% =============================================================================
% Project       : lpcSpeechSynthesis
% Module name   : study_2_Voice_detection_design
% File name     : study_2_Voice_detection_design.m
% File type     : Matlab script
% Purpose       : experimental framework to analyse a voice signal frame by 
%                 frame, to help designing a voice/noise discriminator.
% Author        : QuBi (nitrogenium@outlook.fr)
% Creation date : Sunday, 02 February 2025
% -----------------------------------------------------------------------------
% Best viewed with space indentation (2 spaces)
% =============================================================================

% -----------------------------------------------------------------------------
% DESCRIPTION
% -----------------------------------------------------------------------------
% Provides a GUI that explores an audio signal frame by frame, showing its
% spectrum and giving some means to interact with it. 
% Hopefully, it helps to get a better idea of the role of each components
% in the spectrum.

close all
clear all
clc

global clickMsg; clickMsg = 0;
global clickCoord; clickCoord = [0;0];

% -----------------------------------------------------------------------------
% SETTINGS
% -----------------------------------------------------------------------------
% Analysis window and overlap
WINDOW_SIZE = 1024;
HOP_SIZE = 256;

% FFT size
FFT_SIZE = 16384;

% Max frequency in the spectrum plot
F_MAX = 8000;

% Max lag in the autocorrelation plot
MAX_LAG = 1000;



% -----------------------------------------------------------------------------
% READ SIGNAL
% -----------------------------------------------------------------------------
% Load from file
[x, fs] = audioread('../db/rec03___gather_your_strength.mp3');

% Convert to mono
x = x(:,1);

% Prepend and append zeros to avoid information loss
x = [zeros(WINDOW_SIZE, 1); x; zeros(WINDOW_SIZE, 1)];



% -----------------------------------------------------------------------------
% SPLIT
% -----------------------------------------------------------------------------
[Mx, nFrm] = splitOverlap(x, WINDOW_SIZE, HOP_SIZE);

% Apply windowing
y = Mx .* hann(WINDOW_SIZE);

% Calculate spectrum
kMax = round(FFT_SIZE*F_MAX/fs);
s = fft(y, FFT_SIZE, 1);
s = s(1:kMax, :);
f = fs*(0:(kMax-1))'/FFT_SIZE;



% -----------------------------------------------------------------------------
% FIGURES & UI
% -----------------------------------------------------------------------------
fig = figure('Name', 'Signal explorer', 'Position', [475, 250, 1616, 953]);

subplotSignal = subplot(2,2,1);
plotSignal = plot(Mx(:,1));
title('Time series');
xlabel('Time')
grid minor

subplotSpectrum = subplot(2,2,3);
plotSpectrum = plot(f, 20*log10(abs(s(:,1))));
title('Spectrum');
xlabel('Frequency')
ylabel('DSP (dB)')
ylim([-60 60])
grid minor

subplotCorr = subplot(2,2, [2, 4]);
[r, lags] = xcorr(Mx(:,1), MAX_LAG, 'normalized');
plotCorr = plot(lags, abs(r));
line([200, 200], [0, 1.0], 'Color', 'r', 'LineStyle','--')
line([-200, -200], [0, 1.0], 'Color', 'r', 'LineStyle','--')
line([-MAX_LAG, MAX_LAG], [0.4, 0.4], 'Color', 'r', 'LineStyle','--')
title('Autocorr');
xlabel('Lag')
grid minor


% Slider definition
slider = uicontrol('Style', 'slider', ...
  'Min', 1, ...
  'Max', nFrm, ...
  'Value', 1, ...
  'SliderStep', [1/(nFrm-1), 1/(nFrm-1)], ...
  'Position', [100, 20, 800, 20], ...
  'Callback', @(src, event) updatePlot(round(get(src, 'Value')), Mx, s, plotSignal, subplotSignal, plotSpectrum, plotCorr) ...
);

% Attach a click event on the spectrum plot
set(plotSpectrum, 'ButtonDownFcn', @(src, event) plotClickCallback(src, event));




function plotClickCallback(~, event)
  clickPos = event.IntersectionPoint;
  disp(['Clicked at: x = ' num2str(clickPos(1)) ', y = ' num2str(clickPos(2))]);
  clickMsg = 1;
  clickCoord = clickPos;
  %sprintf('Approximate index: k = %d\n', fftSize*clickPos(1)/fs);
end



function updatePlot(frame, Mx, s, hPlot1, hSub1, hPlot2, hPlot3)
  hPlot1.YData = Mx(:, frame);
  hPlot2.YData = 20*log10(abs(s(:,frame)));
  hPlot3.YData = abs(xcorr(Mx(:, frame), 1000, 'normalized'));
  
  hSub1.Title.String = sprintf('Frame %d/%d - Power: %f', frame, size(s,2), sum(Mx(:, frame).^2, 1));
end
  


