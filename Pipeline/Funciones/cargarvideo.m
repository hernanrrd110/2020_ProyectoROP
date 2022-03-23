function [vidObj,framesNo] = ...
    cargarvideo(pathVideo)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    % Declaracion del objeto para manejar el video
    if (nargin == 0)
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
        fprintf('======= Carga de Video ======= \n ');
        fprintf('-- Video Seleccionado: \n ');
        fprintf('%s\n',filename);
        fprintf('-- Path:\n ');
        if (size(path) == 0)
            which(filename);
        else
            disp(path);
        end
    end
    % Declaracion del objeto para manejar el video
    vidObj = VideoReader(pathVideo);
    framesNo = round(vidObj.Duration*vidObj.FrameRate);

end

