function [mascaraCirc] = enmascararcirculo(imRGB,posCent,radio)
%ENMASCARARCIRCULO crea una mascara no binaria de la lupa
%   La funcion enmascara los valores que se encuentran por fuera del valor
%   del radio y centro especificados con valores nulos, y deja intactos los
%   demas valores.
%   Parametros:
%   - imRGB: imagen (double) en formato RGB.
%   - posCent: vector 2x1 con valores de la posicion del centro en X y Y.
%   - radio: valor del radio de la circunferencia.
%   Retornos:
%   - mascaraCirc: imagen RBG enmascarada.

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

