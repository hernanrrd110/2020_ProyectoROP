function [Mosaico] = mosaicobrisk(imGray1,imGray2,...
    mascBin1,mascBin2,param,selectNonRigid)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if(nargin == 5)
    selectNonRigid = false;
end

%Verificamos valores por default
param = verificarparametros(param);

minContrast = param.MinContrast;
minQuality = param.MinQuality;
maxRatio = param.MaxRatio;
matchThreshold = param.MatchThreshold;
numOctaves = param.NumOctaves;
upright = param.Upright;


% Caracteristicas BRISK
pointsBRISK1 = detectBRISKFeatures(imGray1,'MinContrast',minContrast,...
    'MinQuality',minQuality,...
    'NumOctaves',numOctaves);
pointsBRISK2 = detectBRISKFeatures(imGray2,'MinContrast',minContrast,...
    'MinQuality',minQuality,...
    'NumOctaves',numOctaves);

% Extraemos Carateristicas
% Las caracteristicas FREAK usan el descriptor FREAK de forma
% predeterminada
[fFREAK1,vptsBRISK1] = extractFeatures(imGray1,pointsBRISK1,...
    'FeatureSize',128,...
    'Upright',upright);
[fFREAK2,vptsBRISK2] = extractFeatures(imGray2,pointsBRISK2,...
    'FeatureSize',128,...
    'Upright',upright);

% Retrieve the locations of matched points.
indexPairsBRISK = matchFeatures(fFREAK2,fFREAK1,...
    'MatchThreshold',matchThreshold,...
    'MaxRatio',maxRatio);

matchedPoBRISK1 = vptsBRISK1(indexPairsBRISK(:,2),:);
matchedPoBRISK2 = vptsBRISK2(indexPairsBRISK(:,1),:);

tforms = estimateGeometricTransform(matchedPoBRISK2,...
    matchedPoBRISK1,...
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
    'OutputView', mosRef,...
    'SmoothEdges',true);

% Transform II into the panorama.
imWarp2 = imwarp(imGray2, tforms, 'OutputView', mosRef);
imMascWarp2 = imwarp(mascBin2,tforms,'OutputView', mosRef);

% Nonrigid registration
if(selectNonRigid)
    [dispField,imWarp2] = ...
        imregdemons(imWarp2,imWarp1,param.iterations,...
        'AccumulatedFieldSmoothing',param.AccumulatedFieldSmoothing,...
        'PyramidLevels',param.PyramidLevels);
    % Transform II into the panorama.
    imMascWarp2 = imwarp(imMascWarp2,dispField,...
        'SmoothEdges',true);
end

% Crear mosaico, imagenes y mascaras
% Initialize the "empty" panorama.
mosaic = imWarp1;
restaMasc = imMascWarp2-imMascWarp1;
restaMasc(restaMasc < 0) = 0;
restaMasc = logical(restaMasc);
mosaic(restaMasc) = imWarp2(restaMasc);

% Crear mascara completa del mosaico
mascPan = mosaic;
mascPan(mascPan>0) = 1;
se = strel('disk',20);
mascPan = imclose(mascPan,se);

% Estructura de salida
Mosaico.imMosaico = mosaic;
Mosaico.imMascMos = mascPan;
Mosaico.imWarp1 = imWarp1;
Mosaico.imWarp2 = imWarp2;
Mosaico.imRef2d = mosRef;
Mosaico.transf = tforms;
if (selectNonRigid)
    Mosaico.dispField = dispField;
end

end

function parametros = verificarparametros(parametros)
    % Verificamos que existan los parametros
    % En caso que no existan, les damos un valor predeterminado
    if(~isfield(parametros,'MinContrast'))
        parametros.MinContrast = 0.01;
    end
    if(~isfield(parametros,'MinQuality'))
        parametros.MinQuality = 0.2;
    end
    if(~isfield(parametros,'MaxRatio'))
        parametros.MaxRatio = 0.5;
    end
    if(~isfield(parametros,'MatchThreshold'))
        parametros.MatchThreshold = 60;
    end
    if(~isfield(parametros,'NumOctaves'))
        parametros.NumOctaves = 3;
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
end
