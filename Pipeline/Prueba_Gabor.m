%% ========= Prueba Gabor filter ==========
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge
% Prueba para hacer desde cero una imagen con funcion ondita Gabor y luego
% hacer el filtrado de una imagen con un kernel Gabor

%% ========= 
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');
warning('off');

% Declaracion de vectores y parametros
RAD = pi/180; % factor de conversion
M = 128; N = 128; % tamanio de pixeles de la imagen

% -- Parametros de senoidal
Uo = -1/80; Vo = 1/80; % frecuencias espaciales de la senoidal compleja
PHI = 0; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_GAUSS = 1; % Magnitud 
A = 1/50; B = 1/40; % factor escala de X e Y
THETA = 45*RAD; % angulo de rotacion
Xo = floor(M/2); Yo = floor(N/2); % posicion del centro

% Seno complejo
senoComplex = zeros(M,N);
for i = 1:M
    for j = 1:N
        senoComplex(i,j) = exp(1i*(2*pi*(Uo*i+Vo*j)+PHI));
    end
end

% Envolvente gaussiana
envGauss = zeros(M,N);
for i = 1:M
    for j = 1:N
        xr = (i-Xo)*cos(THETA)+(j-Yo)*sin(THETA);
        yr = -(i-Xo)*sin(THETA)+(j-Yo)*cos(THETA);
        envGauss(i,j) = K_GAUSS * exp(-pi*((A*xr)^2+(B*yr)^2));
    end
end

gaborWavelet = senoComplex.*envGauss;

% Graficacion
figure(); 
subplot 121;
imshow(real(senoComplex),[-1 1]); title('Parte real senoidal compleja')
subplot 122;
imshow(real(senoComplex),[-1 1]); title('Parte real senoidal compleja')
figure();
imshow(envGauss); title('Envolvente Gaussiana')
figure();
subplot 121;
imshow(real(gaborWavelet),[-1 1]); title('Parte Real Gabor Wavelet');
subplot 122;
imshow(imag(gaborWavelet),[-1 1]); title('Parte Imag Gabor Wavelet');

%%
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

[imRGB,imGray] = cargarimagen('DR1.jpg');
[M,N,t] = size(imRGB);
% -- Parametros de senoidal
Uo = 0.05; Vo = 0.05; % frecuencias espaciales de la senoidal compleja
PHI = 30; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_GAUSS = 1; % Magnitud 
A = 10; B = 10; % factor escala de X e Y
THETA = 45; % angulo de rotacion en grados

hSize = [5 5];
[imFilt] = filtradogabor(imGray,Uo,Vo,PHI,...
    K_GAUSS,A,B,THETA,hSize);

subplot 121;
imshow(real(imFilt)); title('Parte Real filtrado');
subplot 122;
imshow(imag(imFilt)); title('Parte Real filtrado');
