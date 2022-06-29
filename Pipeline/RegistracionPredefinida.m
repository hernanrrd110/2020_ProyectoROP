clear all; close all; clc;
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

nameVid = 'ID_376';
folderName = fullfile(cd,'./Frames_Videos',nameVid);
folderMosaico = fullfile(folderName,'Imagenes_Mosaico');

frame1 = 308;
frame2 = 83;

% nombreImFija = sprintf('Mosaico_%i.jpg',frame1);
nombreImFija = sprintf('Vasos_%i.jpg',frame1);
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

%-----------
tforms = MOVINGREG.Transformation;
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
imMascWarp1 = imwarp(imMasc1,affine2d(eye(3)),...
    'OutputView', mosRef);

% Transform II into the panorama.
imWarp2 = imwarp(imGray2, tforms, 'OutputView', mosRef);
imMascWarp2 = imwarp(imMasc2,tforms,'OutputView', mosRef);

% Crear mosaico, imagenes y mascaras
% Initialize the "empty" panorama.
imWarp2 = imhistmatch(imWarp2,imWarp1);
se = strel('disk',10);
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

mosaicRGB = imWarp1RGB.*imMascWarp1;
mosaicRGB = mosaicRGB + imWarp2RGB.*restaMasc;

[mosaic,mascPan,...
    mosaicRGB,posiciones] = ...
    acortarmosaico(mosaic,mascPan,...
    mosaicRGB);

imshow(mosaicRGB)

%% Guardado
numMosaic = 1;
imwrite(mosaic,...
    fullfile(folderMosaico,sprintf('Mosaico_%i.jpg',numMosaic)));
imwrite(mascPan,...
    fullfile(folderMosaico,sprintf('MascMosaico_%i.jpg',numMosaic) ) )
imwrite(mosaicRGB,...
    fullfile(folderMosaico,sprintf('MosaicoRGB_%i.jpg',numMosaic) ) )
pathDatos = fullfile(folderMosaico,sprintf('Mosaico_%i.mat',numMosaic) );

transform = tforms;
funcion = 'matlab';
refDim = mosRef;
save(pathDatos,'nombreImFija','nombreImMovil','transform',...
        'posiciones','funcion','xLimits','yLimits','refDim')


