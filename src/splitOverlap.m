% =============================================================================
% Project       : lpcSpeechSynthesis
% Module name   : splitOverlap
% File name     : splitOverlap.m
% Purpose       : splits a linear signal with a given window and hop size
% Author        : QuBi (nitrogenium@hotmail.com)
% Creation date : Sunday, 02 February 2025
% -----------------------------------------------------------------------------
% Best viewed with space indentation (2 spaces)
% =============================================================================
%
% DESCRIPTION
% Takes a signal (vector) as input, reads a window of 'w' samples, jumps
% 'h' samples further, reads another 'w' samples and so on.
% The content of each read is returned in a matrix where each column
% corresponds to a read.
% The last read is padded with zeros if there aren't enough samples.
%
% Arguments:
% - x [nPts*1]  : the input signal to be broken apart
% - w [1*1]     : window size
% - h [1*1]     : hop size
%
% Outputs:
% - Mx      [w*nReads]  : matrix containing all the reads of signal 'x'
% - nReads  [1*1]       : number of reads done
%



function [Mx, nReads] = splitOverlap(x, w, h)

  nPts = size(x,1);
  nReads = ceil(1 + ((nPts-w)/h));
  
  nPad = ((nReads-1)*h + w) - nPts;
  xPad = [x; zeros(nPad,1)];
  
  Mx = zeros(w, nReads);
  
  for r = 1:nReads
    a = 1 + (r-1)*h;
    b = w + (r-1)*h;
    Mx(:,r) = xPad(a:b);
  end
  
end

