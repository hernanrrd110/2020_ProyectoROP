function [EspacioHSV, EspacioHSV_marcado] = ...
    mostrarespaciohsv(im_HSV,tol,hsvVal)
% Mostrar_espacioHSV
%
% Para la graficacion del espacio, se hace en primer lugar un reshape de
% para pasar los valores matriciales de la imagen en un vector, luego para
% disminuir los datos a graficar se utiliza la funcion unique de forma de
% eliminar valores repetidos. El parametro rows es necesario para tomar a
% cada fila del vector como una entidad a comparar
    % Tamanio de imagen
    [M,N,t] = size(im_HSV);
    % Espacio de toda la imagen
    EspacioHSV = unique( reshape( im_HSV,M*N,3 ) ,'rows' );
    % Espacio de los pixeles marcados, es decir los pixeles tomados  
    % como de la retina
    EspacioHSV_marcado = zeros(size(EspacioHSV));
    % Diferencias absolutas
    diffH_marc = abs(EspacioHSV(:,1) - hsvVal(1));
    diffS_marc = abs(EspacioHSV(:,2) - hsvVal(2));
    diffV_marc = abs(EspacioHSV(:,3) - hsvVal(3));

    j = 1; %contador auxiliar
    for i=1:length(EspacioHSV)
        if (diffS_marc(i) <= tol(2) && diffV_marc(i) <= tol(3))
            if(diffH_marc(i) <= tol(1))
                EspacioHSV_marcado(j,:) = EspacioHSV(i,:);
                j = j + 1;
            elseif (0<=EspacioHSV(i,1)) && ...
                    (EspacioHSV(i,1)<=(tol(1)+hsvVal(1)-1))
                EspacioHSV_marcado(j,:) = EspacioHSV(i,:);
                j = j + 1;
            elseif  ((1+hsvVal(1)-tol(1))<=EspacioHSV(i,1)...
                    && EspacioHSV(i,1)<=1)
                EspacioHSV_marcado(j,:) = EspacioHSV(i,:);
                j = j + 1;
            end
        end
    end
    
    % Recorte
    EspacioHSV_marcado = EspacioHSV_marcado(1:j,:);

end

