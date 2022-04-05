function [frameFinExtraido] = extraerframes(vidObj,...
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
barraWait = waitbar(0,'Extracción de Frames');

% Datos para guardar en metadatos
vidName = strcat(name,ext);
frameRate = vidObj.FrameRate;
frameSelected = zeros(round(vidObj.Duration*frameRate),1,'logical');

for iFrame = frameIni:frameFin
    if (hasFrame(vidObj))
        vidFrame = readFrame(vidObj);
        pathCompleto = fullfile(folderFrames,...
            sprintf('Image_%i.jpg',iFrame));
        % Caso de submuestro
        if (select == SUBMUESTREO && ( mod(iFrame,2)~= 0) )
            % Solo se seleccionan los frames impares
            frameSelected(iFrame) = 1;
            % Caso sin submuestro
        elseif(select == SIN_SUBMUESTREO)
            frameSelected(iFrame) = 1;
        end
        % En caso de que el archivo ya exista, no escribir
        if (~isfile(pathCompleto))
            vidFrame = imresize(vidFrame,resolucionSalida);
            imwrite(vidFrame,pathCompleto);
        end
    end
    waitbar((iFrame-frameIni)/(frameFin-frameIni));
end % Fin for

close(barraWait);
frameFinExtraido = iFrame;
% Guardado de metadatos
pathMetadatos = fullfile(folderFrames,'metadatos.mat');
if(exist(pathMetadatos,'file') == 0)
    save(pathMetadatos,'frameRate','vidName','frameSelected');
end

end

