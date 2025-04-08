% =============================================================================
% Project       : lpcSpeechSynthesis
% Module name   : -
% File name     : study_3_Voice_detection.m
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
% TODO

close all
clear all
clc

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

POWER_THRESH = 0.1;

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

for frame = 1:nFrm
  
  xCurr = Mx(:,frame);

  if (sum(xCurr.^2) > POWER_THRESH)
 
    [r, lags] = xcorr(xCurr, MAX_LAG, 'normalized');

    peakCount = 0;
    peakLag = zeros(MAX_LAG-2, 1);
    peakVal = zeros(MAX_LAG-2, 1);
    for lag = 1:(MAX_LAG-1)
      u = lag + (MAX_LAG+1);

      rL = abs(r(u-1));
      rC = abs(r(u));
      rR = abs(r(u+1));
      
      if ((rL < rC) && (rC > rR))
        peakCount = peakCount + 1;
        peakLag(peakCount) = lag;
        peakVal(peakCount) = rC;
      end
    end
    peakLag = peakLag(1:peakCount);
    peakVal = peakVal(1:peakCount);

    plot(lags, abs(r), peakLag, peakVal, 'r+');
    title(sprintf('Frame %d/%d - peakCount: %d', frame, nFrm, peakCount));
    grid minor
    %pause(0.01)
    pause()
  end

end


