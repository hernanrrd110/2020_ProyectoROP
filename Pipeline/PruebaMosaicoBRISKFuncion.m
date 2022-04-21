clear all; close all; clc;
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_69';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 165;
frame2 = 819;

nombreImFija = sprintf('Vasos_%i.jpg',frame1);
nombreImMovil = sprintf('Vasos_%i.jpg',frame2);

% Carga de imagenes
[~,imGray1] = cargarimagen( fullfile(folderMosaico,...
    nombreImFija) );
[~,imGray2] = cargarimagen( fullfile(folderMosaico,...
    nombreImMovil) );

% Carga de Mascaras
[~,imMasc1] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascVasos_%i.jpg',frame1) ) );
[~,imMasc2] = cargarimagen( fullfile(folderMosaico,...
    sprintf('MascVasos_%i.jpg',frame2) ) );

param.MinContrast = 0.102778;
param.MinQuality = 0.203125;
param.MaxRatio = 0.545139;
param.MatchThreshold = 70.513889;
param.NumOctaves = 3;
param.Upright = false;
param.AccumulatedFieldSmoothing = 3.0;
param.PyramidLevels = 3;
param.iterations = 1000;
selectNonRigid = true;

[Mosaico] = mosaicobrisk(imGray1,imGray2,...
    imMasc1,imMasc2,param,selectNonRigid);
figure();imshowpair(Mosaico.imWarp1,Mosaico.imWarp2)
figure();imshow(Mosaico.imMosaico)

%% Acotar Mosaico
minX = length(Mosaico.imMascMos);
minY = length(Mosaico.imMascMos);
maxX = 0;
maxY = 0;

for iFilas = 1:size(Mosaico.imMascMos,1)
    valor = find(Mosaico.imMascMos(iFilas,:),1);
    if(valor < minX)
        minX = valor;
    end
    valor = find(Mosaico.imMascMos(iFilas,:),1,'last');
    if(valor > maxX)
        maxX = valor;
    end
end

for jColum = 1:size(Mosaico.imMascMos,2)
    valor = find(Mosaico.imMascMos(:,jColum),1);
    if(valor < minY)
        minY = valor;
    end
    valor = find(Mosaico.imMascMos(:,jColum),1,'last');
    if(valor > maxY)
        maxY = valor;
    end
end
Mosaico.imMascMos(minY-20:maxY+20,minX-20:maxX+20)
Mosaico.imMosaico(minY-20:maxY+20,minX-20:maxX+20)

%% Guardado

imwrite(Mosaico.imMosaico,fullfile(folderMosaico,'Mosaico_1.jpg'))
imwrite(Mosaico.imMascMos,fullfile(folderMosaico,'MascMosaico_1.jpg'))
pathDatos = fullfile(folderMosaico,'Mosaico_1.mat');

transform = Mosaico.transf;
dispField = Mosaico.dispField;
funcion = 'mosaicobrisk';

save(pathDatos,'param','nombreImFija','nombreImMovil','transform',...
    'dispField','funcion')


