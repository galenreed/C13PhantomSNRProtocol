% Galen Reed
% written and tested in Octave 4.4.0
% 9/13/18

clear all; 
close all;
addpath('utils');

%if(isOctave())
%    pkg load image;
%end

% the pfile format changed with dv26, so a new script for loading data m ust be used
% furthermore, there is a change (either in the reading script or file format) that 
% transposes the X and Y coordinates, so this must be considered when sorting
files = {'toronto/P44032.7', 'mskcc/P87552.7'};
dv26Flag = [0 0 0];


% take a square patch on the top left corner with this edge size
noiseRegionSize = 10;

sosImages = {};
snrMaps = {};
fileNameRoot = 'snrMaps';




for ii = 1:length(files)
  
  % read the PFile
  if(dv26Flag(ii) == 1)
    [rawData, header, ec] = read_MR_rawdata(files{ii});
  else
    [rawData, header] = rawloadX(files{ii});
  end
  squeezedData = squeeze(rawData);
  
  % check for multiple receivers
  multiChannelFlag = 0;
  if(length(size(squeezedData)) == 3)
    multiChannelFlag = 1;
  end
  
  % reconstruct individual coil images
  rawImages = fftAndZeroPad(squeezedData, dv26Flag(ii));
  
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
  noiseRegion = sosImages(1:noiseRegionSize, 1:noiseRegionSize);
  noise = std(noiseRegion(:));
  noiseBias = mean(noiseRegion(:));
  snrMap = (sosImages - noiseBias) / noise;
  snrMap = (sosImages) / noise;
  
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
  colorbar
  set(gca, 'xtick', [], 'ytick', []);
  title(files{ii});

  %cleanup
  delete(thisFileName);
end


