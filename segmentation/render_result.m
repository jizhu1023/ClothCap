function [colors] = render_result(labels_result)

colors = zeros(length(labels_result), 3);
for i = 1 : length(labels_result)
    if labels_result(i) == 0 % skin
        colors(i, :) = [255, 255, 0];
    elseif labels_result(i) == 1 % t-shirt
        colors(i, :) = [0, 0, 255];
    else % pants
        colors(i, :) = [255, 0, 0];    
    end
end

end

