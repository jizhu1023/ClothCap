function mesh_exporter(varargin)

n = numel(varargin);
assert(n >= 2);

mesh_filename = varargin{1};
mesh = varargin{2};

if n == 2
    color = false;
    tex = false;
elseif n == 3
    color = varargin{3};
    tex = false; 
elseif n == 4
    color = varargin{3};
    tex = varargin{4};  
end

assert(~(color & tex)); 

fp = fopen(mesh_filename, 'wb');

[n_faces, ~] = size(mesh.faces);
[n_vertices, ~] = size(mesh.vertices);

if color == true
    for i = 1 : n_vertices
        fprintf(fp, 'v %f %f %f ', mesh.vertices(i, 1), mesh.vertices(i, 2), mesh.vertices(i, 3));
        fprintf(fp, '%d %d %d\n', mesh.colors(i, 1), mesh.colors(i, 2), mesh.colors(i, 3));
    end
else
    for i = 1 : n_vertices
        fprintf(fp, 'v %f %f %f\n', mesh.vertices(i, 1), mesh.vertices(i, 2), mesh.vertices(i, 3));
    end
end

for i = 1 : n_faces
    fprintf(fp, 'f %d %d %d\n', mesh.faces(i, 1), mesh.faces(i, 2), mesh.faces(i, 3));
end

if tex == true
    for i = 1 : n_vertices
        fprintf(fp, 'vt %f %f\n', mesh.tex_coords(i, 1), mesh.tex_coords(i, 2));
    end
end

fclose(fp);

end