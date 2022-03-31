function [mascFinal] = cerrayerocionarmascara(masc1,radClose,radErode)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
se = strel('disk',radClose);
mascFinal = imclose(masc1,se);
se = strel('disk',radErode);
mascFinal = imerode(mascFinal,se);

end

