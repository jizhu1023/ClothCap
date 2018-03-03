import numpy as np
import numpy.linalg as lg
from common import calculation
from sklearn.neighbors import NearestNeighbors


def energy_garments(param, *args):

    L = np.reshape(param[72:], [-1, 3])
    theta = np.reshape(param[:72], [-1, 3])

    mesh_scan = args[0]
    mesh_smpl = args[1]
    garment_scan = args[2]
    garment_smpl = args[3]
    smpl_param = args[4]
    smpl_model = args[5]
    is_first = args[6]

    sigma = 0.2
    energy = 0

    if is_first == 1:
        w_g = 1
        w_b = 10
        w_c = 1.5
        w_s = 1000
        w_a = 2000
    else:
        w_g = 1
        w_b = 10
        w_c = 1.5
        w_s = 200
        w_a = 2000

    # 1st data term
    normals_scan = mesh_scan.normals[garment_scan.vertices_ind - 1, :]
    normals_smpl = mesh_smpl.normals[garment_smpl.vertices_ind - 1, :]
    vertices_scan = mesh_scan.vertices[garment_scan.vertices_ind - 1, :]

    _, nearest_ind_d2m = NearestNeighbors(
        n_neighbors=1, algorithm='kd_tree').fit(L).kneighbors(vertices_scan)
    nearest_ind_d2m = nearest_ind_d2m.flatten()
    error_n = np.sum(normals_scan * normals_smpl[nearest_ind_d2m, :], axis=1)
    mask_d2m = np.where(error_n > 0.8)
    nearest_pts_d2m = vertices_scan[mask_d2m[0], :]
    nearest_ind_d2m = nearest_ind_d2m[mask_d2m[0]]

    _, nearest_ind_m2d = NearestNeighbors(
        n_neighbors=1, algorithm='kd_tree').fit(vertices_scan).kneighbors(L)
    nearest_ind_m2d = nearest_ind_m2d.flatten()
    nearest_pts_m2d = vertices_scan[nearest_ind_m2d, :]
    error_n = np.sum(normals_scan[nearest_ind_m2d, :] * normals_smpl, axis=1)
    mask_m2d = np.where(error_n > 0.8)
    nearest_pts_m2d = nearest_pts_m2d[mask_m2d[0], :]

    error_d2m = nearest_pts_d2m - L[nearest_ind_d2m, :]
    error_m2d = nearest_pts_m2d - L[mask_m2d[0], :]

    energy = energy + w_g * (
            np.sum(error_d2m * error_d2m / (error_d2m * error_d2m + sigma * sigma)) +
            np.sum(error_m2d * error_m2d / (error_m2d * error_m2d + sigma * sigma)))

    # 2nd boundary term
    vertices_smpl_boundary = L[garment_smpl.boundary_local_ind - 1, :]
    vertices_scan_boundary = vertices_scan[garment_scan.boundary_local_ind - 1, :]
    normals_smpl_boundary = mesh_smpl.normals[garment_smpl.boundary_ind - 1, :]
    normals_scan_boundary = mesh_scan.normals[garment_scan.boundary_ind - 1, :]

    _, nearest_ind_d2m = NearestNeighbors(
        n_neighbors=1, algorithm='kd_tree').fit(vertices_smpl_boundary).kneighbors(vertices_scan_boundary)
    nearest_ind_d2m = nearest_ind_d2m.flatten()
    error_n = np.sum(normals_scan_boundary * normals_smpl_boundary[nearest_ind_d2m, :], axis=1)
    mask_d2m = np.where(error_n > 0.5)
    nearest_pts_d2m = vertices_scan_boundary[mask_d2m[0], :]
    nearest_ind_d2m = nearest_ind_d2m[mask_d2m[0]]

    _, nearest_ind_m2d = NearestNeighbors(
        n_neighbors=1, algorithm='kd_tree').fit(vertices_scan_boundary).kneighbors(vertices_smpl_boundary)
    nearest_ind_m2d = nearest_ind_m2d.flatten()
    nearest_pts_m2d = vertices_scan_boundary[nearest_ind_m2d, :]
    error_n = np.sum(normals_scan_boundary[nearest_ind_m2d, :] * normals_smpl_boundary, axis=1)
    mask_m2d = np.where(error_n > 0.5)
    nearest_pts_m2d = nearest_pts_m2d[mask_m2d[0], :]

    error_d2m = nearest_pts_d2m - vertices_smpl_boundary[nearest_ind_d2m, :]
    error_m2d = nearest_pts_m2d - vertices_smpl_boundary[mask_m2d[0], :]

    energy = energy + w_b * (
            np.sum(error_d2m * error_d2m / (error_d2m * error_d2m + sigma * sigma)) +
            np.sum(error_m2d * error_m2d / (error_m2d * error_m2d + sigma * sigma)))

    # 3rd coupling term
    n_smpl = smpl_model.v_template.shape[0]
    beta, _, trans, scale = calculation.divide_param(smpl_param)
    v_shaped, j_shaped = calculation.cal_shaped_mesh(smpl_model, beta)
    v_posed = calculation.cal_posed_mesh(smpl_model, theta, v_shaped, j_shaped, 0)
    v_posed = np.tile(trans, [n_smpl, 1]) + v_posed * scale
    v_posed_garment = v_posed[garment_smpl.vertices_ind - 1, :]

    error_coupling = lg.norm(L - v_posed_garment, 'fro')
    energy = energy + w_c * error_coupling

    # 4th laplacian term
    rows = np.transpose(np.tile(garment_smpl.vertices_ind - 1, [garment_smpl.vertices_ind.shape[0], 1]))
    cols = np.tile(garment_smpl.vertices_ind - 1, [garment_smpl.vertices_ind.shape[0], 1])
    Z = mesh_smpl.adjacency_map[rows, cols]
    vertices_degree = np.sum(Z, axis=1)
    H = np.diag(vertices_degree)
    I = np.eye(vertices_degree.shape[0], vertices_degree.shape[0])
    G = I - np.dot(lg.inv(H), Z)
    product = np.dot(G, L)

    error_laplacian = lg.norm(product, 'fro')
    energy = energy + w_s * error_laplacian

    # 5th boundary smoothness term
    error_ring = 0
    rings = garment_smpl.rings
    for i in range(rings.shape[0]):
        ring = rings[i] - 1
        vertices = mesh_smpl.vertices[ring, :]
        for j in range(1, vertices.shape[0] - 1):
            err = vertices[j - 1, :] + vertices[j + 1, :] - 2 * vertices[j, :]
            error_ring = error_ring + np.dot(err, err)

    energy = energy + w_a * error_ring

    return energy
