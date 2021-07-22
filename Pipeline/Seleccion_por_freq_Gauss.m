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
im_Gray = rgb2gray(im_RGB);

% Conversion a escala de grises
fft_imagen = single(fft2(im_Gray));
modulo_fft = abs(fft_imagen);

f = figure('Name', 'imagen RGB y FFT de escala de gris');
subplot 121;
imshow(im_RGB); title('RGB');
subplot 122;
imagesc(log(1+abs(fftshift(fft_imagen)))); title('Modulo FFT');

%% ========= Filtrado Gaussiano ==========
sigma_m = 0.25;
sigma_l = 0.1;

m_filt_m = imgaussfilt(modulo_fft,sigma_m);
m_filt_l = imgaussfilt(m_filt_m,sigma_l);

puntaje_freq = norm(m_filt_m - m_filt_l,1)/...
    norm(modulo_fft - m_filt_m,1);

fprintf('Puntaje frecuencial obtenido: %.2f\n',puntaje_freq);


