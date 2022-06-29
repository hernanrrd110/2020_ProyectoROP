function [mascaraHSV,puntajeHSV] = clasificadorhsv(imRGB,posCent,radio)
%CLASIFICADORHSV Se obtiene mascara con colores retinales y puntacion HSV.
%   La funcion da como resultado la imagen enmascarada con los pixeles que
%   corresponden a la informacion de la retina y brinda un puntaje con
%   respecto a numero de pixeles que hay en la lupa.
%   Parametros:
%   - imRGB: imagen (double) en formato RGB.
%   - posCent: vector 2x1 con valores de la posicion del centro en X y Y.
%   - radio: valor del radio de la circunferencia.
%   Retornos:
%   - mascaraHSV: imagen binaria (logical) con valor 1 en pixeles retinales
%   y valor 0 en pixeles no retinales. 

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

