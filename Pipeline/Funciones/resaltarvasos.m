function [imGaborMax] = resaltarvasos(imRGB)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
imGray = rgb2gray(imRGB);
[M,N] = size(imGray);

%  ========= Filtrado LoG
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

% ===== Filtrado Gabor Wavelet
%   Aplicacion de filtros sucesivos de Gabor Wavelet con respuesta en
%   magnitud y en fase

waveLgth = [10 20]; % vector de longitudes de onda
orient = 0:5:170; % Vector de Orientaciones 

% Arreglo de objetos gabor para el filtrado
gaborArray = gabor(waveLgth,orient,'SpatialAspectRatio', 1,...
    'SpatialFrequencyBandwidth',20); 

[magResp,~] = imgaborfilt(imLoGMax,gaborArray);
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

end

