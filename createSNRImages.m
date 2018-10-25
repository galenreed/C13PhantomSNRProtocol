% Galen Reed
% written and tested in Octave 4.4.0
% 9/13/18

clear all; 
close all;
addpath('utils');
addpath('read_MR');


files = {'b1mappingUTSWTorso/45/P55296.7', 'b1mappingUTSWTorso/90/P54272.7'};



params.reconMode = 0; % 0 for multiple images in SNR units, 1 for B1 mapping. 
params.integrationWindow = .18; % spectra integration width
params.windowWidth = .3; % FID window width
params.noiseRegionSize = 10; % noise calculated from a square with this edge size
params.doPlot = 1;% make a plot of the summed spectra with integration limits

sosImages = {};
snrMaps = {};
fileNameRoot = 'snrMaps';



RECONSNRMAPS = 0;
RECONB1MAP = 1;

for ii = 1:length(files)
  
  % read the PFile
  [rawData, header, ec] = read_MR_rawdata(files{ii});
  
  squeezedData = squeeze(rawData);
  
  % check for multiple receivers
  multiChannelFlag = 0;
  if(length(size(squeezedData)) == 3)
    multiChannelFlag = 1;
  end
  
  % reconstruct individual coil images
  rawImages = fftAndZeroPad(squeezedData, params);
  
  % do a sum of squares over channels if needed
  sosImages = [];
  if(multiChannelFlag == 1)
    sosImages = zeros(size(rawImages, 1), size(rawImages, 2));
    for jj = 1:size(rawImages, 3)
      sosImages = sosImages + rawImages(:,:,jj) .* rawImages(:,:,jj);
    end
    sosImages = sqrt(sosImages);
  else
    sosImages = rawImages;
  end
  
  % turn magnitude images into SNR maps
  if(params.reconMode == RECONSNRMAPS)
    noiseRegion = sosImages(1:params.noiseRegionSize, 1:params.noiseRegionSize);
    noise = std(noiseRegion(:));
    noiseBias = mean(noiseRegion(:));
    snrMap = (sosImages) / noise;
  else 
    snrMap = sosImages;
  end
  
  % save to file
  thisFileName = [fileNameRoot num2str(ii) '.mat'];
  save(thisFileName, 'snrMap');
  
end



%%plot
figure();
for ii = 1:length(files)
  % read from file
  thisFileName = [fileNameRoot num2str(ii) '.mat'];
  load(thisFileName);
  subplot(1, length(files), ii);
  imagesc(snrMap);
  colorbar();
  set(gca, 'xtick', [], 'ytick', []);
  title(files{ii});
  
  %cleanup
  delete(thisFileName);
end





