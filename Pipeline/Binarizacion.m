clear all; close all; clc;
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');

[imRGB,imGray] = cargarimagen('Vasos_819.jpg');
imGrayAdj = imadjust(imGray);

imBin = imbinarize(imGrayAdj);
imBordes = imbinarize(imGray,'adaptive');
figure; imshow(imBin);


