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
[imRGB,imGray] = cargarimagen();

% Conversion a escala de grises
fftImagen = fft2(imGray);
moduloFFT = abs(fftImagen);

f = figure('Name', 'imagen RGB y FFT de escala de gris');
subplot 121;
imshow(imRGB); title('RGB');
subplot 122;
imagesc(log(1+abs(fftshift(fftImagen)))); title('Modulo FFT');

%% ========= Filtrado Gaussiano ==========
sigmaM = 0.25;
sigmaL = 0.1;

modFiltM = imgaussfilt(moduloFFT,sigmaM);
modFiltL = imgaussfilt(modFiltM,sigmaL);

puntajeFreq = norm(modFiltM - modFiltL,1)/...
    norm(moduloFFT - modFiltM,1);

fprintf('Puntaje frecuencial obtenido: %.2f\n',puntajeFreq);


