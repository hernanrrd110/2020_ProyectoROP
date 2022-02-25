% Resaltar vasos
clear all; close all; clc;
% Agregado de carpetas de funciones e imagenes
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[imRGB,imGray] = cargarimagen();
figure();imshow(imRGB)
imVerde = imRGB(:,:,2);
figure();imshow(imVerde)
%% Filtrado TotHat
se = strel('disk',100,0);

imTopHat = imtophat(imVerde,se);
figure();
imshow(imTopHat);

%% Filtrado BotHat
se = strel('disk',70);
imBotHat = imbothat(imVerde,se);
imshow(imBotHat);


