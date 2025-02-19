% =============================================================================
% Project       : lpcSpeechSynthesis
% Module name   : study_1_Robotic_voice
% File name     : study_1_Robotic_voice.m
% File type     : Matlab script
% Purpose       : make a robotic voice based on study_0 framework
% Author        : QuBi (nitrogenium@outlook.fr)
% Creation date : Wednesday, 19 February 2025
% -----------------------------------------------------------------------------
% Best viewed with space indentation (2 spaces)
% =============================================================================

% -----------------------------------------------------------------------------
% DESCRIPTION
% -----------------------------------------------------------------------------
% A simple robotic voice from the study_0 framwork, done by zeroing the
% phase of each term in the FFT.
% Output is not super clean but it gives a first shot.

close all
clear all
clc

% -----------------------------------------------------------------------------
% SETTINGS
% -----------------------------------------------------------------------------
w = 1024;
h = 512;
win = hann(w);

% -----------------------------------------------------------------------------
% READ SIGNAL
% -----------------------------------------------------------------------------
[x, fs] = audioread('../db/rec03___gather_your_strength.mp3');
x = x(:,1);
x = [zeros(w,1); x; zeros(w,1)];
nPts = size(x,1);

% -----------------------------------------------------------------------------
% SPLIT
% -----------------------------------------------------------------------------
[Mx, nFrm] = splitOverlap(x, w, h);

% Apply window
Mx_w = Mx .* win;

% -----------------------------------------------------------------------------
% PROCESS
% ------------------------------------------------- ----------------------------
for frm = 1:nFrm
  s = fft(Mx_w(:,frm));
  
  % Zero the phase of all FFT terms
  s_r = abs(s);
  
  Mx_w(:,frm) = real(ifft(s_r));
end


% -----------------------------------------------------------------------------
% MERGE
% -----------------------------------------------------------------------------
x_r = mergeOverlap(Mx_w, h);

% Evaluate the window gain
Mwin = win(:, ones(1, nFrm));
g = mergeOverlap(Mwin, h);

% Remove the window gain
x_r = x_r ./ g;

% Remove the padding
x_r = x_r(1:nPts, 1);

% -----------------------------------------------------------------------------
% OUTPUT
% -----------------------------------------------------------------------------

% Original vs. reconstructed
figure
plot([x, x_r])
title('Original vs. reconstructed')
xlabel('sample')
grid minor

sound(x_r, fs)