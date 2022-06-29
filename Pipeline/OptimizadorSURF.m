clear all; close all; clc;
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_244';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 1;
frame2 = 731;

nombreImFija = sprintf('Mosaico_%i.jpg',frame1);
% nombreImFija = sprintf('Vasos_%i.jpg',frame1);
nombreImMovil = sprintf('Vasos_%i.jpg',frame2);

% Carga de imagenes
[~,imGray1] = cargarimagen( fullfile(folderMosaico,...
    nombreImFija) );
[~,imGray2] = cargarimagen( fullfile(folderMosaico,...
    nombreImMovil) );
imRGB1 = cargarimagen(fullfile(folderMosaico,...
    replace(nombreImFija,'_','RGB_') ) );
imRGB2 = cargarimagen( fullfile(folderMosaico,...
    replace(nombreImMovil,'_','RGB_') ) );

% Carga de Mascaras
[~,imMasc1] = cargarimagen( fullfile(folderMosaico,...
    strcat('Masc',nombreImFija) ) );
[~,imMasc2] = cargarimagen( fullfile(folderMosaico,...
    strcat('Masc',nombreImMovil) ) );

param.FeatureSize = 128;
param.Upright = true;
param.TransfType = 'similarity';

iter = 1;
for metricThreshold = [600 700]
    for numScaleLevels = [3 4 5]
        for numOctaves = [4 5]
            for matchThreshold = [60 70 80]
                for maxRatio = [0.6 0.7 0.8]
                try
                    param.MetricThreshold = metricThreshold;
                    param.NumScaleLevels = numScaleLevels;
                    param.NumOctaves = numOctaves;
                    param.MaxRatio = maxRatio;
                    param.MatchThreshold = matchThreshold;
                    
                    [Mosaico] = mosaicosurf(imGray1,imGray2,...
                        imRGB1,imRGB2,imMasc1,imMasc2,param);
                    valorCorr(iter) = ...
                        corr2(Mosaico.imWarp1,Mosaico.imWarp2);
                    fprintf('- Fig %i: corr %.4f\n',...
                        iter,valorCorr(iter));
                    fprintf('  Parametros: %i %i %i %.2f %i \n',...
                        metricThreshold,numScaleLevels,numOctaves,...
                        maxRatio,matchThreshold);
                    f = figure(iter); set(f,'WindowStyle','dock');
                    imshowpair(Mosaico.imWarp1,Mosaico.imWarp2);
                catch
                    fprintf('- Puntos coincidentes no suficientes \n')
                     fprintf('  Parametros: %i %i %i %.2f %i\n',...
                        metricThreshold,numScaleLevels,numOctaves,...
                        maxRatio,matchThreshold);
                    valorCorr(iter) = 0;
                end
                iter = iter + 1;
                end
            end
        end
    end
end

figure(); plot(1:iter-1,valorCorr,'*')

% figure();imshowpair(Mosaico.imWarp1,Mosaico.imWarp2)
% figure();imshow(Mosaico.imMosaico)