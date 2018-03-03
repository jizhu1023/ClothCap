import numpy as np
from common import calculation
from common import importer
from scipy.io import savemat
from scipy.optimize import minimize
from energy_garments import  energy_garments


def main():
    # import data from MATLAB
    mesh_scan, mesh_smpl = \
        importer.import_mesh()
    garment_scan, garment_smpl = \
        importer.import_garments()
    L, theta = \
        importer.import_params()
    is_first, n_smpl = \
        importer.import_extra()
    smpl_param = \
        importer.import_smpl_param()
    smpl_model = \
        importer.import_smpl_model(gender="male")

    mesh_smpl_temp = mesh_smpl
    mesh_smpl_temp.vertices[garment_smpl.vertices_ind - 1, :] = L
    mesh_smpl_temp.normals = calculation.cal_normals(mesh_smpl_temp.faces, mesh_smpl_temp.vertices)

    # optimization
    param = np.hstack((np.reshape(theta, [1, -1]), np.reshape(L, [1, -1])))
    args = (mesh_scan, mesh_smpl_temp, garment_scan,
            garment_smpl, smpl_param, smpl_model, is_first)

    param_opt = minimize(fun=energy_garments, x0=param,
                         args=args, method='BFGS', options={'disp': True, 'maxiter': 10})

    opt_param = param_opt.x
    opt_theta = np.reshape(opt_param[0, :72], [-1, 3])
    opt_L = np.reshape(opt_param[0, 72:], [-1, 3])

    savemat(file_name="data/opt_params", mdict={"L": opt_L, "theta": opt_theta})

    # energy = energy_garments(param, args)
    # print(energy)


if __name__ == '__main__':
    main()
