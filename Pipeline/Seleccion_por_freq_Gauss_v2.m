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
[M,N,t] = size(imRGB);

% Calculo fft imagen original
fftH = fft2(imGray);
fftH = fftshift(fftH);
modFFTH = abs(fftH);

% --- Graficacion fft
f = figure('Name', 'imagen RGB y FFT de escala de gris');
subplot 121;
imshow(imRGB); title('RGB');
subplot 122;
imagesc(log(1+modFFTH)); title('Modulo FFT');

%% ========= Filtrado Gaussiano ==========
% Parametros de las funciones gausseanas
sigmaM = 10;
sigmaL = 5;

% Filtrados
figure();
subplot 121;
ventGaussM = fspecial('gaussian',[M,N],sigmaM);
mesh(ventGaussM); title('Kernel Gauss 1')
subplot 122;
ventGaussL = fspecial('gaussian',[M,N],sigmaL);
mesh(ventGaussL); title('Kernel Gauss 2')

%%
% Ventaneo gausseano de la fft de la imagen
fftM = fftH.*ventGaussM; modFFTM = abs(fftM);
fftL = fftM.*ventGaussL; modFFTL = abs(fftL);

figure();
subplot 131;
imagesc(log(1+modFFTH)); title('Modulo FFT original (H)');
subplot 132;
imagesc(log(1+modFFTM));title('Modulo FFT M');
% mesh(modFFTM);
subplot 133;
imagesc(log(1+modFFTL));title('Modulo FFT L');
% mesh(modFFTL);

%%
% Resta de los valores complejos de la fft para obtener las medidas
restaFAltas = fftH-fftM; modRestaFAltas = abs(restaFAltas);
restaFMedias = fftM-fftL; modRestaFMedias = abs(restaFMedias);

figure();
subplot 131;
imagesc(log(1+modFFTL)); title('Modulo Freq Bajas (H)');
subplot 132;
imagesc(log(1+modRestaFMedias));title('Modulo Freq Medias'); 
subplot 133;
imagesc(log(1+modRestaFAltas));title('Modulo Freq Altas');

puntaje = norm(restaFMedias,1)/norm(restaFAltas,1)
