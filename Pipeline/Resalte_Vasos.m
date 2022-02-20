% Resaltar vasos
clear all; close all; clc;
% Agregado de carpetas de funciones e imagenes
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[imRGB,imGray] = cargarimagen();

%% Filtrado TotHat
se = strel('disk',100);
imVerde = imRGB(:,:,2);
imTopHat = imtophat(imVerde,se);
imshow(imTopHat);

%% Filtrado BotHat
se = strel('disk',70);
imBotHat = imbothat(imTopHat,se);
imshow(imBotHat);


