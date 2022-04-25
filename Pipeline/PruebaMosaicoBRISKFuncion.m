clear all; close all; clc;
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_69';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 2;
frame2 = 1205;

nombreImFija = sprintf('Mosaico_%i.jpg',frame1);
nombreImMovil = sprintf('Vasos_%i.jpg',frame2);

% Carga de imagenes
[~,imGray1] = cargarimagen( fullfile(folderMosaico,...
    nombreImFija) );
[~,imGray2] = cargarimagen( fullfile(folderMosaico,...
    nombreImMovil) );

% Carga de Mascaras
[~,imMasc1] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascMosaico_%i.jpg',frame1) ) );
[~,imMasc2] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascVasos_%i.jpg',frame2) ) );

param.MinContrast = 0.15;
param.MinQuality = 0.20;
param.MaxRatio = 0.7;
param.MatchThreshold = 70;
param.NumOctaves = 3;
param.Upright = false;
param.AccumulatedFieldSmoothing = 3.0;
param.PyramidLevels = 4;
param.iterations = [1000];
selectNonRigid = true;

[Mosaico] = mosaicobrisk(imGray1,imGray2,...
    imMasc1,imMasc2,param,selectNonRigid);
[Mosaico.imMosaico,Mosaico.imMascMos, posiciones] = ...
    acortarmosaico(Mosaico.imMosaico,Mosaico.imMascMos);
figure();imshowpair(Mosaico.imWarp1,Mosaico.imWarp2)
figure();imshow(Mosaico.imMosaico)

%% Guardado

numMosaic = 3;
imwrite(Mosaico.imMosaico,...
    fullfile(folderMosaico,'Mosaico_3.jpg'))
imwrite(Mosaico.imMascMos,...
    fullfile(folderMosaico,sprintf('MascMosaico_%i.jpg',numMosaic) ) )
pathDatos = fullfile(folderMosaico,sprintf('Mosaico_%i.mat',numMosaic) );

transform = Mosaico.transf;

funcion = 'mosaicobrisk';

if(selectNonRigid == false)
    save(pathDatos,'param','nombreImFija','nombreImMovil','transform',...
        'posiciones','funcion')
else
    dispField = Mosaico.dispField;
    save(pathDatos,'param','nombreImFija','nombreImMovil','transform',...
        'posiciones','dispField','funcion')
end


