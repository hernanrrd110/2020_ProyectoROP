function [mascara_HSV, puntajeHSV] = enmascarhsv(imHSV,tol,hsvVal)
%ENMASCAR_HSV Enmascarado imagen segun el valor de hsv y tolerancia dado.
%   Establece un conjunto de valores de HSV de la imagen segun los
%   parametros dados y crea una mascara binaria para los pixeles que
%   cumplen con la clasificacion. Tambien presenta un contador de los
%   numero de pixeles clasificados.
%   ---- Parametros:
%   im_HSV: imagen de M x N x 3 con valores entre 0 y 1 de HSV
%   tol: vector con valores de tolerancia en H, S y V
%   hsvVal: vector de 1x3 con los valores de HSV a comparar
    % Diferencias absolutas entre valores de cada pixel y el valor elegido
    [M,N,t] = size(imHSV); 
    
    if (nargin == 3)
        diffH = abs(imHSV(:,:,1) - hsvVal(1));
        diffS = abs(imHSV(:,:,2) - hsvVal(2));
        diffV = abs(imHSV(:,:,3) - hsvVal(3));
        
        % Matrices para ser rellenadas con 1
        I1 = zeros(M,N); I2 = zeros(M,N); I3 = zeros(M,N);

        % Debido a los valores ciclicos del valor de tonalidad (H), 
        % es necesario evaluar los extremos 
        if ( (hsvVal(1)+tol(1))>1 )
            for i=1:M
                for j=1:N
                   if( (0<=imHSV(i,j,1)) &&...
                           (imHSV(i,j,1)<=(tol(1)+hsvVal(1)-1)) )
                       I1(i,j)= 1;
                   end
                end
            end    
            elseif ( (hsvVal(1)-tol(1))<0 )
            for i=1:M
                for j=1:N
                   if( (1+hsvVal(1)-tol(1))<=imHSV(i,j,1) &&...
                           imHSV(i,j,1)<=1 )
                       I1(i,j)= 1;
                   end
                end
            end
        end

        % Rellenando las máscaras binarios con 1 en donde la diferencia  
        % absoluta es menor a la tolerancia
        I1(diffH <= tol(1)) = 1;
        I2(diffS <= tol(2)) = 1;
        I3(diffV <= tol(3)) = 1;
        
        % creacion de las mascaras
        mascara_HSV = I1.*I2.*I3;
        
    else     
        % Define thresholds for channel 1 based on histogram settings
        channel1Min = 0;
        channel1Max = 0.160;

        % Define thresholds for channel 2 based on histogram settings
        channel2Min = 0.472;
        channel2Max = 1.000;

        % Define thresholds for channel 3 based on histogram settings
        channel3Min = 0.446;
        channel3Max = 1.000;

        % Create mask based on chosen histogram thresholds
        sliderBW = ...
            ((imHSV(:,:,1) >= channel1Min) & ...
            (imHSV(:,:,1) <= channel1Max) ) & ...
            (imHSV(:,:,2) >= channel2Min ) & ...
            (imHSV(:,:,2) <= channel2Max) & ...
            (imHSV(:,:,3) >= channel3Min ) & ...
            (imHSV(:,:,3) <= channel3Max);
        mascara_HSV = double(sliderBW);
        % Initialize output masked image based on input image.
        % mascara_HSV = imRGB;

        % Set background pixels where BW is false to zero.
        % mascara_HSV(repmat(~BW,[1 1 3])) = 0;
    end
    contador_pix = 0;
    
    for i=1:M
        for j=1:N
            if (mascara_HSV(i,j) == 1)
                contador_pix = contador_pix + 1;
            end
        end
    end
    
    % Conformacion del puntaje HSV por proporcion 
    % de los pixeles retinianos
    puntajeHSV = contador_pix/(M*N);
    
end

