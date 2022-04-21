function [mosaic,mascPan,tforms,mosRef] = mosaicomultidesc(imGray1,imGray2,...
    mascBin1,mascBin2,numOctaves,metricThreshold,...
    minContrast,minQuality,matchThreshold,maxRatio,metric)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
% Encontramos las caracteristicas SURF
pointsSURF1 = detectSURFFeatures(imGray1,'NumOctaves',numOctaves,...
    'MetricThreshold',metricThreshold);
pointsSURF2 = detectSURFFeatures(imGray2,'NumOctaves',numOctaves,...
    'MetricThreshold',metricThreshold);

% Caracteristicas BRISK
pointsBRISK1 = detectBRISKFeatures(imGray1,'MinContrast',minContrast,...
    'MinQuality',minQuality);
pointsBRISK2 = detectBRISKFeatures(imGray2,'MinContrast',minContrast,...
    'MinQuality',minQuality);

% Extraemos Carateristicas
[fSURF1,vptsSURF1] = extractFeatures(imGray1,pointsSURF1,...
    'FeatureSize',128);
[fSURF2,vptsSURF2] = extractFeatures(imGray2,pointsSURF2,...
    'FeatureSize',128);
% Las caracteristicas FREAK usan el descriptor FREAK de forma
% predeterminada
[fFREAK1,vptsBRISK1] = extractFeatures(imGray1,pointsBRISK1,...
    'FeatureSize',128);
[fFREAK2,vptsBRISK2] = extractFeatures(imGray2,pointsBRISK2,...
    'FeatureSize',128);

% Retrieve the locations of matched points.
indexPairsSURF = matchFeatures(fSURF2,fSURF1,...
    'MatchThreshold',matchThreshold(1),...
    'MaxRatio',maxRatio(1),'Metric',metric);
indexPairsBRISK = matchFeatures(fFREAK2,fFREAK1,...
    'MatchThreshold',matchThreshold(2),...
    'MaxRatio',maxRatio(2));

matchedPoSURF1 = vptsSURF1(indexPairsSURF(:,2),:);
matchedPoSURF2 = vptsSURF2(indexPairsSURF(:,1),:);

matchedPoBRISK1 = vptsBRISK1(indexPairsBRISK(:,2),:);
matchedPoBRISK2 = vptsBRISK2(indexPairsBRISK(:,1),:);

% Display the matching points.
% The data still includes several outliers, but you can see the effects
% of rotation and scaling on the display of matched features.
% figure; showMatchedFeatures(imGray1,imGray2,matchedPoSURF1,matchedPoSURF2);
% legend('matched points 1','matched points 2');
% 
% figure; showMatchedFeatures(imGray1,imGray2,matchedPoBRISK1,matchedPoBRISK2);
% legend('matched points 1','matched points 2');

matchedBoth1 = [matchedPoSURF1.Location; matchedPoBRISK1.Location];
matchedBoth2 = [matchedPoSURF2.Location; matchedPoBRISK2.Location];

tforms = estimateGeometricTransform(matchedBoth2,...
    matchedBoth1,...
    'affine', 'Confidence', 99.999,...
    'MaxNumTrials', 10000,...
    'MaxDistance',1.5);
 
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
mosaic = zeros([height width], 'like', imGray1);

% Etapa 4 - Crear Panorama por Mascara Binaria

% Utiliza imwarp para mapear las imágenes en el panorama y utiliza 
% vision.AlphaBlender para superponer las imágenes.

blender = vision.AlphaBlender();
blender.Operation = 'Binary mask';
blender.MaskSource = 'Input port';
% blender.OpacitySource = 'Input port';

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
mosRef = imref2d([height width], xLimits, yLimits);

% Create the panorama.

% Transform I into the panorama.
warpedImage = imwarp(imGray2, tforms, 'OutputView', mosRef);

mask = imwarp(mascBin2,tforms,'OutputView', mosRef);
% Overlay the warpedImage onto the panorama.
mosaic = blender.step(mosaic, warpedImage,mask);

% Transform I into the panorama.
warpedImage = imwarp(imGray1, affine2d(eye(3)), 'OutputView', mosRef);

mask = imwarp(mascBin1,affine2d(eye(3)),'OutputView', mosRef);

% Overlay the warpedImage onto the panorama.
mosaic = blender.step(mosaic, warpedImage,mask);

% Crear mascara completa del mosaico

mascPan = mosaic;
mascPan(mascPan>0) = 1;
se = strel('disk',20);
mascPan = imclose(mascPan,se);

end

