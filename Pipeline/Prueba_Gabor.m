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
DEG2RAD = pi/180; % factor de conversion
M = 127; N = 127; % tamanio de pixeles de la imagen

% -- Parametros de senoidal
uo = -1/80; vo = 1/80; % frecuencias espaciales de la senoidal compleja
phi = 0; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_GAUSS = 10; % Magnitud 
A = 1/50; B = 1/40; % factor escala de X e Y
theta = 45*DEG2RAD; % angulo de rotacion
Xo = floor(N/2); Yo = floor(M/2); % posicion del centro

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
        xr = (j-Xo)*cos(theta)+(i-Yo)*sin(theta);
        yr = -(j-Xo)*sin(theta)+(i-Yo)*cos(theta);
        envGauss(i,j) = K_GAUSS * exp(-pi*((A*xr)^2+(B*yr)^2));
    end
end

gaborWavelet = senoComplex.*envGauss;

% Graficacion
% figure(); 
% subplot 121;
% imshow(real(senoComplex),[]); title('Parte real senoidal compleja')
% subplot 122;
% imshow(real(senoComplex),[]); title('Parte real senoidal compleja')
% figure();
% imshow(envGauss); title('Envolvente Gaussiana')

figure();
subplot 121;
imshow(real(gaborWavelet),[]); title('Parte Real Gabor Wavelet');
% subplot 122;
% imshow(imag(gaborWavelet),[]); title('Parte Imag Gabor Wavelet');

%%
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

[imRGB,imGray] = cargarimagen('DR1.jpg');
[M,N,t] = size(imRGB);
% -- Parametros de senoidal
lambda = [2 5 10 15];
uo = -1./lambda; vo = 1./lambda; % frecuencias espaciales de la senoidal compleja
phi = 0; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_GAUSS = 1; % Magnitud
A = 1/10; B = 1/10; % factor escala de X e Y
theta = 0:20:170; % angulo de rotacion en grados

hSize = [75 75];
imGaborFilt = zeros(M,N,length(theta));
for i=1:length(theta)
    % Filtrado de la imagen 
    for j=1:length(uo)
        imGaborFilt(:,:,i) = filtradogabor(imGray,uo(j),vo(j),phi,...
        K_GAUSS,A,B,theta(i),hSize);
    end
end

imGaborMax = zeros(M,N);
for iFilas=1:M
    for jColum=1:N
        imGaborMax(iFilas,jColum) = max(imGaborFilt(iFilas,jColum,:));
    end
end

subplot 121;
imshow(imGray,[]); title('Imagen Original en grises');
subplot 122;
imshow(imGaborMax,[]); title('Imagen Filtrada');
