%% === Carga del archivo 
% 
clc; clear all; close all;
% Cuadro de diálogo para abrir archivos, guarda nombre de archivo 
% y dirección
[filename,pathname,~] = uigetfile({'*.png';'*.jpeg';'*.*'});
 
% Concatena dirección y nombre de archivo
file_datos = strcat(pathname,filename);

% === Imagen en RGB y en escala de grises
rgb = imread(file_datos);
gray_image = rgb2gray(rgb);

%Con 70 anda bastante bien
nivel_gris = 40;  
modif = detectar_color(rgb,nivel_gris);

figure('Name','Imagen original')
imshow(rgb);
% linea para poder medir las circunferencias a marcar
d = imdistline;

%%
figure('Name','Imagen con filtro de gris')
imshow(modif);

PSF = fspecial('gaussian',7,7);

iter = 5;
luc1 = deconvlucy(modif,PSF,iter);
imshow(luc1)

%% === Filtrado y deteccion de la circunferencia
% Filtrado pasaalto para acentuar bordes canny o sobel
threshold = 0.06;
im_filtrada = edge(rgb2gray(luc1),'sobel',threshold);

figure('Name','Imagen filtrada enmarcada')
subplot(1,2,1)
imshow(im_filtrada);

% Intervalo de radio del circulo a detectar
radio1 = 400;
radio2 = 700;
[centers, radii] = imfindcircles(im_filtrada,[radio1 radio2],...
    'Sensitivity',0.97,'Method','twostage')
h = viscircles(centers,radii);

% === Visualizacion de la circunferencia marcada en la imagen 
subplot(1,2,2)
imshow(rgb);
h = viscircles(centers,radii);

%% Anular valores de la imagen fuera de la circunferencia detectada
% Imagen original enmarcada

im_cortada = rgb;
centers = centers(1,:);
radii = radii(1,:)

for i = 1:size(rgb,1)
    for j = 1:size(rgb,2)
        % Ecuacion de circunferencia
        if((i-centers(2))^2+(j-centers(1))^2 > (radii*0.95)^2)
            im_cortada(i,j,:) = 0;
        end
    end
end

figure('Name','Imagen cortada con circulo')
imshow(im_cortada)
h = viscircles(centers,radii);

figure('Name','Imagen cortada')
imshow(im_cortada)
    
    
    
    
    
    
