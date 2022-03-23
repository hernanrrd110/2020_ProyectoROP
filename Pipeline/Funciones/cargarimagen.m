function [imRGB,imGray] = cargarimagen(file)
%CARGA DE IMAGEN Lectura de imagen desde un archivo 
%   Si se pasa el argumento file, abre el archivo de imagen y devuelve la
%   imagen en RGB y (opcional) en escala de grises. 
%   Si no se pasa argumento, brinda una interfaz para elegir el archivo de 
%   donde se obtiene la imagen. Mismo output.
%   Parametros:
%   - file (opcional): nombre del archivo o ruta completa del archivo
%   Retornos:
%   - imRGB: imagen leida directamente del archivo (generalmente en RGB)
%   - imGray (opcional): imagen conve rtida a escala de grises
% -------------------------------
    if (nargin == 0) % no se pasa el nombre del archivo por imagen
        [filename, path] = uigetfile ({'*.jpg;*.tif;*.png;*.gif',...
            'All Image Files';'*.*','All Files'},...
            'Seleccione la imagen');
        if(filename == 0)
            fprintf('No se selecciono archivo\n')
            return;
        else
            fprintf('Archivo Seleccionado:\n ')
            disp(filename);
            fprintf('Path:\n ')
            disp(strcat(path,filename));
            imRGB = im2double(imread(strcat(path,filename)));
            
        end

        % Se da la direccion del archivo a abrir
    else
        [path,name,ext] = fileparts(file);
        fprintf('======= Carga de Imagen ======= \n ');
        fprintf('-- Imagen Seleccionado:\n ')
        disp(strcat(name,ext));
        fprintf('Path:\n ')
        if(size(path) == 0)
            which(strcat(name,ext))
        else
            disp(path);
        end
        imRGB = im2double(imread(file));
    end
    
    % Argumento de salida opcional
    switch nargout
        case 2
            if( size(imRGB,3) == 3 )
                % Convierte la imagen original RGB en escala de grises
                imGray = im2double(rgb2gray(imRGB));
            else
                % En el caso de que la imagen original este en escala de
                % grises, las dos imagenes quedan iguales
                imGray = imRGB;
            end
    end
    
end

