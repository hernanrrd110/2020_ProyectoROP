function [Mosaico] = mosaicosurf(imGray1,imGray2,imRGB1,imRGB2,...
    mascBin1,mascBin2,param)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%Verificamos valores por default
param = verificarparametros(param);

metricThreshold = param.MetricThreshold;
numScaleLevels = param.NumScaleLevels;
numOctaves = param.NumOctaves;
maxRatio = param.MaxRatio;
matchThreshold = param.MatchThreshold;
upright = param.Upright;
featureSize = param.FeatureSize;

% Caracteristicas SURF
pointsSURF1 = detectSURFFeatures(imGray1,...
    'MetricThreshold',metricThreshold,...
    'NumScaleLevels',numScaleLevels,...
    'NumOctaves',numOctaves);
pointsSURF2 = detectSURFFeatures(imGray2,...
    'MetricThreshold',metricThreshold,...
    'NumScaleLevels',numScaleLevels,...
    'NumOctaves',numOctaves);

% Extraemos Carateristicas
[fSURF1,vptsSURF1] = extractFeatures(imGray1,pointsSURF1,...
    'FeatureSize',featureSize,...
    'Upright',upright);
[fSURF2,vptsSURF2] = extractFeatures(imGray2,pointsSURF2,...
    'FeatureSize',featureSize,...
    'Upright',upright);

% Retrieve the locations of matched points.
indexPairsSURF = matchFeatures(fSURF2,fSURF1,...
    'MatchThreshold',matchThreshold,...
    'MaxRatio',maxRatio);

matchedPoSURF1 = vptsSURF1(indexPairsSURF(:,2),:);
matchedPoSURF2 = vptsSURF2(indexPairsSURF(:,1),:);

tforms = estimateGeometricTransform(matchedPoSURF2,...
    matchedPoSURF1,...
    param.TransfType,...
    'Confidence', 99.999,...
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

% Etapa 4 - Crear Panorama por Mascara Binaria
% Utiliza imwarp para mapear las imágenes en el panorama

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
mosRef = imref2d([height width], xLimits, yLimits);

% Transform I into the panorama.
imWarp1 = imwarp(imGray1, affine2d(eye(3)), ...
    'OutputView', mosRef,...
    'SmoothEdges',true);
imMascWarp1 = imwarp(mascBin1,affine2d(eye(3)),...
    'OutputView', mosRef);

% Transform II into the panorama.
imWarp2 = imwarp(imGray2, tforms, 'OutputView', mosRef);
imMascWarp2 = imwarp(mascBin2,tforms,'OutputView', mosRef);

% Nonrigid registration
if(param.NonRigid)
    [dispField,imWarp2] = ...
        imregdemons(imWarp2,imWarp1,param.iterations,...
        'AccumulatedFieldSmoothing',param.AccumulatedFieldSmoothing,...
        'PyramidLevels',param.PyramidLevels);
    % Transform II into the panorama.
    imMascWarp2 = imwarp(imMascWarp2,dispField,'Interp','nearest');
end

% Crear mosaico, imagenes y mascaras
% Initialize the "empty" panorama.
imWarp2 = imhistmatch(imWarp2,imWarp1);
se = strel('disk',10);
if(param.Superponer == 'Imagen1')
    imMascWarp1 = imerode(imMascWarp1,se);
    imMascWarp1(imMascWarp1<0.5) = 0;
    imMascWarp2(imMascWarp2<0.5) = 0;
    imMascWarp1(imMascWarp1>=0.5) = 1;
    imMascWarp2(imMascWarp2>=0.5) = 1;
    mosaic = imWarp1.*imMascWarp1;
    restaMasc = imMascWarp2-imMascWarp1;
    restaMasc(restaMasc < 0) = 0;
    restaMasc = logical(restaMasc);
    mosaic(restaMasc) = imWarp2(restaMasc);
elseif (param.Superponer == 'Imagen2')
    imMascWarp2 = imerode(imMascWarp2,se);
    imMascWarp1(imMascWarp1<0.5) = 0;
    imMascWarp2(imMascWarp2<0.5) = 0;
    imMascWarp1(imMascWarp1>=0.5) = 1;
    imMascWarp2(imMascWarp2>=0.5) = 1;
    mosaic = imWarp2.*imMascWarp2;
    restaMasc = imMascWarp1-imMascWarp2;
    restaMasc(restaMasc < 0) = 0;
    restaMasc = logical(restaMasc);
    mosaic(restaMasc) = imWarp1(restaMasc);
end

% Crear mascara completa del mosaico
mascPan = mosaic;
mascPan(mascPan>0) = 1;
se = strel('disk',20);
mascPan = imclose(mascPan,se);

% Crear Mosaico RGB

imWarp1RGB = imwarp(imRGB1, affine2d(eye(3)),...
    'OutputView', mosRef,...
    'SmoothEdges',true);
imWarp2RGB = imwarp(imRGB2, tforms,...
    'OutputView', mosRef,...
    'SmoothEdges',true);
if (param.NonRigid)
    imWarp2RGB = imwarp(imWarp2RGB, dispField,...
        'SmoothEdges',true);
end

if(param.Superponer == 'Imagen1')
    mosaicRGB = imWarp1RGB.*imMascWarp1;
    mosaicRGB = mosaicRGB + imWarp2RGB.*restaMasc;
elseif(param.Superponer == 'Imagen2')
    mosaicRGB = imWarp2RGB.*imMascWarp2;
    mosaicRGB = mosaicRGB + imWarp1RGB.*restaMasc;
end

% Estructura de salida
Mosaico.imMosaico = mosaic;
Mosaico.imMascMos = mascPan;
Mosaico.imWarp1 = imWarp1;
Mosaico.imWarp2 = imWarp2;
Mosaico.imMascWarp1 = imMascWarp1;
Mosaico.ImMascWarp2 = imMascWarp2;
Mosaico.imRef2d = mosRef;
Mosaico.transf = tforms;
Mosaico.xLimitsRef = xLimits;
Mosaico.yLimitsRef = yLimits;
Mosaico.refDim = [height width];
Mosaico.imMosaicRGB = mosaicRGB;

if (param.NonRigid)
    Mosaico.dispField = dispField;
end

end

function parametros = verificarparametros(parametros)
    % Verificamos que existan los parametros
    % En caso que no existan, les damos un valor predeterminado
    if(~isfield(parametros,'MetricThreshold'))
        parametros.MetricThreshold = 700;
    end
    if(~isfield(parametros,'NumScaleLevels'))
        parametros.NumScaleLevels = 4;
    end
    if(~isfield(parametros,'NumOctaves'))
        parametros.NumOctaves = 3;
    end
    if(~isfield(parametros,'TransfType'))
        parametros.TransfType = 'affine';
    end
    if(~isfield(parametros,'MaxRatio'))
        parametros.MaxRatio = 0.5;
    end
    if(~isfield(parametros,'MatchThreshold'))
        parametros.MatchThreshold = 60;
    end
    if(~isfield(parametros,'FeatureSize'))
        parametros.FeatureSize = 64;
    end
    if(~isfield(parametros,'Upright'))
        parametros.Upright = false;
    end
    if(~isfield(parametros,'AccumulatedFieldSmoothing'))
        parametros.AccumulatedFieldSmoothing = 1.0;
    end
    if(~isfield(parametros,'PyramidLevels'))
        parametros.PyramidLevels = 2;
    end
    if(~isfield(parametros,'iterations'))
        parametros.iterations = 100;
    end
    if(~isfield(parametros,'NonRigid'))
        parametros.NonRigid = false;
    end
    if(~isfield(parametros,'Superponer'))
        parametros.Superponer = 'Imagen1';
    end
end
