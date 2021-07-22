%% ========= Vessel mapping ==========
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge

%% ========= Lectura del archivo de la imagen
clear all; close all; clc;
fprintf('====== %s - Vessel Mapping ======\n', datetime());
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[im_RGB,M,N,t] = cargar_imagen('DR1.jpg');
im_Gray = rgb2gray(im_RGB);

%% ------ Creacion del filtro
% parametros del filtro
filter_size = 5; % El por defecto es 5
sigma = 5:1:10; % valores de sigma para hacer diferentes filtros

h_LoG = zeros(filter_size,filter_size, length(sigma));
filt_image = uint8(zeros(M,N,length(sigma)));

for i=1:length(sigma)
    % Creacion de kernel de Laplacian of Gaussian filter
    h_LoG(:,:,i) = fspecial('log',filter_size,sigma(i));
    % Filtrado de la imagen 
    filt_image(:,:,i) = imfilter(im_Gray,h_LoG(:,:,i));
end

filt_image_final = zeros(M,N);
% Se selecciona la respuesta maxima de cada pixel individual para todas 
% las iteraciones 
for i=1:M
    for j=1:N
        filt_image_final(i,j) = max(filt_image(i,j,:));
    end
end

%% ------ Graficacion
f = figure('Name', 'Imagen Original y filtrada');
subplot 121;
imshow(im_Gray); title('Imagen Original en Grises');
subplot 122;
imshow(filt_image_final); title('Escala Grises filtrada LoG');

%% Gabor wavelet

