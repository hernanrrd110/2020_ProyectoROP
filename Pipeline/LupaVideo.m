% Prueba Lupa Video

%% ============== Carga Video
clear all; close all; clc;
% Agregado de carpetas de funciones e imagenes
addpath('./Funciones');
addpath('./Imagenes');
% MACROS
SIN_SUBMUESTREO = 0;
SUBMUESTREO = 1;

% Declaracion del objeto para manejar el video
[vidObj, framesNo] = cargarvideo('ID_68_VIDEO.mp4');
% --- Interfaz de usuario para elegir la carpeta de destino 
% folderName = ...
%     uigetdir('Introducir carperta de destino de extraccion de cuadros'); 
folderName = ...
    'D:\GitHub Repositorio\2020_ProyectoROP\Pipeline\Frames_Videos\PruebaLupa';
fprintf('Direccion de frames seleccionada\n');
fprintf('%s\n', folderName);

frameIni = 50;
frameFin = 80;
factorEscala = [1080 1920];

extraerframes(vidObj,...
    frameIni,frameFin,folderName,factorEscala,SUBMUESTREO)

pathMetadatos = fullfile(folderName,'metadatos.mat');
load(pathMetadatos);

% Se extrae frameSelected de metadatos, un array que indica los frames que
% se seleccionaron para el procesamiento


%% ====== Detector lupa
barraWait = waitbar(0,'Deteccion Lupa');
for iFrame = frameIni:frameFin
    if(frameSelected(iFrame) == 1)
        % Cargar imagen
        pathImagen = fullfile(folderName,sprintf('Image_%i.jpg',iFrame));
        imRGB = im2double(imread(pathImagen));
        
        % Extramos la lupa 
        [imCort, ~, ~] = detectorlupa(imRGB);
        if(~isempty(imCort))
            % Guardamos la imagen
            pathLupa = fullfile(folderName,...
                sprintf('Lupa_%i.jpg',iFrame));
            imwrite(imCort,pathLupa);
        end
    end
    waitbar((iFrame-frameIni)/(frameFin-frameIni)); 
end
close(barraWait);


