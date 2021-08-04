%% ========= Vessel mapping ==========
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge

%% ========= Lectura del archivo de la imagen
clear all; close all; clc;
fprintf('====== %s - Vessel Mapping ======\n', datetime());
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[imRGB,imGray] = cargarimagen('DR1.jpg');
[M,N,t] = size(imRGB);

%% ------ Creacion del filtro
% parametros del filtro
filterSize = 5; % El por defecto es 5
sigma = 0.11:1:0.51; % valores de sigma para hacer diferentes filtros

hLoG = zeros(filterSize,filterSize, length(sigma));
filtImage = zeros(M,N,length(sigma));

for i=1:length(sigma)
    % Creacion de kernel de Laplacian of Gaussian filter
    hLoG(:,:,i) = fspecial('log',filterSize,sigma(i));
    % Filtrado de la imagen 
    filtImage(:,:,i) = imfilter(imGray,hLoG(:,:,i));
end

filtImageFinal = zeros(M,N);
% Se selecciona la respuesta maxima de cada pixel individual para todas 
% las iteraciones 
for i=1:M
    for j=1:N
        filtImageFinal(i,j) = max(filtImage(i,j,:));
    end
end

%% ------ Graficacion
f = figure('Name', 'Imagen Original y filtrada');
subplot 121;
imshow(imGray); title('Imagen Original en Grises');
subplot 122;
imshow(filtImageFinal); title('Escala Grises filtrada LoG');

%% Gabor wavelet

