clear all; close all; clc;
% Prueba de SURF
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');

[~,imGray1] = cargarimagen('Vasos_165.jpg');
[~,imGray2] = cargarimagen('Vasos_819.jpg');

imGray1 = imadjust(imGray1);
imGray2 = imadjust(imGray2);

% Pathmetadatos
pathMetadatos = fullfile(cd,'./Frames_Videos/ID_69/metadatos.mat');
load(pathMetadatos);

% Creacion de mascaras
imRGB1 = cargarimagen('ImagenModif_165.jpg');
mascBin1 = clasificadorhsv(imRGB1,posCent(165,:), radio(165));
% Strel de disco para comparacion con la funcion imclose
se = strel('disk',40);
mascBin1 = imclose(mascBin1,se);
se = strel('disk',70);
mascBin1 = imerode(mascBin1,se);
CON_FONDO = 1;
mascBin1 = recortelupa(mascBin1 ,...
            posCent(165,:), radio(165),CON_FONDO);
imRGB1 = recortelupa(imRGB1 ,...
    posCent(165,:), radio(165),CON_FONDO);

imRGB2 = cargarimagen('ImagenModif_819.jpg');
mascBin2 = clasificadorhsv(imRGB2,posCent(819,:), radio(819));
% Strel de disco para comparacion con la funcion imclose
se = strel('disk',40);
mascBin2 = imclose(mascBin2,se);
se = strel('disk',70);
mascBin2 = imerode(mascBin2,se);
mascBin2 = recortelupa(mascBin2 ,...
    posCent(819,:), radio(819),CON_FONDO);
imRGB2 = recortelupa(imRGB2 ,...
    posCent(819,:), radio(819),CON_FONDO);
% 
imGray1 = imGray1.*mascBin1;
imGray2 = imGray2.*mascBin2;

% imGray1 = imadjust(imRGB1(:,:,2).*mascBin1);
% imGray2 = imadjust(imRGB2(:,:,2).*mascBin2);

%%
% Encontramos las caracteristicas SURF
pointsSURF1 = detectSURFFeatures(imGray1);
pointsSURF2 = detectSURFFeatures(imGray2);

% Caracteristicas BRISK
pointsBRISK1 = detectBRISKFeatures(imGray1,'MinContrast',0.01,...
    'MinQuality',0.2);
pointsBRISK2 = detectBRISKFeatures(imGray2,'MinContrast',0.01,...
    'MinQuality',0.2);

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
    'MaxRatio',0.5,'Metric','SAD');
indexPairsBRISK = matchFeatures(fFREAK2,fFREAK1,'MatchThreshold',60,...
    'MaxRatio',0.7,'Metric','SAD');
% Coincidencias únicas, especificadas como un par separado por comas que 
% consiste en "Unique" y true o falso. Establezca este valor como true
% para devolver sólo las coincidencias únicas entre 
% las características1 y las características2.
% Si se establece como false, la función devuelve todas las coincidencias
% entre las características1 y las características2. Varias 
% características de features1 pueden coincidir con una 
% característica de features2.

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

figure; showMatchedFeatures(imGray1,imGray2,matchedBoth1,matchedBoth2);
legend('matched points 1','matched points 2');

tforms = estimateGeometricTransform(matchedBoth2,...
    matchedBoth1,...
    'affine', 'Confidence', 99.9999,...
    'MaxNumTrials', 1000000);

% Compute the output limits for each transform
imageSize1 = size(imGray1);
imageSize2 = size(imGray2);
[xlim(1,:), ylim(1,:)] = outputLimits(affine2d(eye(3)), [1 imageSize1(2)],...
    [1 imageSize1(1)]);

[xlim(2,:), ylim(2,:)] = outputLimits(tforms, [1 imageSize2(2)],...
    [1 imageSize2(1)]);

% Find the minimum and maximum output limits 
xMin = min([1; xlim(:)]);
xMax = max([imageSize1(2);imageSize2(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize1(1);imageSize2(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width], 'like', imGray1);

%% Etapa 4 - Crear Panorama por Mascara Binaria

% Utiliza imwarp para mapear las imágenes en el panorama y utiliza 
% vision.AlphaBlender para superponer las imágenes.

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
warpedImage = imwarp(imGray1, affine2d(eye(3)), 'OutputView', ...
    panoramaView,'SmoothEdges',true);

mask = imwarp(mascBin1,affine2d(eye(3)),'OutputView', panoramaView,...
    'SmoothEdges',true);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage,mask);

% Transform I into the panorama.
warpedImage = imwarp(imGray2, tforms, 'OutputView', panoramaView,...
    'SmoothEdges',true);

mask = imwarp(mascBin2,tforms,'OutputView', panoramaView,...
    'SmoothEdges',true);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage,mask);

figure();
imshow(panorama)

%% Crear mascara completa del mosaico

mascPan = panorama;
mascPan(mascPan>0) = 1;
se = strel('disk',20);
mascPan = imclose(mascPan,se);
imshowpair(panorama,mascPan);

%% Etapa 4 - Crear Panorama por Mezcla

% Utiliza imwarp para mapear las imágenes en el panorama y utiliza 
% vision.AlphaBlender para superponer las imágenes.

blender = vision.AlphaBlender();imshow(panorama);
blender.Operation = 'Blend';
blender.Opacity = 0.0001;
% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.

% Transform I into the panorama.
warpedImage1 = imwarp(imGray1, affine2d(eye(3)), 'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage1);

% Transform I into the panorama.
warpedImage2 = imwarp(imGray2, tforms, 'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage2);

% imshow(warpedImage1+warpedImage2,[])
figure();
imshow(panorama)

