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
f = figure('Name', 'imagen orignal y LUPA');
imshowpair(imRGB,imCort,'montage'); title('imagen orignal y LUPA');

%%
close all;
% -- Filtrado de mediana a la imagen
ventAlto = 50; ventAncho = 50;
imMediana(:,:,1) = medfilt2(imRGB(:,:,1) ,[ventAlto ventAncho]);
imMediana(:,:,2) = medfilt2(imRGB(:,:,2) ,[ventAlto ventAncho]);
imMediana(:,:,3) = medfilt2(imRGB(:,:,3) ,[ventAlto ventAncho]);

%%
% ======== Graficacion imagen original y filtrada
f = figure('Name', 'imagen original y con filtro de mediana');
imshowpair(imRGB,imMediana,'montage')
% set(f,'WindowStyle','docked')

% Operacion de contraste de Weber
contrast_Weber = (imRGB(:,:,2) - imMediana(:,:,2))...
    ./imMediana(:,:,2); 

tc = 0.01; % valor de tolerancia
im_modif = imRGB;

for i=1:M
    for j=1:N
        if(contrast_Weber(i,j)>tc)
            im_modif(i,j,:) = imMediana(i,j,:);
        end
    end
end

f = figure('Name', 'imagen original y modificada');
imshowpair(imRGB,im_modif,'montage')
set(f,'WindowStyle','docked')

