%% ======= Clasificacion frames por frecuencias espaciales (Gausseano)
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge
% dos filtros pasabanda gaussianos con valor de sigma_l = 2sigma_m
% Se aplica el ventaneo a la FFT con el primer filtro gausseano, con
% parametro de valor sigma_m y luego se aplica a este resultado, el segundo
% filtro gaussiano con parametro sigma_l. El primero para atenuar
% frecuancias altas mientras el segundo para asentuar frecuencias medias
% El parametro sigma controla la cantidad de suavizado.
% El articulo utiliza el valor de sigma_l = 0.1 y sigma_m = 0,25

%% ========= Lectura y display de la imagen
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[im_RGB,M,N,t] = cargar_imagen();
% Conversion a escala de grises
im_Gray = rgb2gray(im_RGB);
% Calculo fft imagen original
fft_h = fft2(im_Gray);
mod_fft_h = abs(fft_h);

% --- Graficacion fft
f = figure('Name', 'imagen RGB y FFT de escala de gris');
subplot 121;
imshow(im_RGB); title('RGB');
subplot 122;
imagesc(log(1+abs(fftshift(fft_h)))); title('Modulo FFT');

%% ========= Filtrado Gaussiano ==========
% Parametros de las funciones gausseanas
sigma_m = [0.25 0.125];
sigma_l = 0.1;

% Filtrados
im_filt_m = imgaussfilt(im_Gray,sigma_m,'FilterDomain','spatial');
fft_m = fft2(im_filt_m);
mod_fft_m = abs(fft_m);

im_filt_l = imgaussfilt(im_filt_m,sigma_l,'FilterDomain','spatial');
fft_l = fft2(im_filt_l);
mod_fft_l = abs(fft_l);

% puntaje_freq = norm(mod_fft_m - mod_fft_l,1)/...
%     norm(mod_fft_h  - mod_fft_m,1);

puntaje_freq = norm(fft_m - fft_l,1)/...
    norm(fft_h  - fft_m,1);

fprintf('Puntaje frecuencial obtenido: %.2f\n',puntaje_freq);


