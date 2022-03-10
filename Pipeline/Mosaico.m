clear all; close all; clc;
% Prueba de Mosaico

% Cargar las imagenes del mosaico
[~,imGray1] = cargarimagen();
[~,imGray2] = cargarimagen();

%%

% se crea el optimizador y la metrica p
[optimizer, metric] = imregconfig('multimodal');

optimizer.InitialRadius = 0.009;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 300;

% Perform the registration.

movingRegistered = imregister(imGray1, imGray2, 'rigid', optimizer, metric);
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

movingRegistered = imregister(imGray1, imGray2, 'rigid', optimizer, metric);
% View the registered images.

figure()
imshow(movingRegistered)
