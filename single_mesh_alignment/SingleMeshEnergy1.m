function [energy] = SingleMeshEnergy1(x, model, A_vertices, nearest_pts_s2a, nearest_ind_s2a, n_smpl)

[beta, pose, trans, scale] = divideParam(x(1:86));
[v_shaped, J_shaped] = calShapedMesh(model, beta);
[v_posed] = calPosedMesh(model, pose, v_shaped, J_shaped, 0);
v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;

energy = 0;

f = reshape(model.f + 1, 1, numel(model.f));
eng = v_posed(f, :) - A_vertices(f, :);
eng = norm(eng, 'fro');
energy = energy + eng;

end
