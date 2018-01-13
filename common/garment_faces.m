function [face_ind] = garment_faces(mesh, garment_ind, boundary_faces)

face_ind = mesh.vert_faces(garment_ind, :);
face_ind = reshape(face_ind, numel(face_ind), 1);
face_ind(face_ind == 0) = [];
face_ind = unique(face_ind);

for i = 1 : length(face_ind)
   r = find(boundary_faces == face_ind(i));
   if ~isnan(r)
       face_ind(i) = -1;
   end    
end
face_ind(face_ind == -1) =[];

end