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

% -----------------------------------------------------------------------------
% SETTINGS
% -----------------------------------------------------------------------------
w = 1024;
h = 256;
fftSize = 16384;
fMax = 8000;

% -----------------------------------------------------------------------------
% READ SIGNAL
% -----------------------------------------------------------------------------
[x, fs] = audioread('../db/rec03___gather_your_strength.mp3');
x = x(:,1);
x = [zeros(w,1); x; zeros(w,1)];

% -----------------------------------------------------------------------------
% SPLIT
% -----------------------------------------------------------------------------
[Mx, nFrm] = splitOverlap(x, w, h);


kMax = round(fftSize*fMax/fs);

y = Mx .* hann(w);
s = fft(y, fftSize, 1);
s = s(1:kMax, :);
f = fs*(0:(kMax-1))'/fftSize;


fig = figure('Name', 'Signal explorer', 'Position', [475, 250, 1616, 953]);


% -----------------------------------------------------------------------------
% FIGURES & UI
% -----------------------------------------------------------------------------
hSub1 = subplot(2,1,1);
hPlot1 = plot(Mx(:,1));
title('Time series');
xlabel('Time')
ylabel('DSP (dB)')
grid minor

hSub2 = subplot(2,1,2);
hPlot2 = plot(f, 20*log10(abs(s(:,1))));
title('Column 1');
xlabel('Frequency')
ylabel('DSP (dB)')
ylim([-60 60])
grid minor


slider = uicontrol('Style', 'slider', ...
  'Min', 1, ...
  'Max', nFrm, ...
  'Value', 1, ...
  'SliderStep', [1/(nFrm-1), 1/(nFrm-1)], ...
  'Position', [150, 50, 300, 20], ...
  'Callback', @(src, event) updatePlot(round(get(src, 'Value')), Mx, s, hPlot1, hPlot2, hSub1, hSub2) ...
);


set(hPlot2, 'ButtonDownFcn', @(src, event) plotClickCallback(src, event));




function plotClickCallback(~, event)
  clickPos = event.IntersectionPoint;
  disp(['Clicked at: x = ' num2str(clickPos(1)) ', y = ' num2str(clickPos(2))]);
  
  %sprintf('Approximate index: k = %d\n', fftSize*clickPos(1)/fs);
end



function updatePlot(frame, Mx, s, hPlot1, hPlot2, hSub1, hSub2)

  hPlot1.YData = Mx(:, frame);
  hPlot2.YData = 20*log10(abs(s(:,frame)));
  
  hSub1.Title.String = sprintf('Frame %d/%d - Power: %f', frame, size(s,2), sum(Mx(:, frame).^2, 1));
end
  


