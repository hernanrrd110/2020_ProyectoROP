function [mascaraHSV,puntajeHSV] = clasificadorhsv(imRGB,posCent,radio)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% Conversion a valores HSV
imHSV = im2double(rgb2hsv(imRGB));
[mascaraHSV] = enmascarhsv(imHSV);
areaCirculo = round(pi*radio^2);
contHSV = 0;
for iFilas = 1:size(imRGB,1)
    for jColum = 1:size(imRGB,2)
        statement1 = (iFilas-posCent(2))^2+...
            (jColum-posCent(1))^2 <= (radio*0.95)^2;
        statement2 = mascaraHSV(iFilas,jColum) == 1;
        if(statement1 && statement2)
            contHSV = contHSV + 1;
        end
    end
end

puntajeHSV = contHSV/areaCirculo;

end

