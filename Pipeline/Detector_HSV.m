%% ========= Lectura y diplay de la imagen en valores RGB y HSV ==========
% Autor: RODRIGUEZ RUIZ DIAZ, Hernan Jorge
% Este scrip se basa en la deteccion de los pixeles de la retina mediante
% clasificacion en el espacio HSV. Se pide en primer lugar, elegir a mano
% uno de los pixeles de la retina, similar a lo que indica el articulo de
% Estrada (2011). Ya se encuentran configurados valores de tolerancia para
% definir el espacio de pixeles retinianos

clear all; close all; clc;
% Lectura de imagen en valores RGB
[filename, path] = uigetfile ({'*.jpg;*.tif;*.png;*.gif',...
    'All Image Files';'*.*','All Files'},...
    'Seleccione la imagen a analizar');
if(filename == 0)
    fprintf('No se selecciono archivo\n')
else
    fprintf('Archivo Seleccionado:\n ')
    disp(strcat(path,filename));
end

im_RGB = imread(strcat(path,filename));
[M,N,t] = size(im_RGB); % Dimensiones de la imagen originales
f = figure('Name', 'imagen RGB y HSV originales');

% Mostrar imagen en RGB
subplot 121;
imshow(im_RGB); title('RGB');

% Conversion a valores HSV
im_HSV = single(rgb2hsv(im_RGB)); % valores en single en vez de double
subplot 122;
imshow(im_HSV); title('HSV');
set(f,'WindowStyle','docked') % Fijar la figura en el editor

% Entrada de mouse del pixel a elegir
disp('Posicion del pixel seleccionado: ');
[x,y] = ginput(1);
% Valor de HSV elegido para ser comparado
hsvVal = im_HSV(round(y),round(x),:);

%%  ========= Analisis de tonalidad en el espacio HSV ==========
% Tolerancia para los valores H, S y V del espacio de colores
% respectivamente
tol = [0.1 0.1 0.1];
% Diferencias absolutas entre valores de cada pixel y el valor elegido
diffH = abs(im_HSV(:,:,1) - hsvVal(1));
diffS = abs(im_HSV(:,:,2) - hsvVal(2));
diffV = abs(im_HSV(:,:,3) - hsvVal(3));

% Matrices para ser rellenadas con 1
I1 = zeros(M,N); I2 = zeros(M,N); I3 = zeros(M,N);

% Debido a los valores ciclicos del valor de tonalidad (H), es necesario
% evaluar los extremos 
if ( (hsvVal(1)+tol(1))>1 )
for i=1:M
    for j=1:N
       if( (0<=im_HSV(i,j,1)) && (im_HSV(i,j,1)<=(tol(1)+hsvVal(1)-1)) )
           I1(i,j)= 1;
       end
    end
end    
elseif ( (hsvVal(1)-tol(1))<0 )
for i=1:M
    for j=1:N
       if( (1+hsvVal(1)-tol(1))<=im_HSV(i,j,1) && im_HSV(i,j,1)<=1 )
           I1(i,j)= 1;
       end
    end
end
end

% Rellenando las máscaras binarios con 1 en donde la diferencia absoluta 
% es menor a la tolerancia
I1(diffH <= tol(1)) = 1;
I2(diffS <= tol(2)) = 1;
I3(diffV <= tol(3)) = 1;

I = I1.*I2.*I3;

% Imagen Original contra imagen detectada
f = figure('Name', 'imagen RGB y HSV originales');
set(f,'WindowStyle','docked') % Fijar la figura en el editor
subplot(1,2,1),imshow(im_RGB); title('Imagen Original');
subplot(1,2,2),imshow(I,[]); title('Areas detectadas');

% Se podria acotar la busqueda a los pixeles en las inmediaciones del pixel
% seleccionado, algo así como el algoritmo del pintor

%% Grafica de Espacio HSV de la imagen para verificacion
% Para la graficacion del espacio, se hace en primer lugar un reshape de
% para pasar los valores matriciales de la imagen en un vector, luego para
% disminuir los datos a graficar se utiliza la funcion unique de forma de
% eliminar valores repetidos. El parametro rows es necesario para tomar a
% cada fila del vector como una entidad a comparar

% Espacio de toda la imagen
EspacioHSV = unique( reshape( im_HSV,M*N,3 ) ,'rows' );
% Espacio de los pixeles marcados, es decir los pixeles tomados  como de la
% retina
EspacioHSV_marcado = zeros(size(EspacioHSV));

diffH_marc = abs(EspacioHSV(:,1) - hsvVal(1));
diffS_marc = abs(EspacioHSV(:,2) - hsvVal(2));
diffV_marc = abs(EspacioHSV(:,3) - hsvVal(3));

j = 1;
for i=1:length(EspacioHSV)
    if (diffS_marc(i) <= tol(2) && diffV_marc(i) <= tol(3))
        if(diffH_marc(i) <= tol(1))
            EspacioHSV_marcado(j,:) = EspacioHSV(i,:);
            j = j + 1;
        elseif (0<=EspacioHSV(i,1)) && ...
                (EspacioHSV(i,1)<=(tol(1)+hsvVal(1)-1))
            EspacioHSV_marcado(j,:) = EspacioHSV(i,:);
            j = j + 1;
        elseif  ((1+hsvVal(1)-tol(1))<=EspacioHSV(i,1)...
                && EspacioHSV(i,1)<=1)
            EspacioHSV_marcado(j,:) = EspacioHSV(i,:);
            j = j + 1;
        end
    end
end
% Recorte
EspacioHSV_marcado = EspacioHSV_marcado(1:j,:);

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
