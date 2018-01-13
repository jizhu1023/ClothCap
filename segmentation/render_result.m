function [colors] = render_result(labels_result)

colors = zeros(length(labels_result), 3);
for i = 1 : length(labels_result)
    if labels_result(i) == 0 % skin
        colors(i, :) = [200, 86, 0];
    elseif labels_result(i) == 1 % t-shirt
        colors(i, :) = [25, 114, 175];
    else % pants
        colors(i, :) = [29, 139, 58];    
    end
end

end

