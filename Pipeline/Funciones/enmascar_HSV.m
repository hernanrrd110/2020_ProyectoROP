function [mascara_HSV, contador_pix] = enmascar_HSV(im_HSV,tol,hsvVal)
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
    diffH = abs(im_HSV(:,:,1) - hsvVal(1));
    diffS = abs(im_HSV(:,:,2) - hsvVal(2));
    diffV = abs(im_HSV(:,:,3) - hsvVal(3));
    
    [M,N,t] = size(im_HSV); 
    % Matrices para ser rellenadas con 1
    I1 = zeros(M,N); I2 = zeros(M,N); I3 = zeros(M,N);

    % Debido a los valores ciclicos del valor de tonalidad (H), 
    % es necesario evaluar los extremos 
    if ( (hsvVal(1)+tol(1))>1 )
    for i=1:M
        for j=1:N
           if( (0<=im_HSV(i,j,1)) && (im_HSV(i,j,1)<=(tol(1)+hsvVal(1)-1)) )
               I1(i,j)= 1;
           end
        end
    end    
    elseif ( (hsvVal(1)-tol(1))<0 )
    for i=1:M
        for j=1:N
           if( (1+hsvVal(1)-tol(1))<=im_HSV(i,j,1) && im_HSV(i,j,1)<=1 )
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
    
   
    mascara_HSV = I1.*I2.*I3;
    contador_pix = 0;
    for i=1:M
        for j=1:N
            if (mascara_HSV(i,j) == 1)
                contador_pix = contador_pix + 1;
            end
        end
    end
end

