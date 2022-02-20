function [imFiltrada] = filtradogabor(imagen,uo,vo,phi,...
    K,a,b,theta,hSize)
%FILTRADO_GABOR Crea un kernel de gabor wavelet y convoluciona con imagen
%   Genera un kernel de gabor wavelet del tamanio de hsize. El kernel se 
% obtiene de la multiplicacion de una funcion senoidal compleja con una 
% envolvente gaussiana.
% Parametros:
% - uo: frecuencia espacial senoidal en direccion de x
% - vo: frecuancia espacial senoidal en direccion de y
% - phi: angulo de desfase de funcion senoidal en grados
% - K: factor de escala de envolvente gaussiana
% - a: factor de escala de envolvente en eje x
% - b: factor de escala de envolvente en eje y
% - theta: angulo de rotacion de envolvente en grados
% - xo: posicion en x de centro de pico de envolvente gaussiana
% - yo: posicion en y de centro de pico de envolvente gaussiana

% Declaracion de vectores y parametros
DEG2RAD = pi/180; % factor de conversion

% -- Parametros de envolvente gaussiana
theta = theta*DEG2RAD; % angulo de rotacion en radianes
phi = phi * DEG2RAD; % angulo de desfase en radianes
xo = floor(hSize(2)/2); yo = floor(hSize(1)/2); % posicion del centro

% Seno complejo
senComp = zeros(hSize);
for iFilas = 1:hSize(1)
    for jColum = 1:hSize(2)
        senComp(iFilas,jColum) = exp(1i*(2*pi*(uo*iFilas+vo*jColum)+phi));
    end
end

% Envolvente gaussiana
wr = zeros(hSize);
for iFilas = 1:hSize(1)
    for jColum = 1:hSize(2)
        xr = (jColum-xo)*cos(theta)+(iFilas-yo)*sin(theta);
        yr = -(jColum-xo)*sin(theta)+(iFilas-yo)*cos(theta);
        wr(iFilas,jColum) = K * exp(-pi*((a*xr)^2+(b*yr)^2));
    end
end

filtroGabor = real(senComp.*wr);
imFiltrada = imfilter(imagen, filtroGabor);

end

