%% ========= Vessel mapping ==========
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge

%% ========= Lectura del archivo de la imagen
clear all; close all; clc;
fprintf('====== %s - Vessel Mapping ======\n', datetime());
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[imRGB,imGray] = cargarimagen();
[M,N,t] = size(imRGB);

%%  ========= Filtrado LoG
% Parametros del filtro
filterSize = 75; % Por defecto 75
sigma = 0.11:0.05:0.51; % valores de sigma para hacer diferentes filtros

% Declaracion de variables
hLoG = zeros(filterSize,filterSize, length(sigma));
imArrayLoGfilt = zeros(M,N,length(sigma));

for i=1:length(sigma)
    % Creacion de kernel de Laplacian of Gaussian filter
    hLoG(:,:,i) = fspecial('log',filterSize,sigma(i));
    % Filtrado de la imagen 
    imArrayLoGfilt(:,:,i) = imfilter(imGray,hLoG(:,:,i),...
        'symmetric', 'conv');
end

imLoGMax = zeros(M,N);
% Se selecciona la respuesta maxima de cada pixel individual para todas 
% las iteraciones 
for iFilas=1:M
    for jColum=1:N
        % Maxima respuesta del pixel
        imLoGMax(iFilas,jColum) = max(imArrayLoGfilt(iFilas,jColum,:));
    end
end

% Normalizacion a valores de intensidad entre 0 y 1
valorMax = max(imLoGMax(:));
valorMin = min(imLoGMax(:));
imLoGMax = (imLoGMax-valorMin)./(valorMax-valorMin);

% ------ Graficacion
f = figure('Name', 'Filtrado LoG con respuesta maxima');
subplot 121; imshow(imGray); title('Imagen Original en Grises');
subplot 122; imshow(imLoGMax); title('Escala Grises filtrada LoG');

%% ===== Filtrado Gabor Wavelet
%   Aplicacion de filtros sucesivos de Gabor Wavelet con respuesta en
%   magnitud y en fase

waveLgth = [10 15 20]; % vector de longitudes de onda
orient = 0:5:170; % Vector de Orientaciones 

% Arreglo de objetos gabor para el filtrado
gaborArray = gabor(waveLgth,orient); 

[magResp,phaseResp] = imgaborfilt(imLoGMax,gaborArray);
imGaborMax = zeros(M,N);
% Se selecciona la respuesta maxima de cada pixel individual para todas 
% las iteraciones 
for iFilas=1:M
    for jColum=1:N
        imGaborMax(iFilas,jColum) = max(magResp(iFilas,jColum,:));
    end
end

% Normalizacion a valores de intensidad entre 0 y 1
valorMax = max(imGaborMax(:));
valorMin = min(imGaborMax(:));
imGaborMax = (imGaborMax-valorMin)./(valorMax-valorMin);

% ------ Graficacion
f = figure('Name','Filtrado Gabor con respuesta maxima');
subplot 121; imshow(imGray); title('Imagen Original');
subplot 122; imshow(imGaborMax); title('Respuesta en Magnitud Gabor');
