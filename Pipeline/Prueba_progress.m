clear all; close all; clc;
frameIni = 3;
frameFin = 10;
fprintf('Prueba\n');
dispprogress();
for iFrame = frameIni:frameFin
    dispprogress(iFrame-frameIni, frameFin-frameIni);
end