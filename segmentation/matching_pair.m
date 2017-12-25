function [ind] = matching_pair(mesh_scan, mesh_smpl)

n_scan = size(mesh_scan.vertices, 1);
n_smpl = size(mesh_smpl.vertices, 1);



% pair = [];
% 
% ind_smpl = (1:n_smpl)';
% ind_invalid = (1:n_smpl)';
% 
% while ~isempty(ind_invalid)
%     ind_scan = knnsearch(mesh_scan.vertices, mesh_smpl.vertices(ind_invalid, :));
%     cross_dot = dot(mesh_smpl.normals(ind_invalid, :).', mesh_scan.normals(ind_scan, :).').';
%     
%     mask_invalid = cross_dot < 0.5;  
%     smpl_valid = ind_smpl(~mask_invalid);
%     scan_valid = ind_scan(~mask_invalid);
%     
%     pair = [pair; [smpl_valid, scan_valid]];
%     
%     ind_invalid = ind_smpl(mask_invalid);
%     
%     a = 0;
%     
% end

[ind_scan, distance] = knnsearch(mesh_scan.vertices, mesh_smpl.vertices, 'K', 1);
normal_dot = zeros(size(distance));
for i = 1 : 1
    ind = ind_scan(:, i);
    cross_dot = dot(mesh_smpl.normals.', mesh_scan.normals(ind, :).').';
    normal_dot(:, i) = cross_dot;
end
[~, max_ind] = max(normal_dot, [], 2);

a = 0;


% % smpl to scan
% 
% ind_scan = knnsearch(mesh_scan.vertices, mesh_smpl.vertices);
% cross_dot = dot(mesh_smpl.normals.', mesh_scan.normals(ind_scan, :).').';
% invalid = cross_dot < 0.5;
% 
% 
% 
% ind_scan = ind_scan(cross_dot > 0.5);
% 
% ind_smpl = (1:n_smpl)';
% ind_smpl = ind_smpl(cross_dot > 0.5);
% 
% pair_smpl2scan = [ind_smpl, ind_scan];














% % scan to smpl
% ind_smpl = knnsearch(mesh_smpl.vertices, mesh_scan.vertices);
% cross_dot = dot(mesh_smpl.normals(ind_smpl, :).', mesh_scan.normals.').';
% ind_smpl = ind_smpl(cross_dot > 0.5);
% 
% ind_scan = (1:n_scan)';
% ind_scan = ind_scan(cross_dot > 0.5);
% 
% pair_scan2smpl = [ind_scan, ind_smpl];
% 
% % filter
% for i = 1 : size(pair_smpl2scan, 1)
%     smpl_ind = pair_smpl2scan(i, 1); 
%     scan_ind = pair_smpl2scan(i, 2);
%     
%     [ind] = find(pair_scan2smpl(:, 1) == scan_ind);
%     if isempty(ind)
%         continue;
%     end
%     
%     if pair_scan2smpl(ind, 2) == smpl_ind
%         matching_pair = [matching_pair; [smpl_ind, scan_ind]];
%     end   
% end

end

