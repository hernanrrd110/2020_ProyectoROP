%% ======= Eliminacion de artefactos
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge
% Se utiliza la medicion del contraste de Weber para obtener los puntos
% donde se producen los artefactos por la iluminacion en el lente. Para
% ello se utiliza una version de la imagen con filtro de mediana y se hace
% una comparacion con los valores de los pixeles de la imagen.

%% ======= Carga imagen
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

[imRGB]= cargarimagen(); % Funcion para obtener la imagen
[M,N,~] = size(imRGB);

%% ======= Deteccion de LUPA
% Deteccion de lupa centrar el procesamiento en la zona requerida

[imCort, posCent, radio] = detectorlupa(imRGB);
radio = round(radio);
posCent = round(posCent);
figure();
imshow(imCort);

%% ======== Recorte de la imagen en la zona de la Lupa
% Establecemos los limites de la imagen de forma iterativa, de forma de
% encuadrar la lupa lo mas cerca posible en un rectangulo

tolRadio = 20;
posY1 = posCent(2) - radio - tolRadio;
posY2 = posCent(2) + radio + tolRadio;
posX1 = posCent(1) - radio - tolRadio;
posX2 = posCent(1) + radio + tolRadio;

% Se va disminuyendo el numero de la tolerancia a medida que va iterando
while(0>posY1)
    tolRadio = tolRadio - 1;
    posY1 = posCent(2) - radio - tolRadio;
end

tolRadio = 20;
while(posY2>M)
    tolRadio = tolRadio - 1;
    posY2 = posCent(2) + radio + tolRadio;
end

tolRadio = 20;
while(0>posX1)
    tolRadio = tolRadio - 1;
    posX1 = posCent(1) - radio - tolRadio;
end

tolRadio = 20;
while(posX2>N)
    tolRadio = tolRadio - 1;
    posX2 = posCent(1) + radio + tolRadio;
end

% Recorte de la imagen
imCortCuadrado = imRGB(posY1:posY2,posX1:posX2,:);
figure();
imshow(imCortCuadrado);

%% ======== Filtrado de madiana 
close all;
% Se establece la altura y el ancho de la ventana de kernel de mediana
ventAlto = 21; ventAncho = 21;
imMediana = imCortCuadrado;

% Filtrado de mediana iterativo 
iter = 2;
for iFilas = 1:iter
    % Se filtra cada valor de RGB por separado
    imMediana(:,:,1) = medfilt2(imMediana(:,:,1) ,...
        [ventAlto ventAncho]);
    imMediana(:,:,2) = medfilt2(imMediana(:,:,2) ,...
        [ventAlto ventAncho]);
    imMediana(:,:,3) = medfilt2(imMediana(:,:,3) ,...
        [ventAlto ventAncho]);
end

f = figure('Name', 'Mediana');
imshow(imMediana);

%% Procesamiento y remoción de los artefactos por Contraste de Weber
% ======== Graficacion imagen original y filtrada

% Operacion de contraste de Weber
contrastWeber = (imCortCuadrado(:,:,2) - imMediana(:,:,2))...
    ./imMediana(:,:,2); 

tc = 0.15; % valor de tolerancia
imModifCort = imCortCuadrado;

for iFilas = posY1:posY2
    for jColum = posX1:posX2
        % Condición de Weber segun la tolerancia
        statement1 = contrastWeber(iFilas-posY1+1,jColum-posX1+1)>tc; 
        % Condicion para el interior del circulo
        statement2 = (iFilas-posY1+1-posCent(2))^2+...
                        (jColum-posX1+1-posCent(1))^2 <= (radio*0.95)^2;
        if(statement1 && statement2)
            imModifCort(iFilas-posY1+1,jColum-posX1+1,:) = ...
                imMediana(iFilas-posY1+1,jColum-posX1+1,:);
        end
    end
end

f = figure('Name', 'imagen modificada');
imshow(imModifCort)

%% Correccion de distorsion de colores
SIN_ENTRADA_MOUSE = 0;
[mascaraHSV,~] = ...
            clasificadorhsv(imModifCort,SIN_ENTRADA_MOUSE);
imHSV = rgb2hsv(imModifCort);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.7;
channel1Max = 0.179;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 0.431;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.605;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
mascaraExp = ...
    ((imHSV(:,:,1) >= channel1Min) | ...
    (imHSV(:,:,1) <= channel1Max) ) & ...
    (imHSV(:,:,2) >= channel2Min ) & ...
    (imHSV(:,:,2) <= channel2Max) & ...
    (imHSV(:,:,3) >= channel3Min ) & ...
    (imHSV(:,:,3) <= channel3Max);

for iFilas = 1:size(imModifCort,1)
    for jColum = 1:size(imModifCort,2)
        % Condicion del circulo
        statement = (iFilas+posY1-1-posCent(2))^2+...
            (jColum+posX1-1-posCent(1))^2 <= (radio*0.95)^2;
        % condicion de la mascara y la circunferencia
        if(statement && mascaraExp(iFilas,jColum)==1)
            imHSV(iFilas,jColum,2) = 0.431;
        end
    end
end

imModifCort2 = hsv2rgb(imHSV);
figure(); imshow(imModifCort2);
        

        
