function [boundary_local_ind] = garment_boundary(boundary_ind, vertices_ind)

boundary_ind_tmp = vertices_ind;
for i = 1 : length(boundary_ind_tmp)
    r = find(boundary_ind == boundary_ind_tmp(i));
    if ~isnan(r)
        boundary_ind_tmp(i) = -1;
    end    
end

boundary_local_ind = find(boundary_ind_tmp == -1);

end

