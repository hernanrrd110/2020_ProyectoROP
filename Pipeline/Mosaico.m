clear all; close all; clc;
% Prueba de Mosaico
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');

[~,imGray1] = cargarimagen('Vasos_819.jpg');
[~,imGray2] = cargarimagen('Vasos_1229.jpg');

imGray1 = imadjust(imGray1);
imGray2 = imadjust(imGray2);

%% Etapa 2 - Registro de pares de imagenes 

points = detectSURFFeatures(imGray1);
[features, points] = extractFeatures(imGray1, points);

figure; imshow(imGray1); hold on; plot(points.selectStrongest(10));

points = detectSURFFeatures(imGray2);
[features, points] = extractFeatures(imGray2, points);

figure; imshow(imGray2); hold on; plot(points.selectStrongest(10));
%%
% Initialize all the transforms to the identity matrix. Note that the
% projective transform is used here because the building images are fairly
% close to the camera. Had the scene been captured from a further distance,
% an affine transform would suffice.

% Inicializar todas las transformaciones a la matriz identidad. Notese que
% las transformaciones proyectiva es usada aqui debido a que las imagenes
% se encuentran bastante cerca de la camara. Teniendo la escena capturada
% desde una distancia mayor, una tranformacion affine seria suficiente.

points = detectSURFFeatures(imGray1);
[features, points] = extractFeatures(imGray1, points);

numImages = 2; % numero de imagenes para el mosaico
tforms(numImages) = projective2d(eye(3)); % Puede cambiarse debido a que 
% no se necesita ninguna perspectiva para nuestro caso

% Initialize variable to hold image sizes.
imageSize = zeros(numImages,2);
imageSize(1,:) = size(imGray1);

for n = 2:numImages

    % Store points and features for I(n-1).
    pointsPrevious = points;
    featuresPrevious = features;
    
    % Save image size.
    imageSize(n,:) = size(imGray2);

    % Detect and extract SURF features for I(n).
    points = detectSURFFeatures(imGray2);
    [features, points] = extractFeatures(imGray2, points);

    % Find correspondences between I(n) and I(n-1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);

    % Estimate the transformation between I(n) and I(n-1).
    tforms(n) = estimateGeometricTransform(matchedPoints,...
        matchedPointsPrev,...
        'projective', 'Confidence', 99.9,...
        'MaxNumTrials', 2000);

    % Compute T(n) * T(n-1) * ... * T(1)
    tforms(n).T = tforms(n).T * tforms(n-1).T;
end
% En este punto, todas las transformaciones en tforms son relativas a la 
% primera imagen. Esta fue una forma conveniente de codificar el 
% procedimiento de registro de imágenes porque permitió el procesamiento 
% secuencial de todas las imágenes. Sin embargo, usar la primera imagen 
% como inicio del panorama no produce el panorama más agradable 
% estéticamente porque tiende a distorsionar la mayoría de las imágenes 
% que forman el panorama. Se puede crear una panorámica más bonita 
% modificando las transformaciones de forma que el centro de la escena sea
% el menos distorsionado. Esto se consigue invirtiendo la transformación de
% la imagen central y aplicando esa transformación a todas las demás.
% Empiece usando el método outputLimits de projective2d para encontrar los 
% límites de salida de cada transformación. Los límites de salida se 
% utilizan entonces para encontrar automáticamente la imagen que está 
% aproximadamente en el centro de la escena.
% Compute the output limits for each transform.
for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), ...
        [1 imageSize(i,2)], [1 imageSize(i,1)]);    
end
% A continuación, calcule el promedio de los límites X para cada 
% transformación y encuentre la imagen que está en el centro. Aquí sólo se
% utilizan los límites X porque se sabe que la escena es horizontal. 
% Si se utiliza otro conjunto de imágenes, puede ser necesario utilizar los
% límites X e Y para encontrar la imagen central.

avgXLim = mean(xlim, 2);
[~,idx] = sort(avgXLim);
centerIdx = floor((numel(tforms)+1)/2);
centerImageIdx = idx(centerIdx);
% Por último, aplique la transformación inversa de la imagen central a 
% todas las demás.

Tinv = invert(tforms(centerImageIdx));
for i = 1:numel(tforms)    
    tforms(i).T = tforms(i).T * Tinv.T;
end

%% Etapa 3 - Inicializar el Panorama
% Ahora, cree una panorámica inicial, vacía, en la que se mapeen todas las 
% imágenes.
% Utilice el método outputLimits para calcular los límites de salida mínimo
% y máximo sobre todas las transformaciones. Estos valores se utilizan para
% calcular automáticamente el tamaño del panorama.

for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i),...
        [1 imageSize(i,2)], [1 imageSize(i,1)]);
end

maxImageSize = max(imageSize);

% Find the minimum and maximum output limits. 
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', imGray1);

%% Etapa 4 - Crear Panorama

% Utiliza imwarp para mapear las imágenes en el panorama y utiliza 
% vision.AlphaBlender para superponer las imágenes.

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:numImages

   
    % Transform I into the panorama.
    warpedImage = imwarp(imGray1, tforms(i), 'OutputView', panoramaView);
                  
    % Generate a binary mask.    
    mask = imwarp(true(size(imGray1,1),size(imGray1,2)), tforms(i), ...
        'OutputView', panoramaView);
    
    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end

figure
imshow(panorama)
