close all
clear all
clc

[x, fs] = audioread('../db/rec03___gather_your_strength.mp3');
x = x(:,1);
w = 1024;
h = 512;
[Mx, nFrm] = splitOverlap(x, w, h);

fftSize = 16384;
fMax = 4000;
kMax = round(fftSize*fMax/fs);

y = Mx .* hann(w);
s = fft(y, fftSize, 1);
s = s(1:kMax, :);
f = fs*(0:(kMax-1))'/fftSize;



fig = figure('Name', 'Signal explorer', 'Position', [475, 250, 1616, 953]);

% Initialise the plot
%ax = axes('Parent', fig, 'Position', [0.1, 0.3, 0.85, 0.65]);

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
ylim([-40 60])
grid minor


slider = uicontrol('Style', 'slider', ...
  'Min', 1, ...
  'Max', nFrm, ...
  'Value', 1, ...
  'SliderStep', [1/(nFrm-1), 1/(nFrm-1)], ...
  'Position', [150, 50, 300, 20], ...
  'Callback', @(src, event) updatePlot(round(get(src, 'Value')), Mx, s, hPlot1, hPlot2, hSub1, hSub2) ...
);




set(hSub2, 'ButtonDownFcn', @(src, event) plotClickCallback(src, event));




function plotClickCallback(~, event)
  clickPos = event.IntersectionPoint;
  disp(['Clicked at: x = ' num2str(clickPos(1)) ', y = ' num2str(clickPos(2))]);
end



function updatePlot(colIndex, Mx, s, hPlot1, hPlot2, hSub1, hSub2)
  %set(hPlot2, 'YData', 20*log10(abs(s(:,colIndex))));
 
  %set(hPlot1, 'YData', Mx(:, colIndex));
  %set(hPlot2, 'YData', 20*log10(abs(s(:,colIndex))));
  
  hPlot1.YData = Mx(:, colIndex);
  hPlot2.YData = 20*log10(abs(s(:,colIndex)));
  
  hSub1.Title.String = sprintf('Frame %d/%d - Power: %f', colIndex, size(s,2), sum(Mx(:, colIndex).^2, 1));
  
  %title(ax, sprintf('Frame %d/%d', colIndex, size(s,2)));
  %set(label, 'String', ['Col: ' num2str(colIndex)]);
end
  

% function getSpectrum(x)
% 
% y = Mx(:,r) .* hann(w);
% 
% s = fft(y, fftSize);
% s = s(1:kMax);
% f = fs*(0:(kMax-1))'/fftSize;
% subplot(2,1,2)
% plot(f, 20*log10(abs(s)))
% %xlim(0
% ylim([-40 60])
% grid minor
% 
% title(sprintf('Frame %d/%d, Power = %f', r, nFrm, pow))
% 
% 
% subplot(2,1,1)
% plot(Mx(:,r))
% ylim([-1.0 1.0])
% 
% end
% 
%   
  
