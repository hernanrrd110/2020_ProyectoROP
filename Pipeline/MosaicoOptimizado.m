clear all; close all; clc;
% Prueba de SURF
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');

nameVid = 'ID_69'; extVid = '.mp4';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');
% Carga de imagenes
[~,imGray1] = cargarimagen(folderMosaico,'Vasos_165.jpg');
[~,imGray2] = cargarimagen(folderMosaico,'Vasos_819.jpg');
% Carga de Mascaras
[~,imMasc1] = cargarimagen(folderMosaico,'MascVasos_165.jpg');
[~,imMasc2] = cargarimagen(folderMosaico,'MascVasos_819.jpg');


