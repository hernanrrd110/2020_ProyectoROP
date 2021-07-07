%% ======= Filtrado gauseano, seleccion por informacion frecuencial
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge
% dos filtros pasabanda gaussianos con valor de sigma_l = 2sigma_m
% Se aplica el ventaneo a la FFT con el primer filtro gausseano, con
% parametro de valor sigma_m y luego se aplica a este resultado, el segundo
% filtro gaussiano con parametro sigma_l. El primero para atenuar
% frecuancias altas mientras el segundo para asentuar frecuencias medias
% El parametro sigma controla la cantidad de suavizado.
% El articulo utiliza el valor de sigma_l = 0.1 y sigma_m = 0,25

%% ========= Imagen RGB y  ==========
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
% [im_RGB,M,N,t] = cargar_imagen();
im_RGB = imread('imagem_mov.jpg');

[M,N,t] = size(im_RGB); % Dimensiones de la imagen originales
fft_imagen = single(fft2(im_RGB));
Modulo_fft1 = abs(fft_imagen);
Fase_fft1 = angle(fft_imagen);

f = figure('Name', 'imagen RGB');
subplot 221;
imshow(im_RGB); title('RGB');
subplot 222;
imagesc(log(1+abs(fftshift(fft_imagen(:,:,1))))); title('Modulo FFT RED');
subplot 223;
imagesc(log(1+abs(fftshift(fft_imagen(:,:,2))))); title('Modulo FFT GREEN');
subplot 224;
imagesc(log(1+abs(fftshift(fft_imagen(:,:,3))))); title('Modulo FFT BLUE');
set(f,'WindowStyle','docked')

%% ========= Filtrado Gaussiano ==========
sigma_m = 0.25;
sigma_l = 0.1;

% El primer filtrado en el paper se hace de forma anisotropica porque se
% asume que los artefactos de movimientos se producen principalmente entre
% las filas de las imagenes y no de las columnas. Por ahora lo hacemos de
% forma simetrica.

modulo_filtrada = imgaussfilt(Modulo_fft1,sigma_m);
modulo_filtrada_2 = imgaussfilt(modulo_filtrada,sigma_l);

puntaje_freq = norm(modulo_filtrada-modulo_filtrada_2,1)/...
    norm(Modulo_fft1-modulo_filtrada,1);



