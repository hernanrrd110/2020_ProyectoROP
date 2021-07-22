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
[im_RGB,M,N,t] = cargar_imagen();

% Mostrar imagen en RGB
f = figure('Name', 'imagen RGB y HSV originales');
subplot 121;
imshow(im_RGB); title('RGB');
% Conversion a valores HSV
im_HSV = single(rgb2hsv(im_RGB)); % valores en single en vez de double
subplot 122;
imshow(im_HSV); title('HSV');
set(f,'WindowStyle','docked') % Fijar la figura en el editor

% Entrada de mouse del pixel a elegir
[x,y] = ginput(1);
fprintf(' --- Posicion del pixel seleccionado:\nX = %i \nY = %i',...
    round(x),round(y));

% Valor de HSV elegido para ser comparado
hsvVal = im_HSV(round(y),round(x),:);
hsvVal = reshape(hsvVal,1,3);
fprintf('\n --- Valor HSV del pixel seleccionado\n')
fprintf('Tonalidad(H): %.4f\n',hsvVal(1))
fprintf('Saturacion(S): %.4f\n',hsvVal(2))
fprintf('Valor(V): %.4f\n',hsvVal(3))

%%  ========= Analisis de tonalidad en el espacio HSV 
% Tolerancia para los valores H, S y V del espacio de colores
% respectivamente
tol = [0.1 0.1 0.1];
fprintf('Tolerancia elegida: %.2f\n',tol(1));
[mascara_HSV, contador_pix] = enmascar_HSV(im_HSV,tol,hsvVal);

% Imagen Original contra imagen detectada
f = figure('Name', 'imagen RGB y HSV originales');
set(f,'WindowStyle','docked') % Fijar la figura en el editor
subplot(1,2,1),imshow(im_RGB); title('Imagen Original');
subplot(1,2,2),imshow(mascara_HSV,[]); title('Areas detectadas');

fprintf('\n --- Puntuacion de frame en Clasificacion HSV: ')
fprintf('%.2f%% \n', (contador_pix/(M*N)*100));

%% Grafica de Espacio HSV de la imagen para verificacion

% Espacio HSV de toda la imagen y del pixel seleccionado
[EspacioHSV, EspacioHSV_marcado] = mostrar_espacioHSV(im_HSV,tol,hsvVal);

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
