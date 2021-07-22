%% ======= Clasificacion frames por frecuencias espaciales (Laplaciano)
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge


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

%% ========= Medicion de foco
% LAPE: Energy of Laplacian (Subbarao92)
% LAPM: Modified laplacian (Nayar89)
% LAPV: Variance of laplacian (Pech2000)
% LAPD: Diagonal Laplacian (Thelen2009)

FM_LAPE = fmeasure(im_Gray, 'LAPE')
FM_LAPM = fmeasure(im_Gray, 'LAPM')
FM_LAPV = fmeasure(im_Gray, 'LAPV')
FM_LAPD = fmeasure(im_Gray, 'LAPD')

fprintf('Puntución frecuencial por Energia de Laplaciano: %f.2\n',FM_LAPE);
fprintf('Puntución frecuencial por Laplaciano Modif: %f.2\n',FM_LAPM);
fprintf('Puntución frecuencial por Varianza de Laplaciano: %f.2\n',FM_LAPV);
fprintf('Puntución frecuencial por Laplaciano Diagonal: %f.2\n',FM_LAPD);





