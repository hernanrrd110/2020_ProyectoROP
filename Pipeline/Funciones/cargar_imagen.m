function [imagen,M,N,t] = cargar_imagen()
%CARGA DE IMAGEN
%   Encuentra el archivo y devuelve la matriz imagen en RGB o escala gris
%  junto con el tamanio de la imagen
% -------------------------------
    [filename, path] = uigetfile ({'*.jpg;*.tif;*.png;*.gif',...
        'All Image Files';'*.*','All Files'},...
        'Seleccione la imagen a analizar');
    if(filename == 0)
        fprintf('No se selecciono archivo\n')
        return;
    else
        fprintf('Archivo Seleccionado:\n ')
        disp(strcat(path,filename));
        imagen = imread(strcat(path,filename));
        [M,N,t] = size(imagen); % Dimensiones de la imagen originales
    end
end

