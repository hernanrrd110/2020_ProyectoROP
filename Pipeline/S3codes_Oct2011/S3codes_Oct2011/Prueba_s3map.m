%% Prueba s3map
clear all; close all; clc;

img = im2double( rgb2gray( imread('imagen_mov.jpg') ) );
img = img.*255; % Reescalado de valores para la funcion

% Macros para mostrar resultados
SHOW_RES = 1;
NOT_SHOW_RES = 0;

% Llamado a la funcion para hacer el mapa s3
[s_map1 s_map2 mapS3] = s3_map(img);
imshow(mapS3)

% Calculo del valor S3
% Ordenamiento de los valores de la matriz en un vector
vectorS3 = sort(mapS3(:),'descend');
% Numero de elementos que contiene el 1% mas grandes
numOneP = round( length( mapS3(:) )/100 );
% Promedio de 1 porciento de los valores mas grandes
valorS3 = 1/numOneP * sum( vectorS3(1:numOneP) );

fprintf('Valor s3 de la imagen en cuestion: %.2f \n',valorS3);


