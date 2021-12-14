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
[M,N,t] = size(imRGB);

%% ======= Deteccion de LUPA

[imCort, posCent, radio] = detectorlupa(imRGB);
radio = round(radio);
posCent = round(posCent);
figure();
imshow(imCort);
%%
tolRadio = 20;
posY1 = posCent(2) - radio - tolRadio;
posY2 = posCent(2) + radio + tolRadio;
posX1 = posCent(1) - radio - tolRadio;
posX2 = posCent(1) + radio + tolRadio;

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

% 
imCort2 = imRGB(posY1:posY2,posX1:posX2,:);

figure();
imshow(imCort2);

%%
close all;
% -- Filtrado de mediana a la imagen
ventAlto = 15; ventAncho = 15;

imRGBGPU = gpuArray(imRGB);
imMediana = imRGBGPU;

iter = 3;
for i = 1:iter
    if (iter==1)
        imMediana(:,:,1) = medfilt2(imRGBGPU(:,:,1) ,...
            [ventAlto ventAncho]);
        imMediana(:,:,2) = medfilt2(imRGBGPU(:,:,2) ,...
            [ventAlto ventAncho]);
        imMediana(:,:,3) = medfilt2(imRGBGPU(:,:,3) ,...
            [ventAlto ventAncho]);
    else
        imMediana(:,:,1) = medfilt2(imMediana(:,:,1) ,...
            [ventAlto ventAncho]);
        imMediana(:,:,2) = medfilt2(imMediana(:,:,2) ,...
            [ventAlto ventAncho]);
        imMediana(:,:,3) = medfilt2(imMediana(:,:,3) ,...
            [ventAlto ventAncho]);
    end
end
imMediana = gather(imMediana);
f = figure('Name', 'Mediana');
imshow(imMediana);

%%
% ======== Graficacion imagen original y filtrada

% Operacion de contraste de Weber
contrastWeber = (imRGB(:,:,2) - imMediana(:,:,2))...
    ./imMediana(:,:,2); 

tc = 0.2; % valor de tolerancia
imModif = imRGB;

for i=1:M
    for j=1:N
        if(contrastWeber(i,j)>tc)
            imModif(i,j,:) = imMediana(i,j,:);
        end
    end
end

f = figure('Name', 'imagen original y modificada');
imshowpair(imRGB,imModif,'montage')

