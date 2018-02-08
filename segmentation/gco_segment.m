function [seg_scan, seg_smpl] = gco_segment( ...
    mesh_scan, mesh_smpl, unary_scan, unary_smpl)

n_scan = size(unary_scan, 1);
n_smpl = size(unary_smpl, 1);

% for scan
h_scan = GCO_Create(n_scan, 3);
unary_scan_int = int32(unary_scan);

GCO_SetDataCost(h_scan, unary_scan_int');
GCO_SetSmoothCost(h_scan, ...
    [0, 1, 1;
     1, 0, 1;
     1, 1, 0;] * 50);
GCO_SetNeighbors(h_scan, sparse(triu(mesh_scan.adjacency_map)));
GCO_Expansion(h_scan);
seg_scan = GCO_GetLabeling(h_scan);

% for smpl
h_smpl = GCO_Create(n_smpl, 3);
unary_smpl_int = int32(unary_smpl);

GCO_SetDataCost(h_smpl, unary_smpl_int');
GCO_SetSmoothCost(h_smpl, ...
    [0, 1, 1;
     1, 0, 1;
     1, 1, 0;] * 200);
GCO_SetNeighbors(h_smpl, sparse(triu(mesh_smpl.adjacency_map)));
GCO_Expansion(h_smpl);
seg_smpl = GCO_GetLabeling(h_smpl);

seg_scan = seg_scan - 1;
seg_smpl = seg_smpl - 1;

GCO_Delete(h_scan);
GCO_Delete(h_smpl);

end

