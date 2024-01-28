clear;
close all;
% ANALYSIS FROM Q1
% 1: 600 Hz
% 2: 150Hz
% 3: 250Hz 900Hz

audioFiles = ["Original_Audio/audio_in_noise1.wav" "Original_Audio/audio_in_noise2.wav" "Original_Audio/audio_in_noise3.wav"]; 
mkdir("Q2");

[y,Fs] = audioread(audioFiles(1));
info = audioinfo(audioFiles(1));
filteredAudio = bandstop(y, [575,625], Fs);
audiowrite("Q2/noise_removed1.wav",filteredAudio, Fs);
timePlot(filteredAudio, Fs, info.Duration, 1);
frequencyPlot(filteredAudio, Fs, 1);

[y,Fs] = audioread(audioFiles(2));
info = audioinfo(audioFiles(2));
filteredAudio = bandstop(y, [125,175], Fs);
audiowrite("Q2/noise_removed2.wav",filteredAudio, Fs);
timePlot(filteredAudio, Fs, info.Duration, 2);
frequencyPlot(filteredAudio, Fs, 2);

[y,Fs] = audioread(audioFiles(3));
info = audioinfo(audioFiles(3));
y = bandstop(y, [225,275], Fs);
filteredAudio = bandstop(y, [875,925], Fs);
audiowrite("Q2/noise_removed3.wav",filteredAudio, Fs);
timePlot(filteredAudio, Fs, info.Duration, 3);
frequencyPlot(filteredAudio, Fs, 3);

% Time Domain
function [] = timePlot(y, Fs, duration, n)
    t = 0:seconds(1/Fs):seconds(duration);
    t = t(1:end-1);
    
    figure
    plot(t,y)
    xlabel('Time')
    ylabel('Amplitude')
    title("Time domain")
    f = gcf;
    exportgraphics(f, "Q2/time_noise_removed" + n + ".png");
end


% Frequency Domain
function [] = frequencyPlot(y, Fs, n)
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
    title("Frequency domain");
    f = gcf;
    exportgraphics(f, "Q2/frequency_noise_removed" + n + ".png");
end
