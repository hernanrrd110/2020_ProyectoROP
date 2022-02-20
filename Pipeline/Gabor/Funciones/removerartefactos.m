function [imModif] = removerartefactos(imRGB,posCent, radio)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
radio = round(radio);
posCent = round(posCent);

% ======== Recorte de la imagen en la zona de la Lupa
% Establecemos los limites de la imagen de forma iterativa, de forma de
% encuadrar la lupa lo mas cerca posible en un rectangulo

% MACRO 
CON_FONDO = 1;
% Recorte 
[imCortCuadrado, posiciones] = recortelupa(imRGB,posCent, radio,CON_FONDO);
posX1 = posiciones(1,1);
posX2 = posiciones(1,2);
posY1 = posiciones(2,1);
posY2 = posiciones(2,2);

% ======== Filtrado de madiana 
% Se establece la altura y el ancho de la ventana de kernel de mediana
ventAlto = 21; ventAncho = 21;
imMediana = imCortCuadrado;

% Filtrado de mediana iterativo 
iter = 5;
for i = 1:iter
    % Se filtra cada valor de RGB por separado
    imMediana(:,:,1) = medfilt2(imMediana(:,:,1) ,...
        [ventAlto ventAncho]);
    imMediana(:,:,2) = medfilt2(imMediana(:,:,2) ,...
        [ventAlto ventAncho]);
    imMediana(:,:,3) = medfilt2(imMediana(:,:,3) ,...
        [ventAlto ventAncho]);
end

% ===== Procesamiento y remoción de los artefactos por Contraste de Weber

% Operacion de contraste de WeberW
contrastWeber = (imCortCuadrado(:,:,2) - imMediana(:,:,2))...
    ./imMediana(:,:,2); 

tc = 0.01; % valor de tolerancia
imModifCort = imCortCuadrado;

for iFilas = posY1:posY2
    for jColum = posX1:posX2
        % Condición de Weber segun la tolerancia
        statement1 = contrastWeber(iFilas-posY1+1,jColum-posX1+1)>tc; 
        % Condicion para el interior del circulo
        statement2 = (iFilas-posCent(2))^2+...
                        (jColum-posCent(1))^2 <= (radio*0.95)^2;
        if(statement1 && statement2)
            imModifCort(iFilas-posY1+1,jColum-posX1+1,:) = ...
                imMediana(iFilas-posY1+1,jColum-posX1+1,:);
        end
    end
end

% Retornamos los valores al tamanio de la imagen original
imModif = imRGB;
imModif(posY1:posY2,posX1:posX2,:) = imModifCort;

end

