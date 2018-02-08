function [sdf_features] = sdf_extractor(mesh)

cd('sdf_extractor');

delete('sdf_temp.obj');
delete('sdf_value.txt');

mesh_exporter('sdf_temp.obj', mesh); 
if strncmp(computer, 'PC', 2)
    system(['sdf_extractor.exe ', 'sdf_temp.obj']);
else
    system(['./sdf_extractor ', 'sdf_temp.obj']);
end

sdf_features = importdata('sdf_value.txt');
sdf_features = sdf_features(:, 2);

delete('sdf_temp.obj');
delete('sdf_value.txt');

cd('..');

end

