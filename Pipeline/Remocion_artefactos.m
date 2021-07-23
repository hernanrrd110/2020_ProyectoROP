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

[im_RGB]= cargar_imagen(); % Funcion para obtener la imagen
[M,N,t] = size(im_RGB);
canal_verde = zeros(size(im_RGB));
canal_verde(:,:,2) = im_RGB(:,:,2);

%%
close all;
% -- Filtrado de mediana a la imagen
vent_alto = 75; vent_ancho = 75;
im_mediana(:,:,1) = medfilt2(im_RGB(:,:,1) ,[vent_alto vent_ancho]);
im_mediana(:,:,2) = medfilt2(im_RGB(:,:,2) ,[vent_alto vent_ancho]);
im_mediana(:,:,3) = medfilt2(im_RGB(:,:,3) ,[vent_alto vent_ancho]);

% im_verde_filt = uint8(zeros(size(im_RGB)));
% im_verde_filt(:,:,2) = im_mediana(:,:,2);

% ======== Graficacion imagen original y filtrada
f = figure('Name', 'imagen original y con filtro de mediana');
imshowpair(im_RGB,im_mediana,'montage')
set(f,'WindowStyle','docked')

% Operacion de contraste de Weber
contrast_Weber = (im_RGB(:,:,2) - im_mediana(:,:,2))...
    ./im_mediana(:,:,2); 

tc = 0.01; % valor de tolerancia
im_modif = im_RGB;

for i=1:M
    for j=1:N
        if(contrast_Weber(i,j)>tc)
            im_modif(i,j,:) = im_mediana(i,j,:);
        end
    end
end

f = figure('Name', 'imagen original y modificada');
imshowpair(im_RGB,im_modif,'montage')
set(f,'WindowStyle','docked')

