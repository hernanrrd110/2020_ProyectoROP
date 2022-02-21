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
    CON_FONDO = 1;
    % Recorte
    [imCortRGB, posiciones] = recortelupa(imRGB,posCent, radio,CON_FONDO);
    posX1 = posiciones(1,1);
    posX2 = posiciones(1,2);
    posY1 = posiciones(2,1);
    posY2 = posiciones(2,2);
    
%     [mascaraHSV] = enmascarhsv(rgb2hsv(imCortRGB));
%     imCort = imCort .*mascaraHSV;
    
    % % Invertimos el canal verde
    % canalVerde = imCort(:,:,2);
    % imCort(:,:,2) = (imCort(:,:,2)-max(canalVerde(:))).*(-1);
    
else
    imCortRGB = imRGB;
end
figure(); imshow(imCortRGB);
imCort = imCortRGB(:,:,2);

%%  ========= Filtrado LoG
% Parametros del filtro
filterSize = 75; % Por defecto 75
sigma = 0.3:0.02:0.50; % valores de sigma para hacer diferentes filtros

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

% % Normalizacion a valores de intensidad entre 0 y 1
% imLoGMax(imLoGMax<0) = 0;
    
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

for iFilas = 1:size(imCort,1)
    for jColum = 1:size(imCort,2)
        % Ecuacion de circunferencia
        if( ( iFilas +posY1 -1 -posCent(2) )^2 + ...
                ( jColum +posX1 -1 -posCent(1) )^2 > (radio*0.95)^2)
            imLoGMax(iFilas,jColum,:) = 0;
        end
    end
end

[mascaraHSV] = enmascarhsv(rgb2hsv(imCortRGB));
imGaborMax = imGaborMax .*mascaraHSV;

% Normalizacion a valores de intensidad entre 0 y 1
valorMax = max(imGaborMax(:));
valorMin = min(imGaborMax(:));
imGaborMax = (imGaborMax-valorMin)./(valorMax-valorMin);

%imCort = imCort .*mascaraHSV;

% ------ Graficacion
f = figure('Name','Filtrado Gabor con respuesta maxima');
imshow(imGaborMax); title('Respuesta en Magnitud Gabor');




