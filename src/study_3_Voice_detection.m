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

% Size of the neighbourhood for the peak search.
% A given sample is declared as a 'peak' if it is greater than every sample
% in a range of +/-PEAK_SPAN
PEAK_SPAN = 2;

POWER_THRESH = 0.1;



% -----------------------------------------------------------------------------
% READ SIGNAL
% -----------------------------------------------------------------------------
% Load from file
[x, fs] = audioread('../db/rec03___gather_your_strength.mp3');

% Convert to mono
x = x(:,1);

% Prepend and append zeros to avoid information loss
xPad = [zeros(WINDOW_SIZE, 1); x; zeros(WINDOW_SIZE, 1)];

nPts = size(xPad,1);


% -----------------------------------------------------------------------------
% SPLIT
% -----------------------------------------------------------------------------
[Mx, nFrm] = splitOverlap(xPad, WINDOW_SIZE, HOP_SIZE);

% Apply windowing
Mx_w = Mx .* hann(WINDOW_SIZE);



% -----------------------------------------------------------------------------
% VOICE/NOISE ANALYSIS
% -----------------------------------------------------------------------------

% Copy the original frames
Mx_p = Mx_w;

% Loop on the frames
for frame = 1:nFrm
  
  xCurr = Mx_w(:, frame);

  if (sum(xCurr.^2) > POWER_THRESH)
 
    [r, lags] = xcorr(xCurr, MAX_LAG, 'normalized');

    peakCount = 0;
    peakLag = zeros(MAX_LAG-(2*PEAK_SPAN), 1);
    peakVal = zeros(MAX_LAG-(2*PEAK_SPAN), 1);
    for lag = PEAK_SPAN:(MAX_LAG-PEAK_SPAN)
      u = lag + (MAX_LAG+1);

      isMonotonous = true;
      rC = abs(r(u));
      for n = 1:PEAK_SPAN
        rL_ = abs(r(u-n)); rL = abs(r(u-(n-1)));
        rR_ = abs(r(u+n)); rR = abs(r(u+(n-1)));
        
        if ~((rL_ < rL) && (rR > rR_))
          isMonotonous = false;
          break;
        end
      end
        
      if isMonotonous 
        peakCount = peakCount + 1;
        peakLag(peakCount) = lag;
        peakVal(peakCount) = rC;
      end
    end
    peakLag = peakLag(1:peakCount);
    peakVal = peakVal(1:peakCount);

    % Reconstruct
    if (peakCount > 50)
      Mx_p(:, frame) = sqrt(var(xCurr))*randn(WINDOW_SIZE, 1);
    else
      Mx_p(:, frame) = xCurr;
    end

  else
    %Mx_p(:, frame) = zeros(WINDOW_SIZE, 1);
    Mx_p(:, frame) = xCurr;
  end


  % TODO
  % - plot signal before/after
  % - plot xcorr before/after
  % ...



end

x_r = mergeOverlap(Mx_p, HOP_SIZE);
    

% Evaluate the window gain
win = hann(WINDOW_SIZE);
Mwin = win(:, ones(1, nFrm));
g = mergeOverlap(Mwin, HOP_SIZE);

% Remove the window gain
x_r = x_r ./ g;

% Remove the padding
x_r = x_r(1:nPts, 1);



    % plot(lags, abs(r), peakLag, peakVal, 'r+');
    % title(sprintf('Frame %d/%d - peakCount: %d', frame, nFrm, peakCount));
    % grid minor
    % %pause(0.01)
    % pause()
  


plot([xPad, x_r])

sound(x_r, fs)