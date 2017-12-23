function [energy] = SingleMeshEnergy_GMdist(x, model, A_vertices, nearst_pts_s2a, ...
    nearest_ind_s2a, nearest_pts_a2s, mask_a2s)

A_vertices = x;
v_posed = reshape(A_vertices, [3, floor(numel(A_vertices) / 3)])';

sigma = 0.1;
error = nearst_pts_s2a - v_posed(nearest_ind_s2a, :);

energy = 0;
energy = energy + sum(sum(error.^2 ./ (sigma^2 + error.^2)));

error = nearest_pts_a2s - v_posed(mask_a2s,:);
energy = energy + sum(sum(error.^2 ./ (sigma^2 + error.^2)));

end
