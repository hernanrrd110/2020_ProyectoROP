% Example : Show the Gabor Wavelet
% Author : Chai Zhi  
% e-mail : zh_chai@yahoo.cn

close all;
clear all;
clc;
addpath('./Funciones');
addpath('./Imagenes');

% Parameter Setting
R = 128;
C = 128;
Kmax = pi / 2;
f = sqrt( 2 );
Delt = 2 * pi;
Delt2 = Delt * Delt;

% Show the Gabor Wavelets
for v = 0 : 4
    for u = 1 : 8
        % Create the Gabor wavelets
        GW = GaborWavelet ( R, C, Kmax, f, u, v, Delt2 ); 
        figure( 2 );
        % Show the real part of Gabor wavelets
        subplot( 5, 8, v * 8 + u ),imshow ( real( GW ) ,[]); 
    end
    figure ( 3 );
    
    subplot( 1, 5, v + 1 ),imshow ( abs( GW ),[]); 
end



