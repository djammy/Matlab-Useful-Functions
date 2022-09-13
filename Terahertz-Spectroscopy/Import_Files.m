function [] = Import_Files()
    dataFolder = 'C:/Users/r99955dd/Dropbox (The University of Manchester)/BolandGroup shared workspace/Data Files/Cd3As2/RoomTempSpectra/FluenceRepeat';
    [position,T_raw,dT_raw,num_files] = loadFiles(dataFolder);
    
    fluence = [100 75 50 25 10 5 2.5 1];
    permitivitty = 8.854187817620e-12;
    q = 1.60217646e-19;
    c = 299792458;
    for j = 1:num_files
        time(:,j) = position(:,j).*(2e-3/c); % stage position to time in seconds
        L = length(time(:,j)); % length of array to go in Fourier Transform
        Frequency = (1/(time(2,j)-time(1,j)))/L*(0:L-1); % time domain to frequency domain
        dT(:,j) = dT_raw(:,j).*(20/(1000*10)); % scaling of dT to lock-in sensitivity
        T(:,j) = T_raw(:,j) + 0.5*dT(:,j); % scaling of T
        dTonT(:,j) = fft(dT(:,j),L)./fft(T(:,j),L); % calculating dT/T in frequency domain
        weight(:,j) = abs(fft(T(:,j),L))./max(abs(fft(T(:,j),L)));
    end

    fill_factor = 0.33;
    thickness = 100e-9*(pi/4.0);
    material = 'CdAs';
    [m_eff,~,epsilon] = Material_Parameters(material);
    conductivity_full = zeros(L,num_files);
    for j = 1:num_files
        conductivity_full(:,j) = NW_conductivity(Frequency',dTonT(:,j),fill_factor,thickness,epsilon);
    end
    
    Neq = ((2*pi*0.895e12)^2)*m_eff*epsilon*permitivitty/(0.0113*q^2)
    
    f_thz = Frequency./1e12;
    range = f_thz>0.01 & f_thz<3.0;
    f_restrained = f_thz(range);
    cond_restrained = conductivity_full(range,1:num_files);

%     Plot_FluenceDependence_3D(fluence,f_restrained,cond_restrained)
    
    save('all_Data','f_thz','conductivity_full','f_restrained','cond_restrained','weight','m_eff','epsilon')
    
end

function [position,T,dT,num_files] = loadFiles(myFolder)
    % Check to make sure that folder actually exists.  Warn user if it doesn't.
    if ~isfolder(myFolder)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
        uiwait(warndlg(errorMessage));
        myFolder = uigetdir(); % Ask for a new one.
        if myFolder == 0
            % User clicked Cancel
            return;
        end
    end
    
    % Get a list of all files in the folder with the desired file name pattern.
    filePattern = fullfile(myFolder, '*.txt'); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    num_files = length(theFiles);

    % Extract data
    for i = 1:num_files
        baseFileName = theFiles(i).name;
        fullFileName = fullfile(theFiles(i).folder, baseFileName);
        data{i} = dlmread(fullFileName,'\t',1,0);
        all_data = data{i};
        position(:,i) = all_data(:,1);
        T(:,i) = all_data(:,2);
        dT(:,i) = all_data(:,3);
    end
end

