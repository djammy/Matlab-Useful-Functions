function [frequency] = Wavenumber_to_Frequency(wavenumber)
    wavelength = (1.0)./wavenumber; % wavenumber is in cm-1
    frequency = (2.99792458e10)./wavelength;
end