function [colors] = render_kmeans(label_kmeans)

colors = zeros(length(label_kmeans), 3);
for i = 1 : length(label_kmeans)
    if label_kmeans(i) == 1 % skin
        colors(i, :) = [255, 255, 0];
    elseif label_kmeans(i) == 2 % t-shirt
        colors(i, :) = [0, 0, 255];
    else % pants
        colors(i, :) = [255, 0, 0];    
    end
end

end
