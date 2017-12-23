function [energy] = SingleMeshEnergy_OneLoss(x, model, nearest_pts_s2a, nearest_ind_s2a)

[beta, pose, trans, scale] = dividePara(x(1:86));
A_vertices = x(87:end);
[v_shaped, j_shaped] = calShapedMesh(model, beta);
[v_posed] = calPosedMesh(model, pose, v_shaped, j_shaped, 0);

v_posed = repmat(trans, 6890, 1) + v_posed * scale;
A_vertices = reshape(A_vertices, [floor(numel(A_vertices) / 3), 3]);

error = nearest_pts_s2a - A_vertices(nearest_ind_s2a, :);
Eg = 0;
Ec = 0;
wg = 2;
wc = 1;
sigma = 0.01;
Eg = Eg + sum(sum(error.^2 ./ (error.^2 + sigma^2)));
f = reshape(model.f+1, 1, numel(model.f));
eng = v_posed(f,:) - A_vertices(f,:);
eng = norm(eng, 'fro');
Ec = Ec + eng;
energy = Eg * wg + Ec * wc;

end
