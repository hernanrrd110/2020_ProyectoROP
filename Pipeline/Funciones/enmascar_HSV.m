function [mascara_HSV] = enmascar_HSV(im_HSV,tol,hsvVal)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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

end

