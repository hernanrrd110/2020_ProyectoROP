function [imagen] = detectar_color(original,nivel_gris)
    imagen  =  original;
    for i=1:size(imagen,1)
        for j=1:size(imagen,2)
            r = original(i,j,1);
            g = original(i,j,2);
            b = original(i,j,3);
            marg = 1;
            if (not(r<nivel_gris && r-marg<g<r+marg && r-marg<b<r+marg))
                imagen(i,j,1) = 255;
                imagen(i,j,2) = 255;
                imagen(i,j,3) = 255;
            end
        end
    end