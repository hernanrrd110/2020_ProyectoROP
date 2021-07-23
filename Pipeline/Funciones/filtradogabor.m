function [im_filtrada] = filtradogabor(imagen,uo,vo,phi,...
    K,a,b,theta,h_size)
%FILTRADO_GABOR Crea un kernel de gabor wavelet y convoluciona con imagen
%   Genera un kernel de gabor wavelet del tamanio de h_size. El kernel se 
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
rad = pi/180; % factor de conversion

% -- Parametros de envolvente gaussiana
theta = theta*rad; % angulo de rotacion en radianes
phi = phi * rad; % angulo de desfase en radianes
xo = floor(h_size(1)/2); yo = floor(h_size(2)/2); % posicion del centro

% Seno complejo
seno_comp = zeros(h_size);
for i = 1:h_size(1)
    for j = 1:h_size(2)
        seno_comp(i,j) = exp(1i*(2*pi*(uo*i+vo*j)+phi));
    end
end

% Envolvente gaussiana
wr = zeros(h_size);
for i = 1:h_size(1)
    for j = 1:h_size(2)
        xr = (i-xo)*cos(theta)+(j-yo)*sin(theta);
        yr = -(i-xo)*sin(theta)+(j-yo)*cos(theta);
        wr(i,j) = K * exp(-pi*((a*xr)^2+(b*yr)^2));
    end
end

filtro_gabor = seno_comp.*wr;
im_filtrada = imfilter(imagen, filtro_gabor);

end

