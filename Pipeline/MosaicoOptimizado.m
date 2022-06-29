clear all; close all; clc;
% Prueba de SURF
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_510';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 497;
frame2 = 432;
% nombreImFija = sprintf('Mosaico_%i.jpg',frame1);
nombreImFija = sprintf('Vasos_%i.jpg',frame1);
nombreImMovil = sprintf('Vasos_%i.jpg',frame2);

% Carga de imagenes
[~,imGray1] = cargarimagen( fullfile(folderMosaico,...
    nombreImFija) );
[~,imGray2] = cargarimagen( fullfile(folderMosaico,...
    nombreImMovil) );

% Carga de Mascaras
[~,imMasc1] = cargarimagen( fullfile(folderMosaico,...
    strcat('Masc',nombreImFija) ) );
[~,imMasc2] = cargarimagen( fullfile(folderMosaico,...
    strcat('Masc',nombreImMovil) ) );

% Parametros a iterar
numOctaves = 3; %SURF
% metricThreshold = 1000; %SURF
minContrast = 0.01; % BRISK
minQuality = 0.2; % BRISK
% matchThreshold1 = 60; %MATCHING
% matchThreshold2 = 60; %MATCHING
metric = 'SAD';
iter = 1;
for maxRatio1 = 0.7:0.1:0.8
    for maxRatio2 = 0.7:0.1:0.8
        for matchThreshold1 = 60:10:70
            for matchThreshold2 = 60:10:70
                for metricThreshold = 500:250:1000
                    
        [~,~,tforms,mosRef] = ...
            mosaicomultidesc(imGray1,imGray2,...
            imMasc1,imMasc2,numOctaves,metricThreshold,...
            minContrast,minQuality,...
            [matchThreshold1 matchThreshold2],...
            [maxRatio1 maxRatio2],metric);
        % imagenes transformadas para compararlas
        imWarp1 = imwarp(imGray1, affine2d(eye(3)), ...
            'OutputView', mosRef);
        imWarp2 = imwarp(imGray2, tforms, ...
            'OutputView', mosRef);
        % Calculo de correlacion entre imagenes
        valorCorr(iter) = corr2(imWarp1,imWarp2);
        fprintf('- Fig %i: corr %.4f\n',iter,valorCorr(iter));
        fprintf('  MaxRatio %.1f %.1f; ', maxRatio1, maxRatio2);
        fprintf('Umbral Coinc %i %i \n',...
            matchThreshold1, matchThreshold2);
        fprintf('  NumOctavas %i; ', numOctaves);
        fprintf('Umbral Metrica %i;\n', metricThreshold);
        fprintf('  Min Contrast %.2f; ', minContrast);
        fprintf('Min Calidad %.2f; \n ', minQuality);
        
        iter = iter +1;
        f = figure();set(f,'WindowStyle','dock'); 
        imshowpair(imWarp1,imWarp2);
        
                end
            end
        end
    end
end

%  - Fig 22: corr 0.4710
%   MaxRatio 0.7 0.8; Umbral Coinc 70 70 
%   NumOctavas 3; Umbral Metrica 500;
%   Min Contrast 0.01; Min Calidad 0.20; 

f = figure(); plot(1:1:iter-1,valorCorr)

[mosai,mascPan,tforms,mosRef] = ...
    mosaicomultidesc(imGray1,imGray2,...
    imMasc1,imMasc2,numOctaves,metricThreshold,...
    minContrast,minQuality,...
    [matchThreshold1 matchThreshold2],...
    [maxRatio1 maxRatio2],metric);



