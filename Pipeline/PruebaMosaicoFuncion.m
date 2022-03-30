clear all; close all; clc;
% Prueba de SURF
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');

[~,imGray1] = cargarimagen('Vasos_165.jpg');
[~,imGray2] = cargarimagen('Vasos_819.jpg');

imGray1 = imadjust(imGray1);
imGray2 = imadjust(imGray2);

% Pathmetadatos
pathMetadatos = fullfile(cd,'./Frames_Videos/ID_69/metadatos.mat');
load(pathMetadatos);

% Creacion de mascaras
imRGB1 = cargarimagen('ImagenModif_165.jpg');
mascBin1 = clasificadorhsv(imRGB1,posCent(165,:), radio(165));
% Strel de disco para comparacion con la funcion imclose
se = strel('disk',40);
mascBin1 = imclose(mascBin1,se);
se = strel('disk',70);
mascBin1 = imerode(mascBin1,se);
CON_FONDO = 1;
mascBin1 = recortelupa(mascBin1 ,...
            posCent(165,:), radio(165),CON_FONDO); 
imRGB1 = recortelupa(imRGB1 ,...
    posCent(165,:), radio(165),CON_FONDO);

imRGB2 = cargarimagen('ImagenModif_819.jpg');
mascBin2 = clasificadorhsv(imRGB2,posCent(819,:), radio(819));
% Strel de disco para comparacion con la funcion imclose
se = strel('disk',40);
mascBin2 = imclose(mascBin2,se);
se = strel('disk',70);
mascBin2 = imerode(mascBin2,se);
mascBin2 = recortelupa(mascBin2 ,...
    posCent(819,:), radio(819),CON_FONDO);
imRGB2 = recortelupa(imRGB2 ,...
    posCent(819,:), radio(819),CON_FONDO);
% 
imGray1 = imGray1.*mascBin1;
imGray2 = imGray2.*mascBin2;

% Parametros
% Valores Decentes
% minContrast = 0.01;
% minQuality = 0.2;
% matchThreshold = [60 60];
% maxRatio = [0.5 0.7];

minContrast = 0.01;
minQuality = 0.2;
matchThreshold = [40 60];
maxRatio = [0.7 0.8];

[panorama,mascPan,tforms] = mosaicomultidesc(imGray1,imGray2,...
    mascBin1,mascBin2,minContrast,minQuality,matchThreshold,maxRatio);

imshow(panorama);

