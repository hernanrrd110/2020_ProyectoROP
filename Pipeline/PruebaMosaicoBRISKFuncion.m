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

param.MinContrast = 0.15;
param.MinQuality = 0.20;
param.MaxRatio = 0.7;
param.MatchThreshold = 60; 
param.NumOctaves = 5;
param.Upright = true;
param.TransfType = 'similarity';
param.FeatureSize = 128;

param.NonRigid = true;
param.AccumulatedFieldSmoothing = 3.0;
param.PyramidLevels = 1;
param.iterations = [500];

param.Superponer = 'Imagen2';

[Mosaico] = mosaicobrisk(imGray1,imGray2,imRGB1,imRGB2,...
    imMasc1,imMasc2,param);
[Mosaico.imMosaico,Mosaico.imMascMos,...
    Mosaico.imMosaicRGB,posiciones] = ...
    acortarmosaico(Mosaico.imMosaico,Mosaico.imMascMos,...
    Mosaico.imMosaicRGB);
figure();imshowpair(Mosaico.imWarp1,Mosaico.imWarp2)
figure();imshow(Mosaico.imMosaico)
figure();imshow(Mosaico.imMosaicRGB)

%% Guardado
numMosaic = 2;
imwrite(Mosaico.imMosaico,...
    fullfile(folderMosaico,sprintf('Mosaico_%i.jpg',numMosaic)));
imwrite(Mosaico.imMascMos,...
    fullfile(folderMosaico,sprintf('MascMosaico_%i.jpg',numMosaic) ) )
imwrite(Mosaico.imMosaicRGB,...
    fullfile(folderMosaico,sprintf('MosaicoRGB_%i.jpg',numMosaic) ) )
pathDatos = fullfile(folderMosaico,sprintf('Mosaico_%i.mat',numMosaic) );

transform = Mosaico.transf;
funcion = 'mosaicobrisk';
refDim = Mosaico.refDim;
xLimits = Mosaico.xLimitsRef;
yLimits = Mosaico.yLimitsRef;

if(param.NonRigid == false)
    save(pathDatos,'param','nombreImFija','nombreImMovil','transform',...
        'posiciones','funcion','xLimits','yLimits','refDim')
else
    dispField = Mosaico.dispField;
    save(pathDatos,'param','nombreImFija','nombreImMovil','transform',...
        'posiciones','dispField','funcion','xLimits','yLimits','refDim')
end
