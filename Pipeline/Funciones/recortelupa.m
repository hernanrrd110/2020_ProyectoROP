function [imCort, posiciones] = recortelupa(imRGB,posCent, radio,select)
%RECORTALUPA Recorta la imagen para contener solo la lupa
%   La funcion realiza un recorte de la imagen en la region de interes
%   Parametros:
%   - imRGB: imagen (double) en formato RGB
%   - posCent: vector 2x1 con valores de la posicion del centro en X y Y.
%   - radio: valor del radio de la circunferencia.
%   - select (opcional): parametro para hacer enmascaramiento adicional del
%   fondo.
%   Retornos:
%   - imCort: imagen recortada
%   - posiciones: vector 2x2, contiene las posiciones de la imagen
%   recortadas relativas a la imagen original. Los datos de la primera fila
%   corresponde a los valores en X y la segunda fila a los valores en Y.

%MACROS
SIN_FONDO = 0;
CON_FONDO = 1;

% Redondeo de valores 
posCent = round(posCent);
radio = round(radio);

[M,N,~] = size(imRGB);

% tolerancia del radio que ira variando a lo largo de las iteraciones
tolRadio = 20;
posY1 = posCent(2) - radio - tolRadio;
posY2 = posCent(2) + radio + tolRadio;
posX1 = posCent(1) - radio - tolRadio;
posX2 = posCent(1) + radio + tolRadio;

% Se va disminuyendo el numero de la tolerancia a medida que va iterando
while(0>=posY1)
    tolRadio = tolRadio - 1;
    posY1 = posCent(2) - radio - tolRadio;
end

tolRadio = 20;
while(posY2>M)
    tolRadio = tolRadio - 1;
    posY2 = posCent(2) + radio + tolRadio;
end

tolRadio = 20;
while(0>=posX1)
    tolRadio = tolRadio - 1;
    posX1 = posCent(1) - radio - tolRadio;
end

tolRadio = 20;
while(posX2>N)
    tolRadio = tolRadio - 1;
    posX2 = posCent(1) + radio + tolRadio;
end
posiciones = [posX1 posX2; posY1 posY2];
imCort = imRGB(posY1:posY2,posX1:posX2,:);

if(select == SIN_FONDO)
    for iFilas = 1:size(imCort,1)
        for jColum = 1:size(imCort,2)
            % Ecuacion de circunferencia
            if( ( iFilas +posY1 -1 -posCent(2) )^2 + ...
                    ( jColum +posX1 -1 -posCent(1) )^2 > (radio*0.95)^2)
                imCort(iFilas,jColum,:) = 0;
            end
        end
    end
end


end

