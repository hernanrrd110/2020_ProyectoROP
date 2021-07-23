%% ======= Clasificacion frames por frecuencias espaciales (Laplaciano)
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge


%% ========= Lectura y display de la imagen
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[imRGB,imGray] = cargarimagen();
[M,N,t] = size(imRGB);

% Conversion a escala de grises
fftImagen = single(fft2(imGray));
moduloFFT = abs(fftImagen);

f = figure('Name', 'imagen RGB y FFT de escala de gris');
subplot 121;
imshow(imRGB); title('RGB');
subplot 122;
imagesc(log(1+abs(fftshift(fftImagen)))); title('Modulo FFT');

%% ========= Medicion de foco
% LAPE: Energy of Laplacian (Subbarao92)
% LAPM: Modified laplacian (Nayar89)
% LAPV: Variance of laplacian (Pech2000)
% LAPD: Diagonal Laplacian (Thelen2009)

fmLAPE = fmeasure(imGray, 'LAPE');
fmLAPM = fmeasure(imGray, 'LAPM');
fmLAPV = fmeasure(imGray, 'LAPV');
fmLAPD = fmeasure(imGray, 'LAPD');

fprintf('Puntución frecuencial por Energia de Laplaciano: %f.2\n',fmLAPE);
fprintf('Puntución frecuencial por Laplaciano Modif: %f.2\n',fmLAPM);
fprintf('Puntución frecuencial por Varianza de Laplaciano: %f.2\n',fmLAPV);
fprintf('Puntución frecuencial por Laplaciano Diagonal: %f.2\n',fmLAPD);





