function [colors] = render_labels(labels)

colors = zeros(length(labels), 3);
for i = 1 : length(labels)
    if labels(i) == 0 % skin
        colors(i, :) = [200, 86, 0];
    elseif labels(i) == 1 % t-shirt
        colors(i, :) = [25, 114, 175];
    else % pants
        colors(i, :) = [29, 139, 58];    
    end
end

end

