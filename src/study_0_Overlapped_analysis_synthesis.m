% =============================================================================
% Project       : lpcSpeechSynthesis
% Module name   : study_0_Overlapped_analysis_synthesis
% File name     : study_0_Overlapped_analysis_synthesis.m
% Purpose       : an experimental analysis/synthesis framework, with overlap
% Author        : QuBi (nitrogenium@hotmail.com)
% Creation date : Wednesday, 05 February 2025
% -----------------------------------------------------------------------------
% Best viewed with space indentation (2 spaces)
% =============================================================================

% -----------------------------------------------------------------------------
% DESCRIPTION
% -----------------------------------------------------------------------------
% A basic framework running a full analysis + synthesis using overlapped
% frames.
% The main goal is to determine windows that are compatible for this
% purpose.

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
% -----------------------------------------------------------------------------
% ...
% ...

% -----------------------------------------------------------------------------
% MERGE
% -----------------------------------------------------------------------------
x_r = mergeOverlap(Mx, h);
x_r = x_r(1:nPts, 1);

% Undo window gain
% ...

% -----------------------------------------------------------------------------
% PLOT
% -----------------------------------------------------------------------------
figure
plot([x, x_r])
grid minor

figure
plot(abs(x-x_r))
grid minor