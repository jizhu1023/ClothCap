function [label_scan_n, label_smpl_n] = manually_modify(mesh_scan, mesh_smpl, label_scan, label_smpl)

label_scan_n = label_scan;
label_smpl_n = label_smpl;

% for smpl
add_shirt = ...
    [4350; 1807; 864; 863; 3094; 6561] + 1;
add_pants = ...
    [3083; 3092; 3096; 3095; 3088; 883; 3481; 4371; 6513; 6519; 6520; 6516; 6506 ...
    ] + 1;

label_smpl_n(add_shirt, :) = 1;
label_smpl_n(add_pants, :) = 2;




end

