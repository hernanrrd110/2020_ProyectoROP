clear all; close all; clc;
% Prueba de SURF
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_69'; extVid = '.mp4';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 165;
frame2 = 819;

% Carga de imagenes
[~,imGray1] = cargarimagen( fullfile(folderMosaico,...
    sprintf('Vasos_%i.jpg',frame1) ) );
[~,imGray2] = cargarimagen( fullfile(folderMosaico,...
    sprintf('Vasos_%i.jpg',frame2) ) );
% imGray1 = imadjust(imGray1);
% imGray2 = imadjust(imGray2);
% Carga de Mascaras
[~,imMasc1] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascVasos_%i.jpg',frame1) ) );
[~,imMasc2] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascVasos_%i.jpg',frame2) ) );

% Parametros a iterar
numOctaves = 3; %SURF
% metricThreshold = 1000; %SURF
minContrast = 0.01; % BRISK
minQuality = 0.2; % BRISK
% matchThreshold1 = 60; %MATCHING
% matchThreshold2 = 60; %MATCHING

[MOVINGREG] = registracionMatlab(imGray2,imGray1);
imshowpair(MOVINGREG.RegisteredImage,imGray1)