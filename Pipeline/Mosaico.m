clear all; close all; clc;
% Prueba de Mosaico

% Cargar las imagenes del mosaico
imRGB1 = cargarimagen();
imRGB2 = cargarimagen();

% imGray1 = rgb2gray(imRGB1);
% imGray2 = rgb2gray(imRGB2);
%%

% se crea el optimizador y la metrica p
[optimizer, metric] = imregconfig('multimodal');

optimizer.InitialRadius = 0.009;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 300;

% Perform the registration.

movingRegistered = imregister(imRGB1, imRGB2, 'affine', optimizer, metric);
% View the registered images.

figure()
imshow(movingRegistered)

%%
% se crea el optimizador y la metrica p
[optimizer, metric] = imregconfig('monomodal');

% optimizer.InitialRadius = 0.009;
% optimizer.Epsilon = 1.5e-4;
% optimizer.GrowthFactor = 1.01;
% optimizer.MaximumIterations = 300;

% Perform the registration.

movingRegistered = imregister(imRGB2, imRGB1, 'affine', optimizer, metric);
% View the registered images.

figure()
imshow(movingRegistered)
