clear all; close all; clc;
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_69';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 1;
frame2 = 819;

nombreImFija = sprintf('Mosaico_%i.jpg',frame1);
nombreImMovil = sprintf('Vasos_%i.jpg',frame2);

% Carga de imagenes
[~,imGray1] = cargarimagen( fullfile(folderMosaico,...
    nombreImFija ) );
[~,imGray2] = cargarimagen( fullfile(folderMosaico,...
    nombreImMovil ) );

% Carga de Mascaras
[~,imMasc1] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascMosaico_%i.jpg',frame1) ) );
[~,imMasc2] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascVasos_%i.jpg',frame2) ) );

param.NumOctaves = 3;
param.Upright = false;
iter = 1;
for minContrast = [0.05 0.075 0.1]
    for minQuality = [0.10 0.15 0.20]
        for maxRatio = [0.3 0.5 0.7]
            for matchThreshold = [50 60 70]
                try
                    param.MinContrast = minContrast;
                    param.MinQuality = minQuality;
                    param.MaxRatio = maxRatio;
                    param.MatchThreshold = matchThreshold;
                    [Mosaico] = mosaicobrisk(imGray1,imGray2,...
                        imMasc1,imMasc2,param);
                    valorCorr(iter) = ...
                        corr2(Mosaico.imWarp1,Mosaico.imWarp2);
                    fprintf('- Fig %i: corr %.4f\n',...
                        iter,valorCorr(iter));
                    fprintf('  Parametros: %.2f %.2f %.1f %i\n',...
                        minContrast,minQuality,maxRatio,matchThreshold);
                    f = figure(iter); set(f,'WindowStyle','dock');
                    imshowpair(Mosaico.imWarp1,Mosaico.imWarp2);
                catch
                    fprintf('- Puntos coincidentes no suficientes \n')
                     fprintf('  Parametros: %.2f %.2f %.1f %i\n',...
                        minContrast,minQuality,maxRatio,matchThreshold);
                    valorCorr(iter) = 0;
                end
                iter = iter + 1;
            end
        end
    end
end

figure(); plot(1:iter-1,valorCorr)

% figure();imshowpair(Mosaico.imWarp1,Mosaico.imWarp2)
% figure();imshow(Mosaico.imMosaico)