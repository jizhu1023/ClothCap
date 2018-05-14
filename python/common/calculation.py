import cv2
import numpy as np
import numpy.linalg as lg


def divide_param(smpl_param):
    beta = smpl_param[0:10]
    pose = smpl_param[10:82]
    trans = smpl_param[82:85]
    scale = smpl_param[85]
    return beta, pose, trans, scale


def cal_normals(faces, vertices):
    e1 = vertices[faces[:, 1] - 1, :] - vertices[faces[:, 0] - 1, :]
    e2 = vertices[faces[:, 2] - 1, :] - vertices[faces[:, 1] - 1, :]

    cross_product = np.cross(e1, e2)
    normal = lg.norm(cross_product, axis=1)
    cross_product = cross_product / np.transpose(np.tile(normal, [3, 1]))

    normals = np.zeros(vertices.shape)
    normals_count = np.zeros([vertices.shape[0], 1])

    for i in range(cross_product.shape[0]):
        for j in range(3):
            ind = faces[i, j] - 1
            normals[ind, :] = normals[ind, :] + cross_product[i, :]
            normals_count[ind, 0] = normals_count[ind, 0] + 1

    normals = normals / np.tile(normals_count, [1, 3])

    return normals


def cal_shaped_mesh(model, beta):
    shape_coeffs = model.shapedirs.x

    v_offset = np.zeros(shape_coeffs.shape[0:2])
    for i in range(beta.shape[0]):
        v_offset = v_offset + beta[i] * shape_coeffs[:, :, i]

    v_shaped = model.v_template + v_offset
    j_shaped = np.dot(model.J_regressor.toarray(), v_shaped)

    return v_shaped, j_shaped


def cal_posed_mesh(model, theta, v_shaped, j_shaped, blend_pose):
    joints_num = model.J.shape[0]
    pose = np.reshape(theta, [3, -1], order='F')

    if blend_pose == 1:
        pose_rodrigues = np.zeros([(joints_num - 1) * 9, 1])
        for i in range(1, joints_num):
            rotate = np.zeros([3, 3])
            cv2.Rodrigues(pose[:, i], rotate)
            rotate = rotate - np.eye(3, 3)
            pose_rodrigues[(i - 1) * 9:i * 9, :] = np.reshape(rotate, [-1, 1])

        pose_coeffs = model.posedirs
        v_offset = np.zeros(pose_coeffs.shape[0:2])
        for j in range((joints_num - 1) * 9):
            v_offset = v_offset + pose_rodrigues[j, :] * pose_coeffs[:, :, j]
        v_posed = v_shaped + v_offset
    else:
        v_posed = v_shaped

    pose_mat = np.zeros([3, 3, joints_num])
    for i in range(joints_num):
        rotate = np.zeros([3, 3])
        cv2.Rodrigues(pose[:, i], rotate)
        pose_mat[:, :, i] = rotate

    id_to_col = model.kintree_table[1, :]
    parent = id_to_col[model.kintree_table[0, 1:id_to_col.shape[0]]]

    A = np.zeros([4, 4, joints_num])
    A[:, :, 0] = with_zeros(pose_mat[:, :, 0], j_shaped[0, :])

    for i in range(1, joints_num):
        parent_index = parent[i - 1]
        A[:, :, i] = np.dot(A[:, :, parent_index], with_zeros(
            pose_mat[:, :, i], j_shaped[i, :] - j_shaped[parent_index, :]))

    A_global = A.copy()

    for i in range(joints_num):
        A[:, :, i] = A[:, :, i] - pack(np.dot(A[:, :, i], extend(j_shaped[i, :], 0)))

    j_posed = np.zeros([joints_num, 3])
    for i in range(joints_num):
        j_posed[i, :] = A_global[0:3, 3, i]

    A_col_wise = np.reshape(A, [-1, joints_num], order='F')
    A_per_vert = np.dot(A_col_wise, np.transpose(model.weights))
    A_per_vert = np.reshape(A_per_vert, [4, 4, -1], order='F')

    for i in range(A_per_vert.shape[2]):
        new_pos = np.dot(A_per_vert[:, :, i], extend(v_posed[i, :], 1))
        v_posed[i, :] = new_pos[0:3]

    return v_posed


def pack(t):
    Rt = np.zeros([4, 4])
    Rt[:, 3] = t
    return Rt


def with_zeros(R, t):
    Rt = np.zeros([4, 4])
    Rt[0:3, 0:3] = R
    Rt[0:3, 3] = t
    Rt[3, 3] = 1
    return Rt


def extend(t, val):
    t_e = np.zeros([4, ])
    t_e[0:3] = t
    t_e[3] = val
    return t_e
