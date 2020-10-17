%% === Carga del archivo 
% 
clc; clear all; close all;

% === Imagen en RGB y en escala de grises
rgb = imread('IMG_6213.PNG');
gray_image = rgb2gray(rgb);

figure('Name','Imagen original')
imshow(rgb);
% linea para poder medir las circunferencias a marcar
d = imdistline;

%% === Filtrado y deteccion de la circunferencia
% Filtrado pasaalto para acentuar bordes canny o sobel
im_filtrada = edge(gray_image,'canny');
tamanio = size(im_filtrada);

% Matriz de ceros para crear una imagen enmarcada
im_filt_enmarcada = zeros(round(tamanio(1)*1.20),round(tamanio(2)*1.20));
rgb_enmarcada = zeros(round(tamanio(1)*1.20)...
    ,round(tamanio(2)*1.20),3,'uint8');

% La finalidad de enmarcar la imagen es detectar circunferencia que estan
% fuera del dominio de la imagen, que no serian detectadas de otra manera

% Asignacion de los elementos correspondientes para generar el marco
im_filt_enmarcada(floor(tamanio(1)*0.10):floor(tamanio(1)*1.1)-1,...
    floor(tamanio(2)*0.10):floor(tamanio(2)*1.1)-1) = ...
    im_filtrada(:,:);
rgb_enmarcada(floor(tamanio(1)*0.10):floor(tamanio(1)*1.1)-1,...
    floor(tamanio(2)*0.10):floor(tamanio(2)*1.1)-1,:) = ...
    rgb(:,:,:);

figure('Name','Imagen filtrada enmarcada')
imshow(im_filt_enmarcada);

% Intervalo de radio del circulo a detectar
radio1 = 540;
radio2 = 600;
[centers, radii] = imfindcircles(im_filt_enmarcada,[radio1 radio2],...
    'Sensitivity',0.995,'Method','twostage')

h = viscircles(centers,radii);

%% === Visualizacion de la circunferencia marcada en la imagen 
figure('Name','Imagen rgb enmarcada')
imshow(rgb_enmarcada);
h = viscircles(centers,radii);

%% Anular valores de la imagen fuera de la circunferencia detectada
% Imagen original enmarcada

im_cortada = rgb_enmarcada;

for i = 1:size(rgb_enmarcada,1)
    for j = 1:size(rgb_enmarcada,2)
        % Ecuacion de circunferencia
        if((i-centers(2))^2+(j-centers(1))^2 > radii^2)
            im_cortada(i,j,:) = 0;
        end
    end
end

figure('Name','Imagen cortada')
imshow(im_cortada)
h = viscircles(centers,radii);

%% La imagen vuelve a tener el tamanio original

im_final = im_cortada(floor(tamanio(1)*0.10):floor(tamanio(1)*1.1)-1,...
    floor(tamanio(2)*0.10):floor(tamanio(2)*1.1)-1,:);    
figure('Name','Imagen final')
imshow(im_final)    
    
    
    
    
    
    
