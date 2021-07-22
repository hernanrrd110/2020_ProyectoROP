%% ========= Seleccion Frames por Espacio HSV ==========
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge
% Este scrip se basa en la deteccion de los pixeles de la retina mediante
% clasificacion en el espacio HSV. Se pide en primer lugar, elegir a mano
% uno de los pixeles de la retina, similar a lo que indica el articulo de
% Estrada (2011). Ya se encuentran configurados valores de tolerancia para
% definir el espacio de pixeles retinianos

%% ========= Lectura y display de la imagen en valores RGB y HSV 
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');

% Lectura de imagen en valores RGB
[im_RGB_mascara,M1,N1,t1] = cargar_imagen();
[im_RGB_original,M,N,t] = cargar_imagen();

% Mostrar imagen en RGB
f = figure('Name', 'imagen original y la mascara');
subplot 121;
imshow(im_RGB_original); title('RGB');
% Conversion a valores HSV
im_HSV_original = single(rgb2hsv(im_RGB_original));
im_HSV_mascara = single(rgb2hsv(im_RGB_mascara));
subplot 122;
imshow(im_RGB_mascara); title('Imagen enmascarada');
set(f,'WindowStyle','docked') % Fijar la figura en el editor

% Valor de HSV elegido para ser comparado
MaxH = max(im_HSV_mascara(:,:,1));MaxH = max(MaxH);
MaxS = max(im_HSV_mascara(:,:,2));MaxS = max(MaxS);
MaxV = max(im_HSV_mascara(:,:,3));MaxV = max(MaxV);
MinH = min(im_HSV_mascara(:,:,1));MinH = min(MinH);
MinS = min(im_HSV_mascara(:,:,2));MinS = min(MinS);
MinV = min(im_HSV_mascara(:,:,3));MinV = min(MinV);

%%  ========= Analisis de tonalidad en el espacio HSV 
% Tolerancia para los valores H, S y V del espacio de colores
% respectivamente
tol = [0.1 0.1 0.1];
fprintf('Tolerancia elegida: %.2f\n',tol(1));
[mascara_HSV] = enmascar_HSV(im_HSV_original,tol,hsvVal);

% Imagen Original contra imagen detectada
f = figure('Name', 'imagen RGB y HSV originales');
set(f,'WindowStyle','docked') % Fijar la figura en el editor
subplot(1,2,1),imshow(im_RGB_original); title('Imagen Original');
subplot(1,2,2),imshow(mascara_HSV,[]); title('Areas detectadas');

% Se podria acotar la busqueda a los pixeles en las inmediaciones del pixel
% seleccionado, algo así como el algoritmo del pintor

%% Grafica de Espacio HSV de la imagen para verificacion

% Espacio HSV de toda la imagen y del pixel seleccionado
[EspacioHSV, EspacioHSV_marcado] = mostrar_espacioHSV(im_HSV_original,tol,hsvVal);

% Graficacion 
f = figure('Name', 'Espacio HSV');
set(f,'WindowStyle','docked') % Fijar la figura en el editor

scat1 = scatter3( EspacioHSV(:,1),EspacioHSV(:,2),EspacioHSV(:,3),'.');
xlabel('Tonalidad (H)'); ylabel('Saturacion (S)'); zlabel('Valor (V)'); 
hold on; title('Espacio HSV');
scat2 = scatter3( EspacioHSV_marcado(:,1),EspacioHSV_marcado(:,2),...
    EspacioHSV_marcado(:,3),'red');
scat3 = scatter3(hsvVal(1),hsvVal(2),hsvVal(3),'red'); hold off;
axis equal;
