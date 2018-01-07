function [ normals ] = calNormal( triangles,pts )
%CALNORMAL Summary of this function goes here
%   Detailed explanation goes here
e1 = pts(triangles(:,2),:) - pts(triangles(:,1),:); 
e2 = pts(triangles(:,3),:) - pts(triangles(:,2),:);
normal = cross(e1.',e2.').';
for i = 1:size(normal,1)
    normal(i,:) = normal(i,:) / norm(normal(i,:));
end
normal_pts = zeros(size(pts));
normal_count = zeros(size(pts,1),1);
for i = 1:size(normal,1)
    for j = 1:3
        id = triangles(i,j);
        normal_pts(id,:) = normal_pts(id,:) + normal(i,:);
        normal_count(id) = normal_count(id) + 1; 
    end
end
normal_pts = normal_pts ./ repmat(normal_count,1,3);
normals = normal_pts;

end

