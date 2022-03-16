clear all; close all; clc;
% Cargar las imagenes del mosaico
addpath('./Funciones');
addpath('./Imagenes');

[imRGB,~] = cargarimagen('Image_1229.jpg');
[~,imGray] = cargarimagen('Vasos_1229.jpg');

[imCort, posCent, radio] = detectorlupa(imRGB);
mascaraCirc = zeros(size(imRGB,1),size(imRGB,2));
for iFilas = 1:size(imRGB,1)
    for jColum = 1:size(imRGB,2)
        if( (iFilas-posCent(2))^2 + (jColum-posCent(1))^2 <= ...
                (0.95*radio)^2)
            mascaraCirc(iFilas,jColum) = 1;
        end
    end
end


figure(); imshow(imCort)

[mascaraHSV,~] = ...
            clasificadorhsv(imRGB,posCent, radio);
mascaraTotal = mascaraHSV.*mascaraCirc;

se = strel('disk',50);
masc1 = imclose(mascaraTotal,se);
se = strel('disk',20);
masc2 = imerode(masc1,se);

figure();
imshowpair(masc1, masc2,'Scaling','joint')

%%
imBin = imbinarize(imGrayAdj);
imBin = imerode(imBin);
figure; imshow(imBin);
se = strel('disk',5);

% % 
% % imMasc = imGray;
% % imMasc(imMasc ~=0) = 1;
% % imshow(imMasc);
% % 

% imopen
