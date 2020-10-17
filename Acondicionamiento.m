%% === Carga del archivo 
% 
clc; clear all; close all;
% Cuadro de diálogo para abrir archivos, guarda nombre de archivo y dirección
[filename,pathname,~] = uigetfile('.png');
 
% Concatena dirección y nombre de archivo
file_datos = strcat(pathname,filename);

% === Imagen en RGB y en escala de grises
rgb = imread(file_datos);
gray_image = rgb2gray(rgb);
modif = detectar_color(rgb,70);

figure('Name','Imagen original')
imshow(rgb);

PSF = fspecial('gaussian',7,7);
figure('Name','Imagen deconv')

iter = 10;
luc1 = deconvlucy(rgb,PSF,iter);
imshow(luc1)
