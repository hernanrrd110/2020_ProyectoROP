function [MOVINGREG] = registracionMatlab(MOVING,FIXED)
%registerImages  Register grayscale images using auto-generated code from 
% Registration Estimator app.
%  [MOVINGREG] = registerImages(MOVING,FIXED) Register grayscale images
%  MOVING and FIXED using auto-generated code from the Registration
%  Estimator app. The values for all registration parameters were set
%  interactively in the app and result in the registered image stored in 
%  the structure array MOVINGREG.
% Auto-generated by registrationEstimator app on 19-Apr-2022
%-----------------------------------------------------------

% Default spatial referencing objects
fixedRefObj = imref2d(size(FIXED));
movingRefObj = imref2d(size(MOVING));

% Detect BRISK features
fixedPoints = detectBRISKFeatures(FIXED,'MinContrast',0.202778,...
    'MinQuality',0.103125,'NumOctaves',4);
movingPoints = detectBRISKFeatures(MOVING,'MinContrast',0.202778,...
    'MinQuality',0.103125,'NumOctaves',4);

% Extract features
[fixedFeatures,fixedValidPoints] = extractFeatures(FIXED,fixedPoints,...
    'Upright',true);
[movingFeatures,movingValidPoints] = extractFeatures(MOVING,...
    movingPoints,...
    'Upright',true);

% Match features
indexPairs = matchFeatures(fixedFeatures,movingFeatures,...
    'MatchThreshold',54.513889,'MaxRatio',0.545139);
fixedMatchedPoints = fixedValidPoints(indexPairs(:,1));
movingMatchedPoints = movingValidPoints(indexPairs(:,2));
MOVINGREG.FixedMatchedFeatures = fixedMatchedPoints;
MOVINGREG.MovingMatchedFeatures = movingMatchedPoints;

% Apply transformation - Results may not be identical between runs
% because of the randomized nature of the algorithm
tform = estimateGeometricTransform(movingMatchedPoints,...
    fixedMatchedPoints,'affine');
MOVINGREG.Transformation = tform;
MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform,...
    'OutputView', fixedRefObj, 'SmoothEdges', true);

% Nonrigid registration
[MOVINGREG.DisplacementField,MOVINGREG.RegisteredImage] = ...
    imregdemons(MOVINGREG.RegisteredImage,FIXED,100,...
    'AccumulatedFieldSmoothing',1.0,'PyramidLevels',2);

% Store spatial referencing object
MOVINGREG.SpatialRefObj = fixedRefObj;

end