function [puntajeFrec] = clasificadorfrec(imGray, select)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [M,N] = size(imGray);

    switch select
        case 'gaussiano'
            % En esta parte se crean dos ventanas gausseanas del tamanio
            % de la imagen original MxN,
            % Parametros de las funciones gausseanas
            % Calculo fft imagen original
            fftH = fft2(imGray);
            fftH = fftshift(fftH);
            % valores de sigma de las envolventes gaussianas
            sigmaM = 0.25;
            sigmaL = 0.1;
            % Kernels gaussianos
            ventGaussM = fspecial('gaussian',[M,N],sigmaM);
            ventGaussL = fspecial('gaussian',[M,N],sigmaL);
            fftM = fftH.*ventGaussM; 
            fftL = fftM.*ventGaussL; 
            % Resta de los valores complejos de la fft
            % para obtener las medidas
            restaFAltas = fftH-fftM; 
            restaFMedias = fftM-fftL;
            puntajeFrec = norm(restaFMedias,1)/norm(restaFAltas,1);
            
        case 'laplaciano' 
            puntajeFrec.fmLAPE = fmeasure(imGray, 'LAPE');
            puntajeFrec.fmLAPM = fmeasure(imGray, 'LAPM');
            puntajeFrec.fmLAPV = fmeasure(imGray, 'LAPV');
            puntajeFrec.fmLAPD = fmeasure(imGray, 'LAPD');
            
        case 'cuadrada'
            fCutBajoU = N/12; fCutBajoV = M/12;
            fCutMediaU = N/8; fCutMediaV = M/8;

            % Mascara binaria para obtener las diferentes frecuencias
            masc1 = square2d(M/2-fCutBajoV, M/2+fCutBajoV, ...
                N/2-fCutBajoU, N/2+fCutBajoU, M, N);
            masc2 = square2d(M/2-fCutMediaV, M/2+fCutMediaV, ...
                N/2-fCutMediaU, N/2+fCutMediaU, M, N);

            % Complemento de la segunda mascara
            masc3 = zeros(M,N);
            masc3(masc2==0) = 1;

            % Las FFTs enmascaradas
            fftIm = fft2(imGray);
            fftIm = fftshift(fftIm);
            frecMedias = fftIm .* (masc2-masc1);
            frecAltas = fftIm .* masc3;
            puntajeFrec = norm(frecMedias,1)/norm(frecAltas,1);
            
        case 's3map'
            imGray = imGray*255; % Reescalado de valores para la funcion
            % Llamado a la funcion para hacer el mapa s3
            [~, ~, mapS3] = s3_map(imGray);
            % Calculo del valor S3
            % Ordenamiento de los valores de la matriz en un vector
            vectorS3 = sort(mapS3(:),'descend');
            % Numero de elementos que contiene el 1% mas grandes
            numOneP = round( length( mapS3(:) )/100 );
            % Promedio de 1 porciento de los valores mas grandes
            valorS3 = 1/numOneP * sum( vectorS3(1:numOneP) );
            puntajeFrec = valorS3;     
    end

end

