function [spectr] = Specto(transformFilter, signal, t, tslide, scaling)
%Specto Calculates a spectogram of the signal using the given transform
%   Transform is any transform function that calculates an FFT 

spectr=[];
for j=1:length(tslide)
    gt=fft(transformFilter(t, scaling, tslide(j)).*signal);
    spectr=[spectr; 
    % The transform function computes the FFT, so we need to shift it
    % to be correct when trying to view it
    abs(fftshift(gt))]; 
end

end