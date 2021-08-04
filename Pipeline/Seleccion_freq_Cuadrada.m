%% ======= Clasificacion frames por frecuencias espaciales (Cuadrada)
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge

%% ========= Lectura y display de la imagen
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[imRGB,imGray] = cargarimagen('imagen_mov.jpg');
%'imagen_desenfocada.jpg'
[M,N,t] = size(imRGB);

% Conversion a escala de grises
fftIm = fft2(imGray);
fftIm = fftshift(fftIm);

% Vectores referidos a los ejes frecuenciales
freqV = linspace(round(-M/2),round(M/2),M);
freqU = linspace(round(-N/2),round(N/2),N);

f = figure('Name', 'imagen RGB y FFT de escala de gris');
subplot 121;
imshow(imRGB); title('RGB');
subplot 122;
imagesc(freqV,freqU,log(1+abs(fftIm))); title('Modulo FFT');

%% ========= Medicion de foco
fCutBajoU = N/12; fCutBajoV = M/12;
fCutMediaU = N/8; fCutMediaV = M/8;

% Mascara binaria para obtener las diferentes frecuencias
masc1 = square2d(M/2-fCutBajoV, M/2+fCutBajoV, ...
    N/2-fCutBajoU, N/2+fCutBajoU, M, N);
masc2 = square2d(M/2-fCutMediaV, M/2+fCutMediaV, ...
    N/2-fCutMediaU, N/2+fCutMediaU, M, N);

% Complemento de la segunda mascara
masc3 = zeros(M,N);
masc3(masc2==0) = 1;

% Las FFTs enmascaradas
frecBajas = fftIm .* masc1;
frecMedias = fftIm .* (masc2-masc1);
frecAltas = fftIm .* masc3;

% Graficacion del espacio frecuencial cortado
figure();
subplot 131
imagesc(freqV,freqU,log(1+abs(frecBajas))); title('Frecuencias bajas');
subplot 132
imagesc(freqV,freqU,log(1+abs(frecMedias))); title('Frecuencias medias');
subplot 133
imagesc(freqV,freqU,log(1+abs(frecAltas))); title('Frecuencias altas');









