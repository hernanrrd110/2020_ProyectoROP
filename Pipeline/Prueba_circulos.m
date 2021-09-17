%% === Carga del archivo 
clc; clear all; close all;
addpath('./Funciones');
addpath('./Imagenes');
warning('off');
% Lectura de imagen en valores RGB
[imRGB] = cargarimagen();
imHSV = rgb2hsv(imRGB); 
[M,N,t] = size(imRGB);

% Mascara binaria para deteccion de lupa
[imMascBin] = crearmascaralupa(imHSV);
imMascBin = double(imMascBin);
figure()
subplot 121; imshow(imRGB); title('Imagen original');
% imdistline;

%% Etapa de deconvolucion
% Funcion de dispersion de puntos modelado mediante una funcion gauussiana
% PSF por siglas en ingles
PSF = fspecial('gaussian',7,7);
iter = 5; % iteraciones del filtrado
% Deconvolucion  Lucy-Richardson
imLuc = deconvlucy(imMascBin,PSF,iter);

%% === Filtrado y deteccion de la circunferencia
% Filtrado pasaalto para acentuar bordes canny o sobel
umbral = 0.2; % valor original 0.06
imBordes = edge(imLuc,'sobel',umbral);

% Intervalo de radio del circulo a detectar
rangoRadio1 = round(M/3)
rangoRadio2 = round(M/2.2)
[posCent, radio] = imfindcircles(imBordes,[rangoRadio1 rangoRadio2],...
    'Sensitivity',0.98,'Method','twostage')

%% Anular valores de la imagen fuera de la circunferencia detectada
% Imagen original enmascarada
imCortada = imRGB;
posCent = posCent(1,:);
radio = radio(1,:);

for iFilas = 1:size(imRGB,1)
    for jColum = 1:size(imRGB,2)
        % Ecuacion de circunferencia
        if((iFilas-posCent(2))^2+(jColum-posCent(1))^2 > (radio*0.95)^2)
            imCortada(iFilas,jColum,:) = 0;
        end
    end
end

subplot 122; imshow(imCortada); title('Mascara cortada');

