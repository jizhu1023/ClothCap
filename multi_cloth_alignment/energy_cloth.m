function [energy] = energy_cloth(x, mesh_scan, mesh_smpl, garment_smpl, garment_scan, smpl_param)

L = x(25:end, :);
theta = x(1:24, :);

v_skin  = L(garment_smpl.skin.vertices_ind, :);
v_shirt = L(garment_smpl.shirt.vertices_ind, :);
v_pants = L(garment_smpl.pants.vertices_ind, :);

x_skin  = [theta; v_skin];
x_shirt = [theta; v_shirt];
x_pants = [theta; v_pants];

energy1 = energy_skin(x_skin, mesh_scan, mesh_smpl, ...
    garment_smpl.skin, garment_scan.skin, smpl_param);

energy2 = energy_garment(x_shirt, mesh_scan, mesh_smpl, ...
    garment_smpl.shirt, garment_scan.shirt, smpl_param);

energy3 = energy_garment(x_pants, mesh_scan, mesh_smpl, ...
    garment_smpl.pants, garment_scan.pants, smpl_param);

energy = energy1 + energy2 + energy3;

end
