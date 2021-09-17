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
        disp(filename);
        fprintf('Path:\n ')
        pathVideo = strcat(path,filename);
        disp(pathVideo);
        
    elseif (nargin == 1)
        [~,name,ext] = fileparts(pathVideo);
        fprintf('Video Seleccionado: \n ');
        fprintf('%s',name); fprintf('.%s\n',ext);
        fprintf('Path:\n ');
        which(file);
    end
    % Declaracion del objeto para manejar el video
    vidObj = VideoReader(pathVideo);
    framesNo = round(vidObj.Duration*vidObj.FrameRate);
    
end

