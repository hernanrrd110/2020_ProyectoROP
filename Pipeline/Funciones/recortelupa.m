function [imCort, posiciones] = recortelupa(imRGB,posCent, radio,select)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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
    for iFilas = 1:M
        for jColum = 1:N
            % Ecuacion de circunferencia
            if( ( iFilas-posCent(2) )^2 + ...
                    ( jColum-posCent(1) )^2 > (radio*0.95)^2)
                imCort(iFilas,jColum,:) = 0;
            end
        end
    end
end


end

