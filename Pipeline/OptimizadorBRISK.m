clear all; close all; clc;
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_617';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 2;
frame2 = 1061;

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
for minContrast = [0.1 0.15 0.2]
    for minQuality = [0.1 0.2 0.3]
        for maxRatio = [0.6 0.7 0.8]
            for matchThreshold = [60 70 80]
                for numOctaves = [4 5]
                try
                    param.MinContrast = minContrast;
                    param.MinQuality = minQuality;
                    param.MaxRatio = maxRatio;
                    param.MatchThreshold = matchThreshold;
                    param.NumOctaves = numOctaves;
                    [Mosaico] = mosaicobrisk(imGray1,imGray2,...
                        imRGB1,imRGB2,imMasc1,imMasc2,param);
                    valorCorr(iter) = ...
                        corr2(Mosaico.imWarp1,Mosaico.imWarp2);
                    fprintf('- Fig %i: corr %.4f\n',...
                        iter,valorCorr(iter));
                    fprintf('  Parametros: %.2f %.2f %.1f %i %i \n',...
                        minContrast,minQuality,maxRatio,matchThreshold,...
                        numOctaves);
                    f = figure(iter); set(f,'WindowStyle','dock');
                    imshowpair(Mosaico.imWarp1,Mosaico.imWarp2);
                catch
                    fprintf('- Puntos coincidentes no suficientes \n')
                     fprintf('  Parametros: %.2f %.2f %.1f %i %i\n',...
                        minContrast,minQuality,maxRatio,matchThreshold,...
                        numOctaves);
                    valorCorr(iter) = 0;
                end
                iter = iter + 1;
                end
            end
        end
    end
end

figure(); plot(1:iter-1,valorCorr)

% figure();imshowpair(Mosaico.imWarp1,Mosaico.imWarp2)
% figure();imshow(Mosaico.imMosaico)