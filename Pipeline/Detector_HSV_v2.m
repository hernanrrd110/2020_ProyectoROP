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
[imRGB] = cargarimagen();
[M,N,t] = size(imRGB);

% Mostrar imagen en RGB
f = figure('Name', 'imagen RGB y HSV originales');
imshow(imRGB); title('RGB');
% Conversion a valores HSV
imHSV = im2double(rgb2hsv(imRGB)); 
set(f,'WindowStyle','docked') % Fijar la figura en el editor

% Entrada de mouse del pixel a elegir
[xPos,yPos] = ginput(1);
fprintf(' --- Posicion del pixel seleccionado:\nX = %i \nY = %i',...
    round(xPos),round(yPos));

% Valor de HSV elegido para ser comparado
hsvVal = imHSV(round(yPos),round(xPos),:);
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
[mascaraHSV, countPix] = enmascarhsv(imHSV,tol,hsvVal);

% Imagen Original contra imagen detectada
f = figure('Name', 'imagen RGB y HSV originales');
set(f,'WindowStyle','docked') % Fijar la figura en el editor
subplot(1,2,1),imshow(imRGB); title('Imagen Original');
subplot(1,2,2),imshow(mascaraHSV,[]); title('Areas detectadas');

fprintf('\n --- Puntuacion de frame en Clasificacion HSV: ')
fprintf('%.2f%% \n', (countPix/(M*N)*100));

%% Grafica de Espacio HSV de la imagen para verificacion

% Espacio HSV de toda la imagen y del pixel seleccionado
[espacioHSV, espacioHSVMarcado] = mostrarespaciohsv(imHSV,tol,hsvVal);

% Graficacion 
f = figure('Name', 'Espacio HSV');
set(f,'WindowStyle','docked') % Fijar la figura en el editor

scat1 = scatter3( espacioHSV(:,1),espacioHSV(:,2),espacioHSV(:,3),'.');
xlabel('Tonalidad (H)'); ylabel('Saturacion (S)'); zlabel('Valor (V)'); 
hold on; title('Espacio HSV');
scat2 = scatter3( espacioHSVMarcado(:,1),espacioHSVMarcado(:,2),...
    espacioHSVMarcado(:,3),'red');
scat3 = scatter3(hsvVal(1),hsvVal(2),hsvVal(3),'red'); hold off;
axis equal;
