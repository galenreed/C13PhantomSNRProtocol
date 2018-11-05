% Galen Reed
% written and tested in Octave 4.4.0
% 9/13/18

clear all; 
close all;
addpath('utils');
addpath('read_MR');


files = {'b1mappingUTSWTorso/45/P55296.7', 'b1mappingUTSWTorso/90/P54272.7'};
files = {'b1mappingUTSWClamshell/45/P59392.7', 'b1mappingUTSWClamshell/90/P60416.7'};



%
% reconstruction parameters
params.integrationWindow = 550; % [Hz] spectra integration width for generating image
params.lineBroadening = 1; % [Hz] line broadening filter width 
params.noiseRegionSize = 8; % [pixels] noise calculated from a square with this edge size
params.noiseStdThresh = 5; % threshold for noise masks
params.reconMode = 0; % 0 for multiple images in SNR units, 1 for B1 mapping. 
params.doPlot = 1;% make a plot of the summed spectra with integration limits
%params.noiseBandwidth = 1200; % [Hz] bandwidth of spectra over hich to determine noise
params.plotFontSize = 15;


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
  rawImages = fftAndZeroPad(squeezedData, params, header);
  
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
    [mask, noiseSTD, noiseMEAN] = createMaskAndCalculateNoise(sosImages, params);
    snrMap = (sosImages- noiseMEAN) / noiseSTD;
  else 
    snrMap = sosImages;
  end
  
  % save to file
  thisFileName = [fileNameRoot num2str(ii) '.mat'];
  save(thisFileName, 'snrMap');
  
end


%%plot
thetaSOS = []; 
twothetaSOS = [];
figure();
for ii = 1:length(files)
  % read from file
  thisFileName = [fileNameRoot num2str(ii) '.mat'];
  load(thisFileName);
  subplot(1, length(files), ii);
  imagesc(snrMap');
  colorbar();
  set(gca, 'xtick', [], 'ytick', []);
  title(files{ii});
  
  %cleanup
  delete(thisFileName);
  
  % grab save the theta/2theta maps if b1mapping
  if(1)
    if(ii == 1)
      thetaSOS = snrMap;
    elseif(ii == 2)
      twothetaSOS = snrMap;
    end
  end
end


% calculate and display the B1 map
if(params.reconMode == RECONB1MAP)
  ratioMap = twothetaSOS ./ thetaSOS;
  estAngle = acos(0.5 * ratioMap) * 180 / pi;
  percentNominal = estAngle * 100 / 45;
  [mask, noise] = createMaskAndCalculateNoise(twothetaSOS, params);
  percentNominal = percentNominal .* mask;
  
  figure();
  imagesc(percentNominal', [50 150])
  colormap jet;
  colorbar();
  title('percent nominal B_1');
  set(gca, 'xtick', [], 'ytick', []);
  set(gca, 'fontsize', params.plotFontSize);
end






