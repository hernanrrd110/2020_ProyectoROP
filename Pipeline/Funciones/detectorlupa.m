function [imCort, posCent, radio] = detectorlupa(imRGB,rangoRadios)
%DETECTORLUPA Detecta la lupa por Transformada Hough y luego la enmascara
%   * Parametros:
%   - imRGB: imagen RGB (double), valores entre [0 , 1].
%   - rangoRadios: vector 2x1 [radioMin radioMax]. Se especifica el radio
%   minimo de busqueda (radioMin) y el radio maximo de busqueda (radioMax).
%   * Salidas:
%   - imCort: imagen RGB (double) con mascara no binaria que cubre la 
%     imagen por fuera de la circunferencia.
%   - posCent: 2x1 double con las posiciones del centro de la
%     circunferencia.
%   - radio: (double) radio de la circunferencia.

    % Conversion valores RGB a HSV
    imHSV = rgb2hsv(imRGB);
    % Creacion mascara binaria
    [imFilt] = crearmascaralupa(imHSV);
    imFilt = double(imFilt);
    [M,~,~] = size(imRGB);
    
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
    
    if(nargin == 1)
        % Intervalo de radio del circulo a detectar
        rangoRadio1 = round(M/3);
        rangoRadio2 = round(M/2.2);
    elseif(nargin == 2)
        rangoRadio1 = rangoRadios(1);
        rangoRadio2 = rangoRadios(2);
    end
    [posCent, radio, metric] = imfindcircles(imFilt,[rangoRadio1 rangoRadio2],...
        'Sensitivity',0.98,'Method','TwoStage');

    % Anular valores de la imagen fuera de la circunferencia detectada
    % Imagen original enmascarada
    imCort = imRGB;
    
    % Si se encuentra circulo
    if(~isempty(posCent))
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
    else
        imCort = [];
    end
end

