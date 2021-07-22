%% ========= Prueba Gabor filter ==========
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge

%% ========= 
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

% Declaracion de vectores y parametros
rad = pi/180; % factor de conversion
M = 128; N = 128; % tamanio de pixeles de la imagen

% -- Parametros de senoidal
uo = -1/80; vo = 1/80; % frecuencias espaciales de la senoidal compleja
phi = 0; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_gaus = 1; % Magnitud 
a = 1/50; b = 1/40; % factor escala de X e Y
theta = 45*rad; % angulo de rotacion
xo = floor(M/2); yo = floor(N/2); % posicion del centro

% Seno complejo
seno_comp = zeros(M,N);
for i = 1:M
    for j = 1:N
        seno_comp(i,j) = exp(1i*(2*pi*(uo*i+vo*j)+phi));
    end
end

% Envolvente gaussiana
wr = zeros(M,N);
for i = 1:M
    for j = 1:N
        xr = (i-xo)*cos(theta)+(j-yo)*sin(theta);
        yr = -(i-xo)*sin(theta)+(j-yo)*cos(theta);
        wr(i,j) = K_gaus * exp(-pi*((a*xr)^2+(b*yr)^2));
    end
end

Gabor_filt = seno_comp.*wr;

% Graficacion
figure(); 
subplot 121;
imshow(real(seno_comp),[-1 1]); title('Parte real senoidal compleja')
subplot 122;
imshow(real(seno_comp),[-1 1]); title('Parte real senoidal compleja')
figure();
imshow(wr); title('Envolvente Gaussiana')
figure();
subplot 121;
imshow(real(Gabor_filt),[-1 1]); title('Parte Real Gabor Wavelet');
subplot 122;
imshow(imag(Gabor_filt),[-1 1]); title('Parte Imag Gabor Wavelet');

%%
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

[im_RGB,M,N,t] = cargar_imagen('DR1.jpg');
im_Gray = rgb2gray(im_RGB);

% -- Parametros de senoidal
uo = 0.05; vo = 0.05; % frecuencias espaciales de la senoidal compleja
phi = 30; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_gaus = 1; % Magnitud 
a = 10; b = 10; % factor escala de X e Y
theta = 45; % angulo de rotacion en grados

h_size = [5 5];
[im_filt] = filtrado_gabor(im_Gray,uo,vo,phi,...
    K_gaus,a,b,theta,h_size);
subplot 121;
imshow(real(im_filt)); title('Parte Real filtrado');
subplot 122;
imshow(imag(im_filt)); title('Parte Real filtrado');
