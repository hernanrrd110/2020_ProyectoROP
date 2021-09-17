function [mascaraHSV,puntajeHSV] = clasificadorhsv(imRGB,select)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    % DECLARACION MACROS
    SIN_ENTRADA_MOUSE = 0;
    ENTRADA_MOUSE = 1;

    % Conversion a valores HSV
    imHSV = im2double(rgb2hsv(imRGB));
    switch select
        case ENTRADA_MOUSE
            % Abre una imagen para seleccionar el pixel con los valores
            figure('Name','Imagen Original (seleccion de pixel)');
            imshow(imRGB); title('Imagen RGB original')
            % Entrada de mouse del pixel a elegir
            numPuntos = 1;
            [xPos,yPos] = ginput(numPuntos);
            % Valor de HSV elegido para ser comparado
            hsvVal = imHSV(round(yPos),round(xPos),:);
            hsvVal = reshape(hsvVal,1,3);
            tol = [0.4 0.3 0.3];
            [mascaraHSV, puntajeHSV] = enmascarhsv(imHSV,tol,hsvVal);
        case SIN_ENTRADA_MOUSE
            [mascaraHSV, puntajeHSV] = enmascarhsv(imHSV);
    end
end

