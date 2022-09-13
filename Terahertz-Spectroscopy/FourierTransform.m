function [Frequency, Spectrum] = FourierTransform(t,T)
    L = length(t);
    Frequency = (1/(t(2)-t(1)))/L*(0:L-1);
    Spectrum = fft(T,L);
end