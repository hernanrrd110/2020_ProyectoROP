%% Prueba de video
% Prueba para leer video y extraer frames

%% 
clear all; close all; clc;
addpath('./Funciones');
addpath('./Imagenes');
warning('off')

vidObj = VideoReader('ID6_Video_ROP.mp4');
resolution = [vidObj.Height vidObj.Width];
framesNo = round(vidObj.Duration*vidObj.FrameRate);
% vidFrames = zeros(resolution(1),resolution(2),3,framesNo);
% iFrame = 1;

frameIni = 100;
frameFin = 200;
vidFrames = read(vidObj,[frameIni frameFin]);
whos vidFrames

while hasFrame(vidObj)
    vidFrames(:,:,:,iFrame) = readFrame(vidObj);
    iFrame = iFrame + 1;
end

disp('se termino');
