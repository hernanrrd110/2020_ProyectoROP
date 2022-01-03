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
uo = -1/80; vo = 1/80; % frecuencias espaciales de la senoidal compleja
phi = 0; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_GAUSS = 10; % Magnitud 
A = 1/50; B = 1/40; % factor escala de X e Y
THETA = 45*RAD; % angulo de rotacion
Xo = floor(M/2); Yo = floor(N/2); % posicion del centro

% Seno complejo
senoComplex = zeros(M,N);
for i = 1:M
    for j = 1:N
        senoComplex(i,j) = exp(1i*(2*pi*(uo*i+vo*j)+phi));
    end
end

% Envolvente gaussiana
envGauss = zeros(M,N);
for i = 1:M
    for j = 1:N
        xr = (j-Xo)*cos(THETA)+(i-Yo)*sin(THETA);
        yr = -(j-Xo)*sin(THETA)+(i-Yo)*cos(THETA);
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
uo = -1/5; vo =1/5 ; % frecuencias espaciales de la senoidal compleja
phi = 30; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_GAUSS = 10; % Magnitud
A = 10; B = 10; % factor escala de X e Y
THETA = 45; % angulo de rotacion en grados

hSize = [21 21];
[imFilt] = filtradogabor(imGray,uo,vo,phi,...
    K_GAUSS,A,B,THETA,hSize);

subplot 121;
imshow(imGray,[]); title('Imagen Original en grises');
subplot 122;
imshow(imFilt,[]); title('Imagen Filtrada');
