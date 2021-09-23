%% ====================== PIPELINE DE PROCESAMIENTO ======================
% Autor: Rodriguez Ruiz Diaz, Hernan Jorge
% =========== Secuencia de procesamiento 
% Clasificacion HSV
% Clasificacion frecuencial
% Deteccion de lupa
% Vessel mapping
% =========== 

%% Carga imagenes
clear all; close all; clc;
% Agregado de carpetas de funciones e imagenes
addpath('./Funciones');
addpath('./Imagenes');
% carga de imagenes
imRGB = cargarimagen();

%% ====== Clasificacion HSV
% -- DECLARACION MACROS
SIN_ENTRADA_MOUSE = 0;
ENTRADA_MOUSE = 1;
% ----
[mascaraHSV,puntajeHSV] = clasificadorhsv(imRGB,SIN_ENTRADA_MOUSE);
figure(); imshow(mascaraHSV);
fprintf('Puntaje frecuencial antes de mascara lupa: %.2f\n',puntajeHSV);
% ----
%% ====== Detector lupa
[imCort, posCent, radio] = detectorlupa(imRGB);
imshow(imCort);
warning('off');

%% ====== Clasificacion HSV
% -- DECLARACION MACROS
SIN_ENTRADA_MOUSE = 0;
ENTRADA_MOUSE = 1;

[mascaraHSV,puntajeHSV] = clasificadorhsv(imCort,SIN_ENTRADA_MOUSE);
figure(); imshow(mascaraHSV);
fprintf('Puntaje frecuencial antes de mascara lupa: %.2f\n',puntajeHSV);


