%% ========= Lectura y diplay de la imagen en valores RGB y HSV ==========
clear all; close all; clc;
% Lectura de imagen en valores RGB
im_RGB = imread('imagen_enfocada.jpg');
figure('Name', 'imagen RGB y HSV originales');
subplot(1,2,1)
imshow(im_RGB);
title('RGB')
% Conversion a valores HSV
im_HSV = rgb2hsv(im_RGB);
subplot(1,2,2)
imshow(im_HSV);
title('HSV')
% Entrada de mouse
[x,y] = ginput(1)
%Valor de HSV elegido para ser comparado
hsvVal = im_HSV(round(y),round(x),:);

%%  ========= Analisis de tonalidad en el espacio HSV ==========
% Tolerancia para los valores H, S y V del espacio de colores
tol = [0.3 0.3 0.3];

% Diferencias absolutas entre valores de pixel y el valor elegido
diffH = abs(im_HSV(:,:,1) - hsvVal(1));
diffS = abs(im_HSV(:,:,2) - hsvVal(2));
diffV = abs(im_HSV(:,:,3) - hsvVal(3));

% Dimensiones de la imagen
[M,N,t] = size(im_RGB);
% Matrices para ser rellenadas con 1s
I1 = zeros(M,N); I2 = zeros(M,N); I3 = zeros(M,N);
% Rellenando las matrices con 1 en donde la diferencia es menor a la
% tolerancia
I1( find(diffH < tol(1)) ) = 1;
I1( find(diffS < tol(2)) ) = 1;
I1( find(diffV < tol(3)) ) = 1;

I = I1.*I2.*I3;
% Imagen Original contra imagen detectada

figure('Name', 'imagen RGB y HSV originales');
subplot(1,2,1),imshow(im_RGB); title('Original Image');
subplot(1,2,2),imshow(I,[]); title('Detected Areas');


