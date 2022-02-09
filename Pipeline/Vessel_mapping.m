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

%% Detectar Lupa, Recorte imagen y mascara HSV
% Deteccion de lupa centrar el procesamiento en la zona requerida

[~, posCent, radio] = detectorlupa(imRGB);
radio = round(radio);
posCent = round(posCent);

if(~isempty(posCent))
    % MACRO
    SIN_FONDO = 0;
    % Recorte
    [imCort, posiciones] = recortelupa(imRGB,posCent, radio,SIN_FONDO);
    posX1 = posiciones(1,1);
    posX2 = posiciones(1,2);
    posY1 = posiciones(2,1);
    posY2 = posiciones(2,2);
    
    [mascaraHSV, ~] = enmascarhsv(rgb2hsv(imCort));
    imCort = imCort .*mascaraHSV;
    
    % % Invertimos el canal verde
    % canalVerde = imCort(:,:,2);
    % imCort(:,:,2) = (imCort(:,:,2)-max(canalVerde(:))).*(-1);
    
else
    imCort = imRGB;
end

figure(); imshow(imCort);
imCort = imCort(:,:,2);

%%  ========= Filtrado LoG
% Parametros del filtro
filterSize = 75; % Por defecto 75
sigma = 0.1:0.05:0.20; % valores de sigma para hacer diferentes filtros

% Declaracion de variables
hLoG = zeros(filterSize,filterSize, length(sigma));
imArrayLoGfilt = zeros(size(imCort,1), size(imCort,2), length(sigma));

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
for iFilas = 1:size(imCort,1)
    for jColum = 1:size(imCort,2)
        % Maxima respuesta del pixel
        imLoGMax(iFilas,jColum) = max(imArrayLoGfilt(iFilas,jColum,:));
    end
end

% Normalizacion a valores de intensidad entre 0 y 1
imLoGMax(imLoGMax<0) = 0;
    
valorMax = max(imLoGMax(:));
valorMin = min(imLoGMax(:));
imLoGMax = (imLoGMax-valorMin)./(valorMax-valorMin);
% imLoGMax = imLoGMax .*mascaraHSV;
% ------ Graficacion
f = figure('Name', 'Filtrado LoG con respuesta maxima');
imshow(imLoGMax,[]); title('Escala Grises filtrada LoG');

%% ===== Filtrado Gabor Wavelet
%   Aplicacion de filtros sucesivos de Gabor Wavelet con respuesta en
%   magnitud y en fase

waveLgth = [10]; % vector de longitudes de onda
orient = 0:10:170; % Vector de Orientaciones 

% Arreglo de objetos gabor para el filtrado
gaborArray = gabor(waveLgth,orient,'SpatialAspectRatio', 1,...
    'SpatialFrequencyBandwidth',10); 

[magResp,phaseResp] = imgaborfilt(imLoGMax,gaborArray);
imGaborMax = zeros(size(imLoGMax));
% Se selecciona la respuesta maxima de cada pixel individual para todas 
% las iteraciones 

for iFilas=1:size(imGaborMax,1)
    for jColum=1:size(imGaborMax,2)
        imGaborMax(iFilas,jColum) = max(magResp(iFilas,jColum,:));
    end
end

% Normalizacion a valores de intensidad entre 0 y 1
valorMax = max(imGaborMax(:));
valorMin = min(imGaborMax(:));
imGaborMax = (imGaborMax-valorMin)./(valorMax-valorMin);

% ------ Graficacion
f = figure('Name','Filtrado Gabor con respuesta maxima');
imshow(imGaborMax); title('Respuesta en Magnitud Gabor');

%% ===== Filtrado Gabor Wavelet 2
%   Aplicacion de filtros sucesivos de Gabor Wavelet con respuesta en
%   magnitud y en fase

% -- Parametros de senoidal
lambda = [2 5 10 15];
uo = -1./lambda; vo = 1./lambda; % frecuencias espaciales de la senoidal compleja
phi = 0; % Desfase de la funciones senoidal

% -- Parametros de envolvente gaussiana
K_GAUSS = 1; % Magnitud
A = 1/10; B = 1/10; % factor escala de X e Y
theta = 0:10:170; % angulo de rotacion en grados

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

% Normalizacion a valores de intensidad entre 0 y 1
valorMax = max(imGaborMax(:));
valorMin = min(imGaborMax(:));
imGaborMax = (imGaborMax-valorMin)./(valorMax-valorMin);

% ------ Graficacion
f = figure('Name','Filtrado Gabor con respuesta maxima');
subplot 121; imshow(imGray); title('Imagen Original');
subplot 122; imshow(imGaborMax); title('Respuesta en Magnitud Gabor');


