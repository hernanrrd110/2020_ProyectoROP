%% === Deteccion de Circulos por Transformada de Hough
% Autor: RODRIGUEZ RUIZ DIAZ, HERNAN

%% === Carga del archivo 
clc; clear all; close all;
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[imRGB] = cargarimagen();
imHSV = rgb2hsv(imRGB); 
[M,N,t] = size(imRGB);

% Mascara binaria para deteccion de lupa
[imMascBin] = crearmascaralupa(imHSV);
% Inicializacion de la mascara segun valores originales de la imagen
maskRGB = imRGB;

% Enmascarar demas valores no clasificados
maskRGB(repmat(imMascBin,[1 1 3])) = 0;
imMascBin = double(imMascBin);
%%
figure('Name','Imagen original y mascaras')
subplot 131; imshow(imRGB); title('Mascara original');
subplot 132; imshow(imMascBin); title('Mascara binaria');
subplot 133; imshow(maskRGB); title('Mascara no binaria');

% Linea para poder medir las circunferencias a marcar
d = imdistline;

%%  === Filtrado y deteccion de la circunferencia
% --- Etapa de deconvolucion
% Funcion de dispersion de puntos modelado mediante una funcion gauussiana
% PSF por siglas en ingles
PSF = fspecial('gaussian',7,7);
iter = 5; % iteraciones del filtrado
% Deconvolucion  Lucy-Richardson
imLuc = deconvlucy(imMascBin,PSF,iter);

% Filtrado pasaalto para acentuar bordes canny o sobel
umbral = 0.2; %valor original 0.06
imBordes = edge(imLuc,'sobel',umbral);

% Intervalo de radio del circulo a detectar
radio1 = round(M/3);
radio2 = round(M/2.2);
warning('off');
[posCent, radio] = imfindcircles(imBordes,[radio1 radio2],...
    'Sensitivity',0.98,'Method','twostage')
% fprintf('Posicion de los centros de los circulos encontrados:  %.2f %.2f\n',...
%     posCent(1),posCent(2));

figure('Name','Imagen filtrada enmarcada')
subplot 121; imshow(imBordes);
viscircles(posCent,radio);

% === Visualizacion de la circunferencia marcada en la imagen 
subplot 122; imshow(imRGB);
viscircles(posCent,radio);

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

figure('Name','Imagen cortada con circulo')
imshow(imCortada)
h = viscircles(posCent,radio);

figure('Name','Imagen cortada')
imshow(imCortada)
    
