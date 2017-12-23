function [prior] = get_prior()

mkdir('segmentation/prior');
smpl_base = mesh_parser('smpl_base_m.obj', 'smpl_model');

if exist('segmentation/prior/prior.mat', 'file')
    prior = load('segmentation/prior/prior.mat');
    prior = prior.prior;
else
    prior.skin = prior_skin(smpl_base);
    prior.shirt = prior_shirt(smpl_base);
    prior.pants = prior_pants(smpl_base);

    save('segmentation/prior/prior.mat', 'prior');
end

smpl_base.colors = render_prior(prior.skin);
mesh_exporter('segmentation/prior/prior_skin.obj', smpl_base, true);

smpl_base.colors = render_prior(prior.shirt);
mesh_exporter('segmentation/prior/prior_shirt.obj', smpl_base, true);

smpl_base.colors = render_prior(prior.pants);
mesh_exporter('segmentation/prior/prior_pants.obj', smpl_base, true);

end