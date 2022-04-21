clear all; close all; clc;
% Prueba de SURF
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_69'; extVid = '.mp4';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 165;
frame2 = 819;

% Carga de imagenes
[~,imGray1] = cargarimagen( fullfile(folderMosaico,...
    sprintf('Vasos_%i.jpg',frame1) ) );
[~,imGray2] = cargarimagen( fullfile(folderMosaico,...
    sprintf('Vasos_%i.jpg',frame2) ) );

% Carga de Mascaras
[~,imMasc1] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascVasos_%i.jpg',frame1) ) );
[~,imMasc2] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascVasos_%i.jpg',frame2) ) );

% Parametros
% Valores Decentes
% numOctaves = 3;
% metricThreshold = 1000;
% minContrast = 0.01;
% minQuality = 0.2;
% matchThreshold = [60 60];
% maxRatio = [0.5 0.7];
% metric = 'SSD';

% Excelentes resultados
% numOctaves = 3; %SURF
% metricThreshold = 1000; %SURF
% minContrast = 0.01; % BRISK
% minQuality = 0.2; % BRISK
% matchThreshold = [60 60]; %MATCHING
% maxRatio = [0.5 0.7]; %MATCHING
% metric = 'SAD';

%  - Fig 22: corr 0.4710
%   MaxRatio 0.7 0.8; Umbral Coinc 70 70 
%   NumOctavas 3; Umbral Metrica 500;
%   Min Contrast 0.01; Min Calidad 0.20; 

numOctaves = 3; %SURF
metricThreshold = 500; %SURF
minContrast = 0.01; % BRISK
minQuality = 0.2; % BRISK
matchThreshold = [70 70]; %MATCHING
maxRatio = [0.7 0.8]; %MATCHING
metric = 'SSD';

[~,~,tforms,mosRef] = mosaicomultidesc(imGray1,imGray2,...
    imMasc1,imMasc2,numOctaves,metricThreshold,...
    minContrast,minQuality,...
    matchThreshold,maxRatio,metric);

% imagenes transformadas para compararlas
imWarp1 = imwarp(imGray1, affine2d(eye(3)), ...
    'OutputView', mosRef);
imWarp2 = imwarp(imGray2, tforms, ...
    'OutputView', mosRef);

f = figure(); imshowpair(imWarp1, imWarp2);
%%
% Nonrigid registration
[displacementField,imWarp2Mod] = ...
    imregdemons(imWarp2,imWarp1,1000,...
    'AccumulatedFieldSmoothing',1.0,'PyramidLevels',2);

f = figure(); imshowpair(imWarp1, imWarp2Mod);

%%
imMasc2Mod = imWarp2Mod;
imMasc2Mod(imMasc2Mod >0) = 1;
se = strel('disk',10);
imMasc2Mod = imclose(imMasc2Mod,se);
imMasc1Mod = imwarp(imMasc1, affine2d(eye(3)),...
    'OutputView', mosRef);

% Initialize the "empty" panorama.
% mosaic = zeros(mosRef.ImageSize, 'like', imGray1);
mosaic = imWarp1;
restaMasc = imMasc2Mod-imMasc1Mod;
restaMasc(restaMasc < 0) = 0;
restaMasc = logical(restaMasc);
mosaic(restaMasc) = imWarp2Mod(restaMasc);


% mosaic = blender.step(mosaic, imWarp2Mod,imMasc2Mod);
% mosaic = blender.step(mosaic, imWarp1,imMasc1Mod);
% 
% f = figure(); imshow(mosaic);

% imwrite(mosaic, fullfile(cd,'./Imagenes','Mosaico1.jpg'))
% imwrite(mascPan,fullfile(cd,'./Imagenes','MascaraMosaico1.jpg'))
