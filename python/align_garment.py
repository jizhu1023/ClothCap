import energy_garments
import numpy as np
import chumpy as ch
from common import calculation
from common import importer
from scipy.optimize import minimize


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
    param = ch.hstack((ch.reshape(ch.asarray(theta), [1, -1]), np.reshape(ch.asarray(L), [1, -1])))
    args = (mesh_scan, mesh_smpl, garment_scan,
            garment_smpl, smpl_param, smpl_model, is_first)

    objs = {'garment': energy_garments.energy_garments(param, args)}
    ch.minimize(fun=objs, x0=[param])

    param_opt = minimize(fun=energy_garments.energy_garments, x0=param,
                         args=args, method='BFGS', options={'disp': True, 'maxiter': 10})

    energy = energy_garments.energy_garments(
        param, mesh_scan, mesh_smpl, garment_scan,
        garment_smpl, smpl_param, smpl_model, is_first)

    print(energy)


if __name__ == '__main__':
    main()
