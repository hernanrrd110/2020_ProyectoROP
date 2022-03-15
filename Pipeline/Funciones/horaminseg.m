function [temp] = horaminseg()
%HORAMINSEG Hora, minuto, segundo de tiempo actual en string
%   Resultado la hora, minuto y segundo del tiempo actual en formato string

hora = hour(datetime()); 
minuto = minute(datetime()); 
segundo = second(datetime());
% Conversion a formato duration de matlab
dur = duration(hora, minuto, segundo);
% Conversion a string
temp = string(dur);

end

