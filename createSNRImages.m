% Galen Reed
% written and tested in Octave 4.4.0
% 9/13/18

clear all; 
close all;
addpath('utils');
addpath('read_MR');


global RECONSNRMAPS RECONB1MAP RECONSPECCOILS 

% recon mode options:
% 0: SOS over all coils, output in SNR units
RECONSNRMAPS = 0
% 1: B1 mapping. 
RECONB1MAP = 1
% 2: SOS over specified coils only, output in SNR units
RECONSPECCOILS = 2

files = {'pfiles_100318/P77312.7', }; % PM, 4 good channels



%
% reconstruction parameters
params.integrationWindow = 500; % [Hz] spectra integration width for generating image
params.lineBroadening = 3; % [Hz] line broadening filter width 
params.noiseRegionSize = 8; % [pixels] noise calculated from a square with this edge size
params.noiseStdThresh = 5; % threshold for noise masks
params.reconMode = RECONSPECCOILS; 
params.doPlot = 0;% make a plot of the summed spectra with integration limits
params.plotFontSize = 15;
params.displaySingleChannels = 1;% plot all coil elements in an array, if on, set params.doPlot = 0   


% this list is only used when params.reconMode == RECONSPECCOILS
% if summing over all channels is desired for the selected file,
% then put -1 instead of a vector for that entry
% otherwise, put a vector containing the desired coils to include
% in the SOS operation
SOSChannelList = {[1 2 3 4]};


sosImages = {};
snrMaps = {};
fileNameRoot = 'snrMaps';


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
  [MRSIImages]  = fftAndZeroPad(squeezedData, params, header);
  
  
  % do a sum of squares over channels if needed
  sosImages = [];
  if(multiChannelFlag == 1)
    if(params.reconMode == RECONSPECCOILS)  
        [sosImages] = MRSISumOfSquares(MRSIImages, SOSChannelList{ii});
    else 
        [sosImages] = MRSISumOfSquares(MRSIImages, -1);
    end
  else
    sosImages = MRSIImages;
  end
  
  %plot single channels
  if(params.displaySingleChannels == 1 && multiChannelFlag == 1)
    figure();
    nCoils = size(MRSIImages, 4);
    for cc = 1:nCoils
      singleCoilImage = MRSIToImage(squeeze(MRSIImages(:,:,:,cc)), params, header);
      subplot(2, nCoils/2, cc);
      imagesc(singleCoilImage);
      set(gca, 'xtick', []);
      set(gca, 'ytick', []);
      title(num2str(cc));
    end
  end
  
  % MRSI to image
  [integratedData totalSpec] = MRSIToImage(sosImages, params, header);
  
  
  % turn magnitude images into SNR maps
  if(params.reconMode == RECONSNRMAPS || params.reconMode == RECONSPECCOILS)
    [mask, noiseSTD, noiseMEAN] = createMaskAndCalculateNoise(integratedData, params);
    snrMap = (integratedData - noiseMEAN) / noiseSTD;
  else 
    snrMap = integratedData;
  end
  
  
  
  % save to file
  thisFileName = [fileNameRoot num2str(ii) '.mat'];
  save(thisFileName, 'snrMap');
  
end


%%plot
thetaSOS = []; 
twothetaSOS = [];
figure();
binEdges = linspace(20, 70, 15);
for ii = 1:length(files)
  % read from file
  thisFileName = [fileNameRoot num2str(ii) '.mat'];
  load(thisFileName);
  subplot(1, length(files), ii);
  imagesc(snrMap, [0 70]);
  colormap jet;
  colorbar();
  set(gca, 'xtick', [], 'ytick', []);
  title(files{ii});
  
  %subplot(2, length(files), ii+length(files));
  %hist(snrMap(:), binEdges);
  
  
  
  
  
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






