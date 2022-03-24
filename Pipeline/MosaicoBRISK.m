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
        
% imshowpair(imGray2, mascBin2,'Scaling','joint')
%%
% Find the SURF features.
points1 = detectBRISKFeatures(imGray1,'MinContrast',0.4,...
    'MinQuality',0.01);
points2 = detectBRISKFeatures(imGray2,'MinContrast',0.4,...
    'MinQuality',0.01);

% Extract the features.
[f1,vpts1] = extractFeatures(imGray1,...
    points1.selectStrongest(1000),'FeatureSize',128);
[f2,vpts2] = extractFeatures(imGray2,...
    points2.selectStrongest(1000),'FeatureSize',128);

% Retrieve the locations of matched points.
indexPairs = matchFeatures(f2,f1,'MatchThreshold',80,...
    'MaxRatio',0.6);
matchedPoints1 = vpts1(indexPairs(:,2),:);
matchedPoints2 = vpts2(indexPairs(:,1),:);

% Display the matching points.
% The data still includes several outliers, but you can see the effects
% of rotation and scaling on the display of matched features.
figure; showMatchedFeatures(imGray1,imGray2,matchedPoints1,matchedPoints2);
legend('matched points 1','matched points 2');

% Estimate the transformation between I(n) and I(n-1).
tforms(2) = affine2d(eye(3));

tforms(2) = estimateGeometricTransform(matchedPoints2,...
    matchedPoints1,...
    'affine', 'Confidence', 99.99999,...
    'MaxNumTrials', 10000000);

imageSize = size(imGray1);  % all the images are the same size
% Compute the output limits for each transform
for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)],...
        [1 imageSize(1)]);    
end

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
warpedImage = imwarp(imGray1, tforms(1), 'OutputView', panoramaView);

mask = imwarp(mascBin1,tforms(1),'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage,mask);

% Transform I into the panorama.
warpedImage = imwarp(imGray2, tforms(2), 'OutputView', panoramaView);

mask = imwarp(mascBin2,tforms(2),'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage,mask);

figure();
imshow(panorama)

%% Etapa 4 - Crear Panorama por Mezcla

% Utiliza imwarp para mapear las imágenes en el panorama y utiliza 
% vision.AlphaBlender para superponer las imágenes.

blender = vision.AlphaBlender();
blender.Operation = 'Blend';

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.

% Transform I into the panorama.
warpedImage = imwarp(imGray1, tforms(1), 'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage);

% Transform I into the panorama.
warpedImage = imwarp(imGray2, tforms(2), 'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = blender.step(panorama, warpedImage);

figure();
imshow(panorama)

