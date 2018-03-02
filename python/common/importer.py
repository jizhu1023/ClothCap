import scipy.io as scio


def import_mesh():
    file_name = 'data/multi_cloth_opt_meshes.mat'
    data = scio.loadmat(file_name, squeeze_me=True, struct_as_record=False)

    mesh_scan = data['m_scan']
    mesh_smpl = data['m_smpl']
    return mesh_scan, mesh_smpl


def import_extra():
    file_name = 'data/multi_cloth_opt_extra.mat'
    data = scio.loadmat(file_name, squeeze_me=True, struct_as_record=False)

    is_first = data['is_first']
    n_smpl = data['n_smpl']
    return is_first, n_smpl


def import_garments():
    file_name = 'data/multi_cloth_opt_garments.mat'
    data = scio.loadmat(file_name, squeeze_me=True, struct_as_record=False)

    garment_scan = data['garment_scan']
    garment_smpl = data['garment_smpl']
    return garment_scan, garment_smpl


def import_params():
    file_name = 'data/multi_cloth_opt_params.mat'
    data = scio.loadmat(file_name, squeeze_me=True, struct_as_record=False)

    L = data['L']
    theta = data['theta']
    return L, theta


def import_smpl_param():
    file_name = 'data/multi_cloth_opt_smpl_param.mat'
    data = scio.loadmat(file_name, squeeze_me=True, struct_as_record=False)

    smpl_param = data['smpl_param']
    return smpl_param


def import_smpl_model(gender):
    if gender == "male":
        file_name = '../smpl_model/smpl_m.mat'
    else:
        file_name = '../smpl_model/smpl_f.mat'
    data = scio.loadmat(file_name, squeeze_me=True, struct_as_record=False)

    smpl_model = data['model']
    return smpl_model
