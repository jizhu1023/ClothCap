function [energy] = SingleMeshEnergy2(x, model, v_posed, nearest_pts_s2a, nearest_ind_s2a)

A_vertices = x;
A_vertices = reshape(A_vertices, [3, floor(numel(A_vertices) / 3)])';

energy = 0;

f = reshape(model.f + 1, 1, numel(model.f));
eng = v_posed(f, :) - A_vertices(f, :);
eng = norm(eng, 'fro');
energy = energy + eng;

end
