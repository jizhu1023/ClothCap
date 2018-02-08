function [label_scan_n, label_smpl_n] = manually_modify( ...
    mesh_scan, mesh_smpl, label_scan, label_smpl)

label_scan_n = label_scan;
label_smpl_n = label_smpl;

% for smpl
add_skin = [ ...
     6794; 6816; 4277; 4741] + 1;
add_shirt = [ ...
     ] + 1;
add_pants = [ ...
     ] + 1;

label_smpl_n(add_skin, :) = 0;
label_smpl_n(add_shirt, :) = 1;
label_smpl_n(add_pants, :) = 2;

% for scan

end

