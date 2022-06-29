
%% ====================== PIPELINE DE PROCESAMIENTO ======================
% Autor: Rodriguez Ruiz Diaz, Hernan Jorge
% =========== Secuencia de procesamiento
% Extraccion de frames
% Deteccion de lupa
% Clasificacion HSV
% Clasificacion frecuencial
% Vessel mapping
% ===========
 
%% ============== Carga Video
clear all; close all; clc;
% Se utiliza carpetas aparte para el guardado de archivos de imagenes y de
% funciones
addpath('./Funciones');
addpath('./Imagenes');
% MACROS
SIN_SUBMUESTREO = 0;
SUBMUESTREO = 1;
SIN_FONDO = 0;
CON_FONDO = 1;

% Declaracion del objeto para manejar el video
% Se requiere especificar el ID del video y su extension
nameVid = 'ID_244'; extVid = '.mov';
% Funcion de creacion de variable de video
[vidObj, framesNo] = ...
    cargarvideo(fullfile(cd,'./Frames_Videos',strcat(nameVid,extVid)));
frameIni = 1; frameFin = framesNo;
% folderName = ...
%     uigetdir('Introducir carperta de destino de extraccion de cuadros'); 
folderName = fullfile(cd,'./Frames_Videos',nameVid);

factorEscala = [1080 1920];

pathMetadatos = fullfile(folderName,'metadatos.mat');

if(exist(pathMetadatos,'file') == 2)
    load(pathMetadatos);
end

%% ======================= Extraccion de frames =========================
% % Si el video tiene 60 fps, submuestramos a 30 fps 
% if (vidObj.FrameRate == 60)
%     select = SUBMUESTREO;
% else
%     select = SIN_SUBMUESTREO;
% end

% Esta funcion, ademas de extraer los cuadros que no existen
frameIni = 1; frameFin = framesNo;
frameFinExtraido = extraerframes(vidObj,...
    frameIni,frameFin,folderName,factorEscala,SIN_SUBMUESTREO);
load(pathMetadatos);
fprintf(' ======= %s - Extraccion de frames completa ========\n',...
    horaminseg());

% Se extrae frameSelected de metadatos, un array que indica los frames que
% se seleccionaron para el procesamiento

%% =========================== Detector lupa ============================
load(pathMetadatos);
warning('off');
barraWait = waitbar(0,'Deteccion Lupa');
frameIni = 1; frameFin = framesNo;
% Seleccion de frames correspondientes a la segunda etapa
% Si no detecta lupa, no se toma en cuenta el frame

if(exist('posCent','var') == 0)
    frameSelected(:,2) = frameSelected(:,1);
    posCent = zeros(framesNo, 2); % Vector para la posicion del centro
    radio = zeros(framesNo,1); % Vector para el radio de la circunferencia
end

for iFrame = frameIni:frameFin
    if(frameSelected(iFrame,1) == 1)
        % Creando la ruta del archivo de imagen
        pathImagen = fullfile(folderName,sprintf('Image_%i.jpg',iFrame));
        % Cargar imagen
        imRGB = im2double(imread(pathImagen));
        % Extramos la lupa
        [imCort, aux1, aux2] = detectorlupa(imRGB,[270 460]);
        if(~isempty(imCort)) 
            % Guardamos la imagen
%             imwrite(imCort,pathLupa);
            posCent(iFrame,:) = aux1;
            radio(iFrame) = aux2;
            frameSelected(iFrame,2) = 1;
        else
            % Si no se detecta el cuadro, no se selecciona
            frameSelected(iFrame,2) = 0;
        end
    end
    waitbar((iFrame-frameIni)/(frameFin-frameIni));
end

fprintf(' ======= %s - Deteccion de Lupa completa ========\n',horaminseg())
fprintf(' -- Num total de detecciones: %i/%i \n',...
    nnz(frameSelected(:,2)),nnz(frameSelected(:,1)));
close(barraWait);
save(pathMetadatos,'frameSelected','posCent','radio','-append'); 
% es necesario correr matlab como administrador para utilizar el comando 
% -append

%% Recortamos la Lupa con el radio minimo detectado
radioMin = min(radio(frameSelected(:,2) == 1));
radioMin = radioMin*1.10;

barraWait = waitbar(0,'Recorte Lupa con radio minimo');
frameIni = 1; frameFin = framesNo;
for iFrame = frameIni:frameFin
    if(frameSelected(iFrame,2) == 1)
        % Creando la ruta del archivo de imagen
        pathImagen = fullfile(folderName,sprintf('Image_%i.jpg',iFrame));
        pathLupa2 = fullfile(folderName,sprintf('Lupa2_%i.jpg',iFrame));
        % Cargar imagen
        imRGB = im2double(imread(pathImagen));
        % Recorte de Lupa 2
        [mascaraCirc] = ...
            enmascararcirculo(imRGB,posCent(iFrame,:),radioMin);
        [mascaraCirc, ~] = ...
        recortelupa(mascaraCirc ,...
                posCent(iFrame,:), radioMin,CON_FONDO);   
        % Guardamos la imagen
        imwrite(mascaraCirc,pathLupa2);
        waitbar((iFrame-frameIni)/(frameFin-frameIni));
        
    end
end
fprintf(' ======= %s - Segundo Recorte Lupa completado ========\n',...
    horaminseg())
save(pathMetadatos,'radioMin','-append');
close(barraWait);
%% ======================== Clasificacion HSV ===========================
load(pathMetadatos);
% Declaracion para vector con puntajes HSV
frameIni = 1; frameFin = framesNo;
if(exist('clasHSV','var') == 0)
    clasHSV = zeros(framesNo,1);
    frameSelected(:,3) = frameSelected(:,2);
end

barraWait = waitbar(0,'Clasificacion HSV');
umbralHSV = 0.4;
for iFrame = frameIni:frameFin
    if(frameSelected(iFrame,2) == 1) % Si el frame fue seleccionado
        pathLupa = fullfile(folderName,sprintf('Image_%i.jpg',iFrame));
        % Cargar imagen de la mascara de la lupa
        imRGB = im2double(imread(pathLupa));

        % Extreaemos las mascaras y el puntaje
        [~,clasHSV(iFrame)] = ...
            clasificadorhsv(imRGB,posCent(iFrame,:), radio(iFrame));
        
        if(clasHSV(iFrame)<umbralHSV)
            frameSelected(iFrame,3) = 0;
        else
            frameSelected(iFrame,3) = 1;
        end
    end % ======
    waitbar((iFrame-frameIni)/(frameFin-frameIni));
end

fprintf(' ======= %s - Clasificacion HSV completa ========\n',...
    horaminseg())
fprintf(' -- Num de clasificaciones: %i/%i \n',...
    nnz(frameSelected(:,3)),nnz(frameSelected(:,2)));

close(barraWait);
save(pathMetadatos,'frameSelected','clasHSV','-append');

%% ===================== Clasificacion de enfoque =======================
load(pathMetadatos);
frameIni = 1; frameFin = framesNo;
if(exist('enfoque','var') == 0)
    % SFIL: Steerable filters-based (Minhas2009)
    enfoque = zeros(framesNo,1);
    frameSelected(:,4) = frameSelected(:,3);    
end
barraWait = waitbar(0,'Clasificación de enfoque');

for iFrame = frameIni:frameFin
    % Si el frame esta seleccionado de la etapa anterior
    if(frameSelected(iFrame,3) == 1) 
        pathIm = fullfile(folderName,sprintf('Image_%i.jpg',iFrame));
        imRGB = imread(pathIm);
        imGray = im2double(rgb2gray(imRGB));
        [~, pos] = ...
        recortelupa(imRGB ,...
                posCent(iFrame,:), radioMin,1);

%         SFIL: Steerable filters-based (Minhas2009)
        [enfoque(iFrame)] = ...
            fmeasure(imGray, 'SFIL',...
            [pos(1,1) pos(2,1) pos(1,2)-pos(1,1) pos(2,2)-pos(2,1)]);
        % Cambio en la barra de progreso
        waitbar((iFrame-frameIni)/(frameFin-frameIni));
    end 
 
end
close(barraWait);
fprintf(' ======= %s - Clasificacion de enfoque completa ========\n',...
    horaminseg())

save(pathMetadatos,'frameSelected','enfoque','-append');

%%  ===================== Selección  =====================
load(pathMetadatos);
% vector de cuadros 
vecFrames = (frameIni:frameFin)';
% Valores del vector de enfoque
enfNorm = enfoque;
enfNorm = enfNorm/max(enfNorm);
enfNorm(isnan(enfNorm)) = 0; 

% Sacamos los valores iguales al 0
enfNorm2 = enfNorm(enfNorm ~= 0);
vecFrames2 = vecFrames(enfNorm ~= 0);
% Obtenemos los indices de los maximos locales para este nuevo vector
maxLoc = islocalmax(enfNorm2);
% Valores de maximos locales
enfMaxLoc = enfNorm2(maxLoc); 
vecFramesMaxLoc = vecFrames2(maxLoc);

% Seleccion primaria
umbralEnfoque = 0.8;
aux = zeros(size(frameSelected(:,3)));
aux(vecFramesMaxLoc(enfNorm(vecFramesMaxLoc)>= umbralEnfoque)) = 1;
frameSelected(:,4) = aux;

fprintf(' -- Num de seleccion final: %i/%i \n',...
    nnz(frameSelected(:,4)),nnz(frameSelected(:,3)));

save(pathMetadatos,'frameSelected','umbralEnfoque',...
    'enfoque','enfNorm','enfNorm2','vecFrames','vecFrames2','-append');
%% Graficacion de valores de enfoque
figure('Name', 'Valores de puntaje enfoque');
plot(vecFrames2,enfNorm2);
hold on; plot(vecFrames2, umbralEnfoque * ones(size(vecFrames2)));
hold on; plot(vecFrames(frameSelected(:,4)), ...
    enfNorm(frameSelected(:,4)),'c*' );
title 'Gauss';
ylim([0 1.1])
fprintf('Cuadros seleccionados')
vecFrames(frameSelected(:,4))

%% Graficacion de Valores HSV

figure('Name', 'Valores de clasificacion HSV');
plot(vecFrames(clasHSV~=0),clasHSV(clasHSV~=0));
title 'HSV 1';

%% ======================= Remocion artefactos ========================== 
% En esta parte se eliminan las partes de la imagen que eran por demás
% brillosas
load(pathMetadatos);
barraWait = waitbar(0,'Remocion de artefactos');
frameIni = 1; frameFin = framesNo;
for iFrame = frameIni:frameFin
    pathSalida = fullfile(folderName,sprintf('ImagenModif_%i.jpg',iFrame)); 
    if(frameSelected(iFrame,4) == 1)
        % Lectura de imagen
        pathImagen = ...
            fullfile(folderName,sprintf('Image_%i.jpg',iFrame));
        imRGB = imread(pathImagen);
        % Removemos los artefactos de la imagen
        [imModif] = ...
            removerartefactos(imRGB,posCent(iFrame,:), radio(iFrame));
        % Guardamos la imagen
        imwrite(imModif,pathSalida);    
    end
    % Cambio en la barra de progreso
    waitbar((iFrame-frameIni)/(frameFin-frameIni)); 
end

fprintf(' ======= %s - Remocion artefactos completa ========\n',...
    horaminseg())
close(barraWait);

%% ======================= Mapeo de Vasos ==========================
load(pathMetadatos);
barraWait = waitbar(0,'Mapeo de vasos');
if(exist('posiciones','var') == 0)
    posiciones = zeros(framesNo, 2, 2);
end
% Carpeta de guardado de imagenes para mosaico
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');
if(exist(folderMosaico,'dir') == 0)
    mkdir(folderMosaico);
end

frameIni = 1; frameFin = framesNo;
for iFrame = frameIni:frameFin
    % Rutas de guardado de imagenes
    pathSalida = fullfile(folderName,sprintf('Vasos_%i.jpg',iFrame));
    pathMosaico =  fullfile(folderMosaico,...
        sprintf('Vasos_%i.jpg',iFrame));
    pathMosaicoRGB =  fullfile(folderMosaico,...
        sprintf('VasosRGB_%i.jpg',iFrame));
    pathMosaicoBin =  fullfile(folderMosaico,...
        sprintf('MascVasos_%i.jpg',iFrame));
    
    % Si el cuadro esta seleccionado
    if(frameSelected(iFrame,4) == 1)
        % Lectura de imagen
        pathImagen = fullfile(folderName,...
            sprintf('ImagenModif_%i.jpg',iFrame));
        imRGB = im2double(imread(pathImagen));
        mascBin = ...
            clasificadorhsv(imRGB,posCent(iFrame,:), radio(iFrame));
        % Creamos el mapa de vasos
        imModif = ...
            resaltarvasos(imRGB,...
            posCent(iFrame,:),radio(iFrame));
        mascBinModif = cerrayerocionarmascara(mascBin,100,20);

        % Guardamos la imagen
        CON_FONDO = 1;
        [imModif, posiciones(iFrame,:,:)] = ...
            recortelupa(imModif ,...
            posCent(iFrame,:), radio(iFrame),SIN_FONDO);
        [mascBinModif,~] = ...
            recortelupa(mascBinModif,...
            posCent(iFrame,:),radio(iFrame),SIN_FONDO);
        imModif2 = imModif.*mascBinModif;
        
        % Normalizacion a valores de intensidad entre 0 y 1
        valorMax = max(imModif2(:));
        valorMin = min(imModif2(:));
        imModif2 = (imModif2-valorMin)./(valorMax-valorMin);
        
        % Normalizacion a valores de intensidad entre 0 y 1
        valorMax = max(imModif(:));
        valorMin = min(imModif(:));
        imModif = (imModif-valorMin)./(valorMax-valorMin);
        posX1 = posiciones(iFrame,1,1);
        posX2 = posiciones(iFrame,1,2);
        posY1 = posiciones(iFrame,2,1);
        posY2 = posiciones(iFrame,2,2);
        
        imModifRGB = imRGB(posY1:posY2,posX1:posX2,:).*mascBinModif;
        imModifRGB(:,:,2) = abs(imModifRGB(:,:,2)-0.15*imModif2); 
        
        imwrite(imadjust(imModif),pathSalida);
        
        imwrite(imadjust(imModif2),pathMosaico);
        imwrite(imModifRGB,pathMosaicoRGB);
        imwrite(mascBinModif,pathMosaicoBin);
    end

    % Cambio en la barra de progreso
    waitbar((iFrame-frameIni)/(frameFin-frameIni));
end
fprintf(' ======= %s - Mapeo de vasos completado ========\n',...
    horaminseg());

save(pathMetadatos,'posiciones','-append');
close(barraWait);

%% ================= Resaltado de imagenes imagenes ======================

barraWait = waitbar(0,'Resaltado de Imagen');
frameIni = 1; frameFin = framesNo;
for iFrame = frameIni:frameFin
    if(frameSelected(iFrame,4)== 1)
        
        
        % Path de la imagen
        pathImagen = fullfile(folderName,...
            sprintf('ImagenModif_%i.jpg',iFrame));
        pathVasos = fullfile(folderName,...
            sprintf('Vasos_%i.jpg',iFrame));
        pathSalida = fullfile(folderName,...
            sprintf('ImagenFinal_%i.jpg',iFrame));
        pathSalida2 = fullfile(folderName,...
            sprintf('ImagenFinal2_%i.jpg',iFrame));
        % Lectura de imagen
        imRGB = im2double(imread(pathImagen));
        imVasos = im2double(imread(pathVasos));
        [imVerde] = enmascararcirculo(imRGB(:,:,2),...
            posCent(iFrame,:),radio(iFrame));
               
        [~, posiciones(iFrame,:,:)] = ...
            recortelupa(imVerde ,...
            posCent(iFrame,:), radio(iFrame),SIN_FONDO);
        
        posX1 = posiciones(iFrame,1,1);
        posX2 = posiciones(iFrame,1,2);
        posY1 = posiciones(iFrame,2,1);
        posY2 = posiciones(iFrame,2,2);
        
        imVerdeRecort = imVerde(posY1:posY2,posX1:posX2);
        imVerdeMod = abs(imVerdeRecort-0.15*imVasos);
        
        for iFilas = 1:size(imVerdeMod,1)
            for jColum = 1:size(imVerdeMod,2)
                if( (iFilas+posY1-1-posCent(iFrame,2) )^2 +...
                        (jColum+posX1-1-posCent(iFrame,1))^2 > ...
                        (radio(iFrame)*0.95)^2)
                    imVerdeMod(iFilas,jColum) = ...
                        imRGB(iFilas+posY1-1,jColum+posX1-1,2);
                end
            end
        end
        
        imFinal = imRGB;
        imFinal(posY1:posY2,posX1:posX2,2) = imVerdeMod;
        mascBin = enmascararcirculo(imFinal,...
            posCent(iFrame,:),radio(iFrame));
        mascBin = 0.4*(~mascBin)+ mascBin;
        imFinal2 = imFinal(posY1:posY2,posX1:posX2,:)...
            .*mascBin(posY1:posY2,posX1:posX2);
        
        imwrite(imFinal.*mascBin,pathSalida);
        imwrite(imFinal2,pathSalida2);
    end
    
    % Cambio en la barra de progreso
    waitbar((iFrame-frameIni)/(frameFin-frameIni));
end

fprintf(' ======= %s - Resaltado de imagenes completado ========\n',...
    horaminseg());
close(barraWait);


%% Creacion de video apartir de imagenes
% Se contruye un objeto VideoWriter, 
% que crea un archivo AVI Motion-JPEG de forma predeterminada.

outputVideo = VideoWriter(fullfile(folderName,'videoSalida.avi'));
outputVideo.FrameRate = frameRate;
open(outputVideo)
% Se recorre la secuencia de imágenes, cargue cada imagen y luego 
% escribirla en el vídeo.
iFrame = 1;
repeticiones = 1; % Indica num de veces que se repitio
numMaxRep = round(outputVideo.FrameRate * 1.5); % maximo de rep

% Inicializacion barra de proceso
barraWait = waitbar(0,'Video de salida'); 

while(iFrame <= framesNo)
    if(frameSelected(iFrame,4)== 1) % Cuadros seleccionados se repiten
        if (repeticiones == 1)  % Si es la primera vez
            pathImagen = fullfile(folderName,...
                sprintf('ImagenFinal_%i.jpg',iFrame));
            repeticiones = 2;
        elseif(repeticiones >= numMaxRep) % Alcanza la condicion
            iFrame = iFrame + 1;
            repeticiones = 1;
        else
            repeticiones = repeticiones + 1; % Aumenta contador
        end
        % Se escribe el cuadro en el video
        imSalida = im2double(imread(pathImagen));
        writeVideo(outputVideo,imSalida);
        
    elseif(frameSelected(iFrame,1) == 1 && mod(iFrame,2) == 1)
        % No se repite este frame
        pathImagen = fullfile(folderName,...
            sprintf('Image_%i.jpg',iFrame));
        % Se escribe el cuadro en el video
        imSalida = im2double(imread(pathImagen));
        writeVideo(outputVideo,imSalida);
        iFrame = iFrame + 1;
    else
        iFrame = iFrame + 1;
    end
    
    % Cambio en la barra de progreso
    waitbar(iFrame/framesNo)
    
end
close(barraWait);
fprintf(' ======= %s - Salida de Video completa ========\n',horaminseg());
% Finalizamos el archivo de vídeo.
close(outputVideo)

    
