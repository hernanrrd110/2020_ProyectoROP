function [BW] = crearmascaralupa(imHSV)
%  crearmask  Threshold RGB image using auto-generated code 
%  from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 03-Aug-2021
%------------------------------------------------------

% Umbrales de deteccion Tonalidad
channel1Min = 0.079;
channel1Max = 0.075;

% Umbrales de deteccion Saturacion
channel2Min = 0.000;
channel2Max = 0.3;

% Umbrales de deteccion Valor
channel3Min = 0.000;
channel3Max = 0.3;

% Crear mascara segun los valores umbrales
BW = ( (imHSV(:,:,1) >= channel1Min) | (imHSV(:,:,1) <= channel1Max) ) & ...
    (imHSV(:,:,2) >= channel2Min ) & (imHSV(:,:,2) <= channel2Max) & ...
    (imHSV(:,:,3) >= channel3Min ) & (imHSV(:,:,3) <= channel3Max);
BW = ~BW;

end
