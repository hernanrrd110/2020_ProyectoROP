%% ====================== PIPELINE DE PROCESAMIENTO ======================
% Autor: Rodriguez Ruiz Diaz, Hernan Jorge
% =========== Secuencia de procesamiento
% Extraccion de frames
% Clasificacion HSV
% Clasificacion frecuencial
% Deteccion de lupa
% Vessel mapping
% ===========

%% ============== Carga Video
clear all; close all; clc;
% Agregado de carpetas de funciones e imagenes
addpath('./Funciones');
addpath('./Imagenes');
% MACROS
SIN_SUBMUESTREO = 0;
SUBMUESTREO = 1;
% Declaracion del objeto para manejar el video
[vidObj, framesNo] = cargarvideo('ID_69_VIDEO.mp4');
% --- Interfaz de usuario para elegir la carpeta de destino 
% folderName = ...
%     uigetdir('Introducir carperta de destino de extraccion de cuadros'); 
folderName = './Frames_Videos/ID_69';
folderName = fullfile(cd,folderName);

fprintf('-- Direccion de frames seleccionada\n');
fprintf('%s\n', folderName);

frameIni = 1;
frameFin = framesNo;
factorEscala = [1080 1920];

pathMetadatos = fullfile(folderName,'metadatos.mat');

if(exist(pathMetadatos,'file') == 2)
    load(pathMetadatos);
end

%% ======================= Extraccion de frames =========================
warning('off');
% % Si el video tiene 60 fps, submuestramos a 30 fps 
% if (vidObj.FrameRate == 60)
%     select = SUBMUESTREO;
% else
%     select = SIN_SUBMUESTREO;
% end

% Esta funcion, ademas de extraer los cuadros que no existen, tambien
% resetea los metadatos
extraerframes(vidObj,...
    frameIni,frameFin,folderName,factorEscala,select)
load(pathMetadatos);

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
        % Verificamos que el archivo existe, en cuyo caso se emite la
        % operacion
        pathLupa = fullfile(folderName,sprintf('Lupa_%i.jpg',iFrame));
        % Cargar imagen
        imRGB = im2double(imread(pathImagen));
        % Extramos la lupa
        [imCort, aux1, aux2] = detectorlupa(imRGB);
        if(~isempty(imCort)) 
            % Guardamos la imagen
            imwrite(imCort,pathLupa);
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

disp(' ============== Deteccion de Lupa completo ==================')
close(barraWait);
save(pathMetadatos,'frameSelected','posCent','radio','-append');
%% Recortamos la Lupa con el radio minimo detectado
radioMin = min(radio(frameSelected(:,2) == 1));
radioMin = radioMin*1.10;

barraWait = waitbar(0,'Deteccion Lupa con radio minimo');
for iFrame = frameIni:frameFin
    if(frameSelected(iFrame,2) == 1)
        % Creando la ruta del archivo de imagen
        pathImagen = fullfile(folderName,sprintf('Image_%i.jpg',iFrame));
        % Verificamos que el archivo existe, en cuyo caso se emite la
        % operacion
        pathLupa2 = fullfile(folderName,sprintf('Lupa2_%i.jpg',iFrame));
        % Cargar imagen
        imRGB = im2double(imread(pathImagen));
        if(~isfile(pathLupa2))
            % Recorte de Lupa 2
            [mascaraCirc] = ...
                enmascararcirculo(imRGB,posCent(iFrame,:),radioMin);
            % Guardamos la imagen
            imwrite(mascaraCirc,pathLupa2);
            waitbar((iFrame-frameIni)/(frameFin-frameIni));
        end

    end
end

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

for iFrame = frameIni:frameFin
    if(frameSelected(iFrame,2) == 1) % Si el frame fue seleccionado
        pathLupa = fullfile(folderName,sprintf('Lupa_%i.jpg',iFrame));
        % Cargar imagen de la mascara de la lupa
        imRGB = im2double(imread(pathLupa));
        % Extreaemos las mascaras y el puntaje
        [mascaraHSV,clasHSV(iFrame)] = ...
            clasificadorhsv(imRGB,posCent(iFrame,:), radio(iFrame));
        pathMascara = fullfile(folderName,...
            sprintf('MascaraHSV_%i.jpg',iFrame));
        if(clasHSV(iFrame)<=0.4)
            frameSelected(iFrame,3) = 0;
        else
            frameSelected(iFrame,3) = 1;
        end
    end % ======
    waitbar((iFrame-frameIni)/(frameFin-frameIni));
end
disp(' ============== Clasificacion HSV completa ==================')
close(barraWait);

save(pathMetadatos,'frameSelected','clasHSV','-append');

%% ===================== Clasificacion frecuencial =======================
load(pathMetadatos);
frameIni = 1; frameFin = framesNo;
if(exist('frecLap','var') == 0)
    % ------- Struct para etapas de procesamiento
    % Metodo gaussiano implementado como Estrada 2011
    frecGauss = zeros(framesNo,1);
    frameSelected(:,4) = frameSelected(:,3);
    
end
barraWait = waitbar(0,'Clasificación frecuencial');

for iFrame = frameIni:frameFin
    % Si el frame esta seleccionado de la etapa anterior
    if(frameSelected(iFrame,3) == 1) 
        pathIm = fullfile(folderName,sprintf('Lupa2_%i.jpg',iFrame));
        imRGB = imread(pathIm);
        imGray = im2double(rgb2gray(imRGB));
        % puntaje por LAPLACE
        [frecLap.LAPE(iFrame)] = ... 
            fmeasure(imGray, 'LAPE');
        [frecLap.LAPD(iFrame)] = ...
            fmeasure(imGray, 'LAPD');
        % Puntaje por Gauss
%         [frecGauss(iFrame)] = ...
%             clasificadorfrec(imGray, 'gaussiano');
        [frecGauss(iFrame)] = ...
            fmeasure(imGray, 'SFIL');
        % Cambio en la barra de progreso
        waitbar((iFrame-frameIni)/(frameFin-frameIni));
    end 

end
close(barraWait);
disp(' ========== Clasificacion frecuencial completa ==============')

%%  ===================== Selección  =====================
load(pathMetadatos);
% vector de cuadros 
vecFrames = (frameIni:frameFin)';
% Valores del vector de Gauss Normalizado
gaussNorm = frecGauss;
gaussNorm = gaussNorm/max(gaussNorm);
gaussNorm(isnan(gaussNorm)) = 0; 

% Ordenamiento de valores segun los valores normalizados de Gauss
[gaussOrdenado, indicesOrd] = sort(gaussNorm,'descend');

% Encontramos maximos locales
gaussNorm2 = gaussNorm(gaussNorm ~= 0);
maxLoc = islocalmax(gaussNorm2);
vecFrames2 = vecFrames(gaussNorm ~= 0);
[gaussOrdenado2, indicesOrd2] = sort(gaussNorm2,'descend');

NVal = 15;
% Nos quedamos con los N elementos mas grandes
maxValores = gaussOrdenado(1:NVal);
maxInd = indicesOrd(1:NVal);
maxInd2 = vecFrames2(indicesOrd2(1:NVal));

% Seleccion primaria
aux = zeros(framesNo,1);
aux(vecFrames2(gaussNorm2 >= 0.75)) = 1;
aux(vecFrames2(gaussNorm2 < 0.75)) = 0;
frameSelected(:,4) = aux;

% Armamos valores que necesitamos
aux = zeros(framesNo,1);
aux(maxInd2) = 1;
frameSelected(:,5) = aux;

if(nnz(frameSelected(:,4)) < nnz(frameSelected(:,5)))
    frameSelected(:,4) = frameSelected(:,5);
end

save(pathMetadatos,'frameSelected',...
    'frecGauss','gaussNorm','-append');

%% Mostramos los valores frecuenciales
close all;

% Obtenemos la resolucion de pantalla
screenReso = get(0,'screensize'); 

figure('Name', 'Valores de puntaje');

plot(vecFrames2,gaussNorm2);
hold on; plot(vecFrames2, 0.7 * ones(size(vecFrames2)));
hold on; plot(vecFrames(frameSelected(:,4)), ...
    gaussNorm(frameSelected(:,4)),'c*' );
title 'Gauss';
ylim([0 1.1])

%% Valores HSV

% Configuramos la posicion de la figura y la tabla
set(gcf,'OuterPosition',[0 0 ...
    screenReso(3) screenReso(4)]);
set(uiTablaHSV,'OuterPosition',[screenReso(3)*0.05 screenReso(4)*0.05 ...
    screenReso(3)*0.9 screenReso(4)*0.83]);

figure('Name', 'Valores de clasificacion HSV');
plot(vecFrames,etapas.clasHSV(frameIni:frameFin));
title 'HSV 1';


%% ======================= Remocion artefactos ========================== 
% En esta parte se eliminan las partes de la imagen que eran por demás
% brillosas
load(pathMetadatos);
barraWait = waitbar(0,'Remocion de artefactos');
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

disp(' ========== Remocion artefactos completa ==============')
close(barraWait);

%% ============ Enmascaramiento de imagenes de fondo retinal =============

load(pathMetadatos);
barraWait = waitbar(0,'Enmascaramiento');
for iFrame = frameIni:frameFin
    pathSalida = fullfile(folderName,sprintf('MascaraHSV_%i.jpg',iFrame)); 
    if(frameSelected(iFrame,4) == 1)
        % Lectura de imagen
        pathImagen = ...
            fullfile(folderName,sprintf('ImagenModif_%i.jpg',iFrame));
        imRGB = im2double(imread(pathImagen));
        % Extreaemos las mascaras
        [mascaraCirc] = ...
                enmascararcirculo(imRGB,posCent(iFrame,:),radio(iFrame));
        [mascaraHSV,~] = ...
            clasificadorhsv(imRGB,posCent(iFrame,:), radio(iFrame));
        % Guardamos la imagen
        imwrite(mascaraHSV.*mascaraCirc,pathSalida);    
    end
    % Cambio en la barra de progreso
    waitbar((iFrame-frameIni)/(frameFin-frameIni)); 
end

disp(' ========== Enmascaramiento completo ==============')
close(barraWait);

%% ======================= Realce de Vasos ==========================
load(pathMetadatos);
barraWait = waitbar(0,'Realce de Vasos');
tic;
for iFrame = frameIni:frameFin
    pathSalida = fullfile(folderName,sprintf('Vasos_%i.jpg',iFrame)); 
    if(frameSelected(iFrame,4) == 1)
        % Lectura de imagen
        pathmascara = fullfile(folderName,...
            sprintf('MascaraHSV_%i.jpg',iFrame));
        pathImagen = fullfile(folderName,...
            sprintf('ImagenModif_%i.jpg',iFrame));
        imRGB = im2double(imread(pathImagen));
        mascaraNoBinaria = im2double(imread(pathmascara));
        mascaraBinaria = ...
            clasificadorhsv(imRGB,posCent(iFrame,:), radio(iFrame));
        
        [imModif] = ...
            resaltarvasos(imRGB,...
            posCent(iFrame,:),radio(iFrame));

        % Guardamos la imagen 
        imModif2 = imModif.*mascaraBinaria;
        CON_FONDO = 1;
        [imModif2, ~] = ...
            recortelupa(imModif2 ,...
            posCent(iFrame,:), radio(iFrame),CON_FONDO);
        
        % Normalizacion a valores de intensidad entre 0 y 1
        valorMax = max(imModif2(:));
        valorMin = min(imModif2(:));
        imModif2 = (imModif2-valorMin)./(valorMax-valorMin);

        imwrite(imModif2,pathSalida);
    end
    % Cambio en la barra de progreso
    waitbar((iFrame-frameIni)/(frameFin-frameIni)); 
end
toc;
disp(' =============  Realce de Vasos completado ===============')
close(barraWait);

 
%% Creacion de video apartir de imagenes

% Se contruye un objeto VideoWriter, 
% que crea un archivo AVI Motion-JPEG de forma predeterminada.

outputVideo = VideoWriter(fullfile(folderName,'videoSalida.avi'));
outputVideo.FrameRate = 2*frameRate;
open(outputVideo)
% Se recorre la secuencia de imágenes, cargue cada imagen y luego 
% escribirla en el vídeo.
iFrame = 1;
repetido = 1;
numRep = 3;
barraWait = waitbar(0,'Video de salida');
while(iFrame <= framesNo)
    if(frameSelected(iFrame,4)== 1)
        % Path de la imagen
        pathImagen = fullfile(folderName,...
            sprintf('ImagenModif_%i.jpg',iFrame));
        pathVasos = fullfile(folderName,...
            sprintf('Vasos_%i.jpg',iFrame));
        % Lectura de imagen
        imRGB = im2double(imread(pathImagen));
        imVasos = im2double(imread(pathVasos));
        imFinal = imRGB;
        imFinal(:,:,2) = imadjust(abs(imRGB(:,:,2)-imVasos));
        if(repetido == numRep)% Si ya se repitio
            iFrame = iFrame + 1;
            repetido = 1;
        else
            repetido = repetido + 1;
        end
    else
        pathImagen = fullfile(folderName,...
            sprintf('Image_%i.jpg',iFrame));
        iFrame = iFrame + 1;
        imRGB = im2double(imread(pathImagen));
        writeVideo(outputVideo,imRGB);
    end
    
    % Cambio en la barra de progreso
    waitbar(iFrame/framesNo)
    
end
close(barraWait);

% Finalizamos el archivo de vídeo.
close(outputVideo)

    
