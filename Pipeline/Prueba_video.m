%% Prueba de video
% Prueba para leer video y extraer frames
%% ====== Carga de video
% Se carga los cuadros obtenidos del video y se extrae informacion
% adicional
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');
warning('off');
TAMANIO_UINT8 = 'uint8';
TAMANIO_UINT16 = 'uint16';

% Declaracion del objeto para manejar el video
vidObj = VideoReader('ID6_Video_ROP_Escalado.mp4');
% Num de frames del video
framesNo = round(vidObj.Duration*vidObj.FrameRate);
% Declaracion estructura de datos para vizualizacion posterior
vidFrame = struct('cdata',zeros(vidObj.Height,vidObj.Width,3,'uint8'),...
    'colormap',[]); 

% Recorrido del video para extraccion de frames
iFrame = 1;
jFrame = 1;
scaleFactor = 0.8;

while hasFrame(vidObj)
    frame = readFrame(vidObj);
    if (mod(iFrame,2)~= 0) % Solo se obtienen los frames impares
        % Se rescala la imagen segun el factor de escala
        vidFrame(jFrame).cdata = imresize(frame,scaleFactor);
        jFrame = jFrame + 1;
    end
    iFrame = iFrame + 1;
end

%% ======== Visualizacion del video
% Obtenemos la resolucion de pantalla
screenReso = get(0,'screensize'); 
% Diferencias entre al resolucion de pantalla y del video
difWidth = screenReso(3) - vidObj.Width*scaleFactor;
difHeight = screenReso(4) - vidObj.Height*scaleFactor;

% Configuramos la posicion de la figura, de la imagen y de los ejes
set(gcf,'OuterPosition',[0 0 ...
    screenReso(3) screenReso(4)]);
set(gca,'Visible','off');
set(gca,'units','pixels');
set(gca,'position',[difWidth/2 difHeight/2 ...
    vidObj.Width vidObj.Height]);

% Reproducimos el video con el framerate especifico
movie(vidFrame,1,vidObj.FrameRate/2);

%%
% Cantidad de espacio requerido para almacenar el video
info = whos('bytes', 'vidFrame');
fprintf('Espacio en memoria del video: %.3f GB\n',info.bytes/1e9);

