function [imModif] = resaltarvasos(imRGB, posCent, radio)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

imVerde = imRGB(:,:,2);
% MACRO 
CON_FONDO = 1;
% Recorte 
[imCort, posiciones] = recortelupa(imVerde ,posCent, radio,CON_FONDO);
posX1 = posiciones(1,1);
posX2 = posiciones(1,2);
posY1 = posiciones(2,1);
posY2 = posiciones(2,2);

%  ========= Filtrado LoG
% Parametros del filtro
filterSize = 75; % Por defecto 75
sigma = 0.3:0.02:0.5; % valores de sigma para hacer diferentes filtros

% Declaracion de variables
hLoG = zeros(filterSize,filterSize, length(sigma));
imArrayLoGfilt = zeros(size(imCort,1),size(imCort,2),length(sigma));

for i=1:length(sigma)
    % Creacion de kernel de Laplacian of Gaussian filter
    hLoG(:,:,i) = fspecial('log',filterSize,sigma(i));
    % Filtrado de la imagen 
    imArrayLoGfilt(:,:,i) = imfilter(imCort,hLoG(:,:,i),...
        'symmetric', 'conv');
end

imLoGMax = zeros(size(imCort));
% Se selecciona la respuesta maxima de cada pixel individual para todas 
% las iteraciones 
for iFilas=1:size(imLoGMax,1)
    for jColum=1:size(imLoGMax,2)
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

waveLgth = 10; % vector de longitudes de onda
orient = 0:10:170; % Vector de Orientaciones 

% Arreglo de objetos gabor para el filtrado
gaborArray = gabor(waveLgth,orient,'SpatialAspectRatio', 1,...
    'SpatialFrequencyBandwidth',20); 

[magResp,~] = imgaborfilt(imLoGMax,gaborArray);
imGaborMax = zeros(size(imLoGMax));
% Se selecciona la respuesta maxima de cada pixel individual para todas 
% las iteraciones 

for iFilas=1:size(imGaborMax,1)
    for jColum=1:size(imGaborMax,2)
        isCirc = (iFilas+posY1-1-posCent(2))^2+...
            (jColum+posX1-1-posCent(1))^2 <= (radio*0.95)^2;
        if(isCirc)
            imGaborMax(iFilas,jColum) = max(magResp(iFilas,jColum,:));
        else 
            imGaborMax(iFilas,jColum) = 0;
        end
    end
end

% Normalizacion a valores de intensidad entre 0 y 1
valorMax = max(imGaborMax(:));
valorMin = min(imGaborMax(:));
imGaborMax = (imGaborMax-valorMin)./(valorMax-valorMin);

imModif = imVerde;
imModif(posY1:posY2,posX1:posX2,:) = imGaborMax;


end

