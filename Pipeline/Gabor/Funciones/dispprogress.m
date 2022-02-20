
function dispprogress(valorActual, valorMax)
% funcion para displegar el nivel de carga segun valores dados
% Parametros:
% - valorActual: valor de progreso absoluto
% - valorMax: valor maximo que puede alcanzar la variables actual. valor de
%       referencia
% - pAnterior: valor de porcentaje anterior. Si esta vacío, se toma la
%       primera vez
% Salida:
% - pFinal: valor de porcentaje hecho

persistent pAnterior; % variable persistente del porcentaje anterior
% Es necesario inicializar la funcion sin parametros para inicializar las
% variables
if (nargin == 0) 
  pAnterior = [];
  return;
end

% Valor de porcentaje actual, con una sola cifra significativa
pDone = round(valorActual/valorMax*100,1,'significant');
% Si el porcentaje calculado es igual al anterior, retorna la funcion
if (pDone == pAnterior)
    return;
end
% Borra lo escrito anteriormente para volver a desplegar la barra de carga    
if (~isempty(pAnterior))
  fprintf(1, '%s\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b', '');
end

pAnterior = pDone;
switch (pDone)
  case 0
    fprintf(1, '%s', '[          ] 0%  ');
  case 10
    fprintf(1, '%s', '[|         ] 10% ');
  case 20
    fprintf(1, '%s', '[||        ] 20% ');
  case 30
    fprintf(1, '%s', '[|||       ] 30% ');
  case 40
    fprintf(1, '%s', '[||||      ] 40% ');
  case 50
    fprintf(1, '%s', '[|||||     ] 50% ');
  case 60
    fprintf(1, '%s', '[||||||    ] 60% ');
  case 70
    fprintf(1, '%s', '[|||||||   ] 70% ');
  case 80
    fprintf(1, '%s', '[||||||||  ] 80% ');
  case 90
    fprintf(1, '%s', '[||||||||| ] 90% ');
  case 100
    fprintf(1, '%s\n', '[||||||||||] 100% ');
end
drawnow;

