%prueba imgaussfilt
clear all; close all;
I = im2double(imread('cameraman.tif'));
S=size(I);

%filtro sigma=2 espacial
Iblur = imgaussfilt(I,2);

%filtro sigma=20 freq

% padding
% PQ=paddedsize(size(I));
% F=fft2(I,PQ(1),PQ(2));

F=fft2(I);

% H=lpfilter('gaussian',PQ(1),PQ(2),2);
H=lpfilter('gaussian',S(1),S(2),20);

figure; mesh(fftshift(H)); title 'filtro freq';

G=F.*H;
filtrada=ifft2(G);

figure();
montage({I,Iblur}); title 'filtrada espacial';

figure();
montage({I,filtrada});title 'filtrada frecuencial';

figure();
montage({Iblur,filtrada});title 'COMPARE F_e_s_p VS. F_f_r_e_q';
% VER DIFERENCIA!!! se supone que ambas tienen el mismo Sigma. 
% OBSERVAR sigma freq = 20 sigma esp


