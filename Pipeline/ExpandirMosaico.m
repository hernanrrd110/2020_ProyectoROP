clear all; close all; clc;
% Prueba de SURF
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');

[~,imGray] = cargarimagen('Vasos_315.jpg');
[~,imMosaic1] = cargarimagen('Mosaico1.jpg');
[~,imBinMosaic] = cargarimagen('MascaraMosaico1.jpg');
imGray = imadjust(imGray);
% Pathmetadatos
pathMetadatos = fullfile(cd,'./Frames_Videos/ID_69/metadatos.mat');
load(pathMetadatos);

% Creacion de mascaras
imRGB = cargarimagen('ImagenModif_315.jpg');
mascBin = clasificadorhsv(imRGB,posCent(315,:), radio(315));
% Strel de disco para comparacion con la funcion imclose
[mascBin] = cerrayerocionarmascara(mascBin,40,40);
CON_FONDO = 1;
mascBin = recortelupa(mascBin ,...
            posCent(315,:), radio(315),CON_FONDO); 
imRGB = recortelupa(imRGB ,...
    posCent(315,:), radio(315),CON_FONDO);

numOctaves = 3; %SURF
metricThreshold = 1000; %SURF
minContrast = 0.01; % BRISK
minQuality = 0.2; % BRISK
matchThreshold = [60 60]; %MATCHING
maxRatio = [0.5 0.7]; %MATCHING
metric = 'SAD';

[panorama,mascPan,tforms] = mosaicomultidesc(imMosaic1,imGray,...
    imBinMosaic,mascBin,numOctaves,metricThreshold,...
    minContrast,minQuality,...
    matchThreshold,maxRatio,metric);
figure();imshow(panorama);