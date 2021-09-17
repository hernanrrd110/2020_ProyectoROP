%% Prueba de video
% Prueba para leer video y extraer frames

%% ====== Carga de video y seleccion de 
% Se carga los cuadros obtenidos del video y se extrae informacion
% adicional
clear all; close all; clc;
% Agregado de carpetas de funciones e imagenes
addpath('./Funciones');
addpath('./Imagenes');
warning('off');
TAMANIO_UINT8 = 'uint8';
TAMANIO_UINT16 = 'uint16';

% Declaracion del objeto para manejar el video
vidObj = VideoReader('ID6_Video_ROP_Escalado.mp4');
% Num de frames del video
framesNo = round(vidObj.Duration*vidObj.FrameRate);
folderName = uigetdir(); %Para seleccionar la carpeta de destino
fprintf('Direccion de frames seleccionada\n');
fprintf('%s\n', folderName);

%% Extraccion de frames
% Especificar los frames de inicio y fin de extraccion
frameIni = 100;
frameFin = 150;
vidObj.CurrentTime = frameIni/vidObj.FrameRate; % Tiempo inicial

% Recorrido del video para extraccion de frames
iFrame = frameIni;
jFrame = 1;
factorEscala = 1; %factor de escala para el video
resoAjust = [floor(vidObj.Height*factorEscala) ...
    floor(vidObj.Width*factorEscala) ];
vidFrame = zeros(resoAjust(1),resoAjust(2),3,...
    TAMANIO_UINT8);
endTime = frameFin/vidObj.FrameRate; % Tiempo de finalizacion

dispprogress()
barraWait = waitbar(0,'Espere a que la extracción termine');
while vidObj.CurrentTime <= endTime
    frame = readFrame(vidObj);
    if (mod(iFrame,2)~= 0) % Solo se obtienen los frames impares
        % Se rescala la imagen segun el factor de escala
        vidFrame = imresize(frame,factorEscala);
        pathCompleto = fullfile(folderName,...
            sprintf('Image_%i.jpg',iFrame));
        imwrite(vidFrame,pathCompleto);
        jFrame = jFrame + 1;
    end
    iFrame = iFrame + 1;
    waitbar(iFrame-frameIni/frameFin-frameIni); 
    dispprogress(iFrame-frameIni, frameFin-frameIni);
end
close(barraWait);

fprintf(' |========= Proceso de extracion finalizada =========|\n');
% Cantidad de espacio requerido para almacenar el video
% info = whos('bytes', 'vidFrame');
% fprintf('Espacio en memoria del video: %.3f GB\n',info.bytes/1e9);

