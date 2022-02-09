function [] = extraerframes(vidObj,...
    frameIni,frameFin,folderFrames,resolucionSalida,select)
%EXTRAERFRAMES extraer frames desde los limites dados con factor de escala
%con o sin submuestreo.
% Parametros:
% - frameIni: numero de inicio de cuadro inicial de extraccion
% - frameFin: numero de fin de cuadro final de extraccion
% - folderFrames: carpeta de destino de los cuadros extraidos
% - resolucion: Parametro para la resolucion o el factor de escala 
% - select: parametro de seleccion para bajar la tasa de extraccion a la
% mitad.
% ========================================================================
% MACROS
SIN_SUBMUESTREO = 0;
SUBMUESTREO = 1;

% Dependiendo de los parametros opcionales
if (nargin == 4)
    resolucionSalida = 1;
    select = SIN_SUBMUESTRO;
end
if (nargin == 5)
    select = SIN_SUBMUESTRO;
end

% Configurando el tiempo inicial del video
vidObj.CurrentTime = frameIni/vidObj.FrameRate;
% Se obtiene la ruta del video
[~,name,ext] = fileparts(vidObj.Path);

% Recorrido del video para extraccion de frames
iFrame = frameIni;
endTime = frameFin/vidObj.FrameRate; % Tiempo de finalizacion
barraWait = waitbar(0,'Extracción de Frames');

% Datos para guardar en metadatos
vidName = strcat(name,ext);
frameSelected = zeros(round(vidObj.Duration*vidObj.FrameRate),1,'logical');
frameRate = vidObj.FrameRate;

while vidObj.CurrentTime <= endTime % Inicio while 
    vidFrame = readFrame(vidObj);
    pathCompleto = fullfile(folderFrames,sprintf('Image_%i.jpg',iFrame));
    if (~isfile(pathCompleto)) % Inicio if 1 (Pregunta si no hay archivo)
        if (select == SUBMUESTREO) % Inicio if 2
            if (mod(iFrame,2)~= 0) % Inicio if 3
                % Solo se obtienen los frames impares
                % Se rescala la imagen segun el factor de escala
                vidFrame = imresize(vidFrame,resolucionSalida);
                imwrite(vidFrame,pathCompleto);
                frameSelected(iFrame) = 1;  
            end % Fin If 3
        elseif(select == SIN_SUBMUESTREO) % Inicio elseif 2
            vidFrame = imresize(vidFrame,resolucionSalida);
            imwrite(vidFrame,pathCompleto);
            frameSelected(iFrame) = 1;
        end % ====== Fin If 2
    else
        frameSelected(iFrame) = 1;
    end % Fin if 1
        iFrame = iFrame + 1;
        waitbar((iFrame-frameIni)/(frameFin-frameIni));
end % Fin while
close(barraWait);

% Guardado de metadatos
pathMetadatos = fullfile(folderFrames,'metadatos.mat');
save(pathMetadatos,'frameRate','vidName','frameSelected');

end

