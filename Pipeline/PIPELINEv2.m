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
[vidObj, framesNo] = cargarvideo('ID_68_VIDEO.mp4');
% --- Interfaz de usuario para elegir la carpeta de destino 
% folderName = ...
%     uigetdir('Introducir carperta de destino de extraccion de cuadros'); 
folderName = ...
    'D:\GitHub Repositorio\2020_ProyectoROP\Pipeline\Frames_Videos\Prueba';
fprintf('Direccion de frames seleccionada\n');
fprintf('%s\n', folderName);

frameIni = 1;
frameFin = 200;
factorEscala = [1080 1920];

pathMetadatos = fullfile(folderName,'metadatos.mat');
%% ======================= Extraccion de frames =========================
warning('off');
barraWait = waitbar(0,'Deteccion Lupa');
% Si el video tiene 60 fps, submuestramos a 30 fps 
if (vidObj.FrameRate == 60)
    select = SUBMUESTREO;
else
    select = SIN_SUBMUESTREO;
end
extraerframes(vidObj,...
    frameIni,frameFin,folderName,factorEscala,select)
load(pathMetadatos);

% Se extrae frameSelected de metadatos, un array que indica los frames que
% se seleccionaron para el procesamiento

%% =========================== Detector lupa ============================
warning('off');
barraWait = waitbar(0,'Deteccion Lupa');

% Seleccion de frames correspondientes a la segunda etapa
% Si no detecta lupa, no se toma en cuenta el frame
frameSelected(:,2) = frameSelected(:,1);
posCent = zeros(framesNo, 2); % Vector para la posicion del centro
radio = zeros(framesNo,1); % Vector para el radio de la circunferencia

tic;
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
        else
            % Si no se detecta el cuadro, no se selecciona
            frameSelected(iFrame,2) = 0;
        end
        
    end
    waitbar((iFrame-frameIni)/(frameFin-frameIni));
end
toc;

disp(' ============== Deteccion de Lupa completo ==================')
close(barraWait);
save(pathMetadatos,'frameSelected','posCent','radio','-append');

%% ======================== Clasificacion HSV ===========================
load(pathMetadatos);
% -- DECLARACION MACROS
SIN_ENTRADA_MOUSE = 0;
ENTRADA_MOUSE = 1;

% Declaracion para vector con puntajes HSV
etapas.clasHSV = zeros(size(frameSelected(1)));

barraWait = waitbar(0,'Clasificacion HSV');
for iFrame = frameIni:frameFin
    if(frameSelected(iFrame,2) == 1) % Si el frame fue seleccionado
        pathLupa = fullfile(folderName,sprintf('Lupa_%i.jpg',iFrame));
        % Cargar imagen de la mascara de la lupa
        imRGB = im2double(imread(pathLupa));
        % Extreaemos las mascaras y el puntaje
        [mascaraHSV,etapas.clasHSV(iFrame)] = ...
            clasificadorhsv(imRGB,SIN_ENTRADA_MOUSE);
        pathMascara = fullfile(folderName,...
            sprintf('MascaraHSV_%i.jpg',iFrame));
        if(~isfile(pathMascara))
            % Guardamos la imagen
            imwrite(mascaraHSV,pathMascara);
        end
    end % ======
    waitbar((iFrame-frameIni)/(frameFin-frameIni));
end
disp(' ============== Clasificacion HSV completa ==================')
close(barraWait);

save(pathMetadatos, 'etapas.clasHSV','-append');

%% ===================== Clasificacion frecuencial =======================

% ------- Struct para etapas de procesamiento
% Energy of laplacian (Subbarao92a)
etapas.FrecLap.LAPE = zeros(size(frameSelected(1)));
% Modified Laplacian (Nayar89)
etapas.FrecLap.LAPM = zeros(size(frameSelected(1)));
% Variance of laplacian (Pech2000)
etapas.FrecLap.LAPD = zeros(size(frameSelected(1)));
% Metodo gaussiano implementado como Estrada 2011
etapas.FrecGauss = zeros(size(frameSelected(1)));

barraWait = waitbar(0,'Clasificación frecuencial');

for iFrame = frameIni:frameFin
    % Si el frame esta seleccionado de la etapa anterior
    if(frameSelected(iFrame,2) == 1) 
        pathLupa = fullfile(folderName,sprintf('Lupa_%i.jpg',iFrame));
        imRGB = imread(pathLupa);
        imGray = im2double(rgb2gray(imRGB));
        % puntaje por LAPLACE
        [etapas.FrecLap.LAPE(iFrame)] = ... 
            fmeasure(imGray, 'LAPE');
        [etapas.FrecLap.LAPM(iFrame)] = ...
            fmeasure(imGray, 'LAPM');
        [etapas.FrecLap.LAPD(iFrame)] = ...
            fmeasure(imGray, 'LAPD');
        % Puntaje por Gauss
        [etapas.FrecGauss(iFrame)] = ...
            clasificadorfrec(imGray, 'gaussiano');
        % Cambio en la barra de progreso
        waitbar((iFrame-frameIni)/(frameFin-frameIni)); 
    end 

end

disp(' ========== Clasificacion frecuencial completa ==============')
close(barraWait);
save(pathMetadatos, 'etapas.FrecLap','-append');

%% ======================= Remocion artefactos ========================== 
% En esta parte se eliminan las partes de la imagen que eran por demás
% brillosas
load(pathMetadatos);
barraWait = waitbar(0,'Remocion de artefactos');
for iFrame = frameIni:frameFin
    pathSalida = fullfile(folderName,sprintf('ImagenModif_%i.jpg',iFrame)); 
    if(frameSelected(iFrame,2) == 1)
        % Lectura de imagen
        pathImagen = fullfile(folderName,sprintf('Image_%i.jpg',iFrame));
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

%% ======================= Realce de Vasos ==========================
load(pathMetadatos);
barraWait = waitbar(0,'Realce de Vasos');
for iFrame = frameIni:frameFin
    pathSalida = fullfile(folderName,sprintf('Vasos_%i.jpg',iFrame)); 
    if(frameSelected(iFrame,2) == 1 && ~isfile(pathSalida))
        % Lectura de imagen
        pathImagen = fullfile(folderName,...
            sprintf('ImagenModif_%i.jpg',iFrame));
        imRGB = imread(pathImagen);
        % Removemos los artefactos de la imagen 
        [imModif] = resaltarvasos(imRGB);
        % Guardamos la imagen
        imwrite(imModif,pathSalida);    
    end
    % Cambio en la barra de progreso
    waitbar((iFrame-frameIni)/(frameFin-frameIni)); 
end

disp(' =============  Realce de Vasos completado ===============')
close(barraWait);

%% Mostramos los valores frecuenciales en formato tabla
close all;
vectorFrames = (frameIni:frameFin)';
% Declaracion de la tabla de valores con puntaje frecuencial
tablaFrecuencial = table(vectorFrames,...
    etapas.FrecLap.LAPE(frameIni:frameFin),...
    etapas.FrecLap.LAPM(frameIni:frameFin),...
    etapas.FrecLap.LAPD(frameIni:frameFin),...
    etapas.FrecGauss(frameIni:frameFin),...
    etapas.FrecCuadrada(frameIni:frameFin));

% Nombres de la columnas de la tabla
tablaFrecuencial.Properties.VariableNames = ...
    {'N_frame','LAPE','LAPM','LAPD','Gauss','Cuadrada'};

% Se crea un archivo de planilla para la tabla de frecuencias
writetable(tablaFrecuencial,fullfile(folderName,'tablaFrecuencias.xlsx'));

% Obtenemos la resolucion de pantalla
screenReso = get(0,'screensize'); 

% Figura de la tabla
fTablaFrec = figure('Name', 'Tabla de puntajes frecuenciales');
uiTablaFrec = uitable(fTablaFrec);
uiTablaFrec.Data = table2array(tablaFrecuencial);
uiTablaFrec.ColumnName = tablaFrecuencial.Properties.VariableNames;

% Configuramos la posicion de la figura y la tabla
set(gcf,'OuterPosition',[0 0 ...
    screenReso(3) screenReso(4)]);
set(uiTablaFrec,'OuterPosition',[screenReso(3)*0.05 screenReso(4)*0.05 ...
    screenReso(3)*0.9 screenReso(4)*0.83]);

figure('Name', 'Valores de puntaje Frecuencial');
subplot 221; 
plot(vectorFrames,etapas.FrecLap.LAPE(frameIni:frameFin));
title 'LAPE'
subplot 222;
plot(vectorFrames,etapas.FrecLap.LAPM(frameIni:frameFin));
title 'LAPM'
subplot 223;
plot(vectorFrames,etapas.FrecLap.LAPD(frameIni:frameFin));
title 'LAPD'

figure('Name', 'Valores de puntaje Frecuencial 2');
subplot 211; plot(vectorFrames,etapas.FrecGauss(frameIni:frameFin));
title 'Gauss';
subplot 212; plot(vectorFrames,etapas.FrecCuadrada(frameIni:frameFin));
title 'Cuadrada';

%% Tablas HSV
% Declaracion de la tabla de valores con puntaje frecuencial
tablaHSV = table(vectorFrames,...
    etapas.clasHSV(frameIni:frameFin));

% Nombres de la columnas de la tabla
tablaHSV.Properties.VariableNames = ...
    {'N_frame','HSV'};

% Se crea un archivo de planilla para la tabla de frecuencias
writetable(tablaHSV,fullfile(folderName,'tablaHSV.xlsx'));

% Figura de la tabla
fTablaHSV = figure();
uiTablaHSV = uitable(fTablaHSV);
uiTablaHSV.Data = table2array(tablaHSV);
uiTablaHSV.ColumnName = tablaHSV.Properties.VariableNames;

% Configuramos la posicion de la figura y la tabla
set(gcf,'OuterPosition',[0 0 ...
    screenReso(3) screenReso(4)]);
set(uiTablaHSV,'OuterPosition',[screenReso(3)*0.05 screenReso(4)*0.05 ...
    screenReso(3)*0.9 screenReso(4)*0.83]);

figure('Name', 'Valores de clasificacion HSV');
plot(vectorFrames,etapas.clasHSV(frameIni:frameFin));
title 'HSV 1';

    
