% =============================================================================
% Project       : lpcSpeechSynthesis
% Module name   : mergeOverlap
% File name     : mergeOverlap.m
% Purpose       : recombines a signal from its split/overlapped version
% Author        : QuBi (nitrogenium@hotmail.com)
% Creation date : Sunday, 02 February 2025
% -----------------------------------------------------------------------------
% Best viewed with space indentation (2 spaces)
% =============================================================================
%
% DESCRIPTION
% Takes a matrix 'Mx' where each column corresponds to an overlapped read
% of an original signal 'x'.
% Knowing the hop size 'h' used for the reads, the function reconstructs
% the original signal 'x'.
%
% Arguments:
% - Mx  [w*nReads]  : matrix containing the overlapped reads of signal 'x'
% - h   [1*1]       : hop size 
%
% Outputs:
% - x [nPts*1]  : the reconstructed signal
%



function x = mergeOverlap(Mx, h)

  [w, nReads] = size(Mx);

  nPts = w + (nReads-1)*h;
  x = zeros(nPts, 1);
  
  for r = 1:nReads
    a = 1 + (r-1)*h;
    b = w + (r-1)*h;
    x(a:b) = x(a:b) + Mx(:,r);
  end

end

