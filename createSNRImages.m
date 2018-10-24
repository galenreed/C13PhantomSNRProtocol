% Galen Reed
% written and tested in Octave 4.4.0
% 9/13/18

clear all; 
close all;
addpath('utils');
addpath('read_MR');


files = {'toronto/P44032.7', 'utsw20180925/image/P72192.7'};

% take a square patch on the top left corner with this edge size
noiseRegionSize = 10;

sosImages = {};
snrMaps = {};
fileNameRoot = 'snrMaps';


for ii = 1:length(files)
  
  % read the PFile
  %[rawData, header] = read_p(files{ii}, 0);
  [rawData, header, ec] = read_MR_rawdata(files{ii});
  
  squeezedData = squeeze(rawData);
  
  % check for multiple receivers
  multiChannelFlag = 0;
  if(length(size(squeezedData)) == 3)
    multiChannelFlag = 1;
  end
  
  % reconstruct individual coil images
  rawImages = fftAndZeroPad(squeezedData);
  
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


