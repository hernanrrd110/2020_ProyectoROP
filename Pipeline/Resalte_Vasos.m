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

%%

imFilt = resaltarvasos(imRGB,0,0);
figure();
%%
imVerdeModif = imadjust(abs(imVerde-imFilt));
imtool(imVerdeModif);
%%
imRGB2 = imRGB;
imRGB2(:,:,2) = imVerdeModif;
imtool(imRGB2)



