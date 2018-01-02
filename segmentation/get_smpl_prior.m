function [prior_smpl] = get_smpl_prior()

mkdir('segmentation/prior_base');
smpl_base = mesh_parser('smpl_base_m.obj', 'smpl_model');

if exist('segmentation/prior_base/prior_base.mat', 'file')
    prior_smpl = load('segmentation/prior_base/prior_base.mat');
    prior_smpl = prior_smpl.prior_smpl;
else
    prior_smpl.skin = prior_skin(smpl_base);
    prior_smpl.shirt = prior_shirt(smpl_base);
    prior_smpl.pants = prior_pants(smpl_base);

    save('segmentation/prior_base/prior_base.mat', 'prior_smpl');
end

smpl_base.colors = render_prior(prior_smpl.skin);
mesh_exporter('segmentation/prior_base/prior_smpl_skin.obj', smpl_base, true);

smpl_base.colors = render_prior(prior_smpl.shirt);
mesh_exporter('segmentation/prior_base/prior_smpl_shirt.obj', smpl_base, true);

smpl_base.colors = render_prior(prior_smpl.pants);
mesh_exporter('segmentation/prior_base/prior_smpl_pants.obj', smpl_base, true);

end