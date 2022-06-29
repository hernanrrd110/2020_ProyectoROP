function [vidObj,framesNo] = ...
    cargarvideo(pathVideo)
%CARGARVIDEO Crea objeto de video con la ruta especificada
%   La funcion CARGAR VIDEO provee de alternativas para crear el objeto de
%   VideoReader asociado a una ruta y puede proveer una interfaz de usuario
%   para buscar un video en espcifico, y despliega informacion en consola
%   Parametros:
%   - pathVideo(opcional): ruta del video a buscar. Si no se especifica,
%   brinda una interfaz de usuario para la seleccion del video
%   Retornos:
%   - vidObj: objeto de clase VideoReader de la ruta especificada
%   - framesNo: numero de cuadros totales que tiene el video
%   =======================================================================

    if (nargin == 0) % Si no se pasa ruta
        [filename, path] = uigetfile ({'*.mp4;*.mov;*.avi;*.mkv;*.',...
            'All Video Files';'*.*','All Files'},...
            'Seleccione el video a extraer');
        fprintf('Video Seleccionado:\n ')
        if (filename ~= 0)
            disp(filename);
            fprintf('Path:\n ')
            pathVideo = strcat(path,filename);
            disp(pathVideo);
        else 
            fprintf('No se seleccionó video \n ')
            return;
        end
        
    elseif (nargin == 1)
        [path,name,ext] = fileparts(pathVideo);
        filename = sprintf('%s%s',name,ext);
        fprintf('======= Carga de Video ======= \n');
        fprintf(' -- Video Seleccionado: \n ');
        fprintf('%s\n',filename);
        fprintf(' -- Path:\n ');
        if (size(path) == 0)
            which(filename);
        else
            disp(path);
        end
    end
    % Declaracion del objeto para manejar el video
    vidObj = VideoReader(pathVideo);
    framesNo = floor(vidObj.Duration*vidObj.FrameRate);

end

