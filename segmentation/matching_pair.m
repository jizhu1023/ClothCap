function [ind_nearest] = matching_pair(mesh_scan, mesh_smpl)

n_smpl = size(mesh_smpl.vertices, 1);

n_points = 20;

[ind_scan, distance] = knnsearch(mesh_scan.vertices, ...
    mesh_smpl.vertices, 'K', n_points);
normal_dot = zeros(size(distance));
for i = 1 : n_points
    ind = ind_scan(:, i);
    cross_dot = dot(mesh_smpl.normals.', mesh_scan.normals(ind, :).').';
    normal_dot(:, i) = cross_dot;
end
[~, max_ind] = max(normal_dot, [], 2);

ind_nearest = zeros(n_smpl, 1);
for i = 1 : n_smpl
    ind_nearest(i) = ind_scan(i, max_ind(i));
end

end