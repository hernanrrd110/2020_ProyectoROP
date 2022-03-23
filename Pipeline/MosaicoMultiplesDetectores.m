clear all; close all; clc;
% Prueba de SURF
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');

[~,imGray1] = cargarimagen('Vasos_165.jpg');
[~,imGray2] = cargarimagen('Vasos_819.jpg');

imGray1 = imadjust(imGray1);
imGray2 = imadjust(imGray2);

imGray2 = imresize(imGray2,size(imGray1));

% Pathmetadatos
pathMetadatos = fullfile(cd,'./Frames_Videos/ID_69/metadatos.mat');
load(pathMetadatos);

% Creacion de mascaras
imRGB = cargarimagen('ImagenModif_165.jpg');
mascBin1 = clasificadorhsv(imRGB,posCent(165,:), radio(165));
% Strel de disco para comparacion con la funcion imclose
se = strel('disk',40);
mascBin1 = imclose(mascBin1,se);
se = strel('disk',40);
mascBin1 = imerode(mascBin1,se);
CON_FONDO = 1;
mascBin1 = recortelupa(mascBin1 ,...
            posCent(165,:), radio(165),CON_FONDO); 
        
imRGB = cargarimagen('ImagenModif_819.jpg');
mascBin2 = clasificadorhsv(imRGB,posCent(819,:), radio(819));
% Strel de disco para comparacion con la funcion imclose
se = strel('disk',40);
mascBin2 = imclose(mascBin2,se);
se = strel('disk',40);
mascBin2 = imerode(mascBin2,se);
mascBin2 = recortelupa(mascBin2 ,...
            posCent(819,:), radio(819),CON_FONDO);
        
%%
% Encontramos las caracteristicas SURF
pointsSURF1 = detectSURFFeatures(imGray1);
pointsSURF2 = detectSURFFeatures(imGray2);

% Caracteristicas BRISK
pointsBRISK1 = detectBRISKFeatures(imGray1,'MinContrast',0.01,...
    'MinQuality',0.1);
pointsBRISK2 = detectBRISKFeatures(imGray2,'MinContrast',0.01,...
    'MinQuality',0.1);

% Extraemos Carateristicas
[fSURF1,vptsSURF1] = extractFeatures(imGray1,pointsSURF1,'FeatureSize',128);
[fSURF2,vptsSURF2] = extractFeatures(imGray2,pointsSURF2,'FeatureSize',128);
% Las caracteristicas FREAK usan el descriptor FREAK de forma
% predeterminada
[fFREAK1,vptsBRISK1] = extractFeatures(imGray1,pointsBRISK1,...
    'FeatureSize',128);
[fFREAK2,vptsBRISK2] = extractFeatures(imGray2,pointsBRISK2,...
    'FeatureSize',128);

% Retrieve the locations of matched points.
indexPairsSURF = matchFeatures(fSURF2,fSURF1,'MatchThreshold',60,...
    'MaxRatio',0.5);
indexPairsBRISK = matchFeatures(fFREAK2,fFREAK1,'MatchThreshold',60,...
    'MaxRatio',0.5);
% Coincidencias �nicas, especificadas como un par separado por comas que 
% consiste en "Unique" y true o falso. Establezca este valor como true
% para devolver s�lo las coincidencias �nicas entre 
% las caracter�sticas1 y las caracter�sticas2.
% Si se establece como false, la funci�n devuelve todas las coincidencias
% entre las caracter�sticas1 y las caracter�sticas2. Varias 
% caracter�sticas de features1 pueden coincidir con una 
% caracter�stica de features2.

matchedPoSURF1 = vptsSURF1(indexPairsSURF(:,2),:);
matchedPoSURF2 = vptsSURF2(indexPairsSURF(:,1),:);

matchedPoBRISK1 = vptsBRISK1(indexPairsBRISK(:,2),:);
matchedPoBRISK2 = vptsBRISK2(indexPairsBRISK(:,1),:);

% Display the matching points.
% The data still includes several outliers, but you can see the effects
% of rotation and scaling on the display of matched features.
figure; showMatchedFeatures(imGray1,imGray2,matchedPoSURF1,matchedPoSURF2);
legend('matched points 1','matched points 2');

figure; showMatchedFeatures(imGray1,imGray2,matchedPoBRISK1,matchedPoBRISK2);
legend('matched points 1','matched points 2');

matchedBoth1 = [matchedPoSURF1.Location; matchedPoBRISK1.Location];
matchedBoth2 = [matchedPoSURF2.Location; matchedPoBRISK2.Location];

tforms = estimateGeometricTransform(matchedBoth2,...
    matchedBoth1,...
    'similarity', 'Confidence', 99.9999,...
    'MaxNumTrials', 1000000);


%%
imageSize = size(imGray1);  % all the images are the same size
% Compute the output limits for each transform

[xlim(1,:), ylim(1,:)] = outputLimits(affine2d(eye(3)), [1 imageSize(2)],...
    [1 imageSize(1)]);
[xlim(2,:), ylim(2,:)] = outputLimits(tforms, [1 imageSize(2)],...
    [1 imageSize(1)]);

% Find the minimum and maximum output limits 
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width], 'like', imGray1);

%% Etapa 4 - Crear Panorama por Mascara Binaria

% Utiliza imwarp para mapear las im�genes en el panorama y utiliza 
% vision.AlphaBlender para superponer las im�genes.

blender = vision.AlphaBlender();
blender.MaskSource = 'Input port';
blender.Operation = 'Binary mask';
% blender.OpacitySource = 'Input port';

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.

% Transform I into the panorama.
warpedImage = imwarp(imGray1, affine2d(eye(3)), 'OutputView', panoramaView);

mask = imwarp(mascBin1,affine2d(eye(3)),'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage,mask);

% Transform I into the panorama.
warpedImage = imwarp(imGray2, tforms, 'OutputView', panoramaView);

mask = imwarp(mascBin2,tforms,'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage,mask);

figure();
imshow(panorama)

%% Etapa 4 - Crear Panorama por Mezcla

% Utiliza imwarp para mapear las im�genes en el panorama y utiliza 
% vision.AlphaBlender para superponer las im�genes.

blender = vision.AlphaBlender();
blender.Operation = 'Blend';

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.

% Transform I into the panorama.
warpedImage = imwarp(imGray1, affine2d(eye(3)), 'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage);

% Transform I into the panorama.
warpedImage = imwarp(imGray2, tforms, 'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage);

figure();
imshow(panorama)

