close all;
clear;

audioFiles = ["Original_Audio/audio_in_noise1.wav" "Original_Audio/audio_in_noise2.wav" "Original_Audio/audio_in_noise3.wav"]; 
numFiles = length(audioFiles);
mkdir("Q1");

for k = 1:numFiles
    file = audioFiles(k);
    [filePath,fileName,fileExt] = fileparts(file);
    
    [y,Fs] = audioread(file);
    info = audioinfo(file);

    t = 0:seconds(1/Fs):seconds(info.Duration);
    t = t(1:end-1);
    
    figure
    plot(t,y)
    xlabel('Time')
    ylabel('Amplitude')
    title("Time domain")
    f = gcf;
    exportgraphics(f, 'Q1/' + "time_" + fileName + '.png');

    Y = fft(y,Fs);
    L = length(Y);
    
    % Copied code from https://uk.mathworks.com/help/matlab/ref/fft.html
    f = Fs/L*(0:(L/2));
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    % End of copied code
    
    figure
    plot(f, P1)
    xlabel("Frequency (Hz)")
    ylabel("Single-Sided Amplitude Spectrum")
    title("Frequency domain")
    f = gcf;
    exportgraphics(f, 'Q1/' + "frequency_" + fileName + '.png');
end