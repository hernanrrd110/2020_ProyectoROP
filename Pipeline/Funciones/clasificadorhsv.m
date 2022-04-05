function [mascaraHSV,puntajeHSV] = clasificadorhsv(imRGB,posCent,radio)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% Conversion a valores HSV
imHSV = im2double(rgb2hsv(imRGB));
% Mascara para valores HSV que entran en la clasificacion 
[mascaraHSV] = enmascarhsv(imHSV);
% Matriz para la mascara circular
mascaraCirc = zeros(size(mascaraHSV));
% Calculo del area del circulo en pixeles
areaCirculo = round(pi*radio^2);

% Recorrido de la imagen para enmascarar
for iFilas = 1:size(imRGB,1)
    for jColum = 1:size(imRGB,2)
        statement1 = (iFilas-posCent(2))^2+...
            (jColum-posCent(1))^2 <= (radio*0.95)^2;
        if(statement1)
            mascaraCirc(iFilas, jColum) = 1; 
        end
    end
end

mascaraHSV = mascaraHSV.*mascaraCirc;
puntajeHSV = nnz(mascaraHSV)/areaCirculo;

end

