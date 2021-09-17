function [imCort, posCent, radio] = detectorlupa(imRGB)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    % Conversion valores RGB a HSV
    imHSV = rgb2hsv(imRGB);
    % Creacion mascara binaria
    [imFilt] = crearmascaralupa(imHSV);
    imFilt = double(imFilt);
    [M,N,t] = size(imRGB);
    
    % Etapa de deconvolucion
    % Funcion Dispersion de Puntos modelado mediante Gaussiana
    % PSF por siglas en ingles
    PSF = fspecial('gaussian',7,7);
    iter = 5; % iteraciones del filtrado
    % Deconvolucion  Lucy-Richardson
    imFilt = deconvlucy(imFilt,PSF,iter);

    % === Filtrado y deteccion de la circunferencia
    % Filtrado pasaalto para acentuar bordes canny o sobel
    umbral = 0.2; %valor original 0.06
    imFilt = edge(imFilt,'sobel',umbral);

    % Intervalo de radio del circulo a detectar
    rangoRadio1 = round(M/3);
    rangoRadio2 = round(M/2.2);
    [posCent, radio] = imfindcircles(imFilt,[rangoRadio1 rangoRadio2],...
        'Sensitivity',0.98,'Method','twostage');

    % Anular valores de la imagen fuera de la circunferencia detectada
    % Imagen original enmascarada
    imCort = imRGB;
    
    % Nos quedamos con la primer circunferencia detectada
    posCent = posCent(1,:);
    radio = radio(1,:);

    for iFilas = 1:size(imRGB,1)
        for jColum = 1:size(imRGB,2)
            % Ecuacion de circunferencia
            if((iFilas-posCent(2))^2+...
                    (jColum-posCent(1))^2 > (radio*0.95)^2)
                imCort(iFilas,jColum,:) = 0;
            end
        end
    end
    
end

