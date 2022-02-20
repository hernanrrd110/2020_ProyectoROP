function [mascaraCirc] = enmascararcirculo(imRGB,posCent,radio)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

mascaraCirc = imRGB;

for iFilas = 1:size(mascaraCirc,1)
    for jColum = 1:size(mascaraCirc,2)
        % Ecuacion de circunferencia
        if( ( iFilas -posCent(2) )^2 + ...
                ( jColum -posCent(1) )^2 > (radio*0.95)^2)
            mascaraCirc(iFilas,jColum,:) = 0;
        end
    end
end

end

