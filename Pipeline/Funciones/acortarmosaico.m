function [imMosaicoCort,imMascMosCort,imMosaicRGBCort, posiciones] = ...
    acortarmosaico(imMosaico,imMascMos,imMosaicRGB)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

minX = length(imMascMos);
minY = length(imMascMos);
maxX = 0;
maxY = 0;

for iFilas = 1:size(imMascMos,1)
    valor = find(imMascMos(iFilas,:),1);
    if(valor < minX)
        minX = valor;
    end
    valor = find(imMascMos(iFilas,:),1,'last');
    if(valor > maxX)
        maxX = valor;
    end
end

for jColum = 1:size(imMascMos,2)
    valor = find(imMascMos(:,jColum),1);
    if(valor < minY)
        minY = valor;
    end
    valor = find(imMascMos(:,jColum),1,'last');
    if(valor > maxY)
        maxY = valor;
    end
end
pixelsAd = 20;
imMosaicoCort = zeros((maxY-minY)+2*pixelsAd,(maxX-minX)+2*pixelsAd);
imMascMosCort = zeros((maxY-minY)+2*pixelsAd,(maxX-minX)+2*pixelsAd);
imMosaicRGBCort = zeros((maxY-minY)+2*pixelsAd,(maxX-minX)+2*pixelsAd,3);
imMosaicoCort(pixelsAd:pixelsAd+(maxY-minY),...
    pixelsAd:pixelsAd+(maxX-minX)) = ...
    imMosaico(minY:maxY,minX:maxX);
imMascMosCort(pixelsAd:pixelsAd+(maxY-minY),...
    pixelsAd:pixelsAd+(maxX-minX)) = ...
    imMascMos(minY:maxY,minX:maxX);
imMosaicRGBCort(pixelsAd:pixelsAd+(maxY-minY),...
    pixelsAd:pixelsAd+(maxX-minX),:) = ...
    imMosaicRGB(minY:maxY,minX:maxX,:);

posiciones = [minY maxY;minX maxX];

end

