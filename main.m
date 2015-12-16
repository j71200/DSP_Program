% MOD algorithm
close('all')
clear
clc

trainDataFolderPath = './train data/plants/';
% trainDataFolderPath = './train data/wood/';
DEFAULT_IMAGE_HEIGHT = 512;
DEFAULT_IMAGE_WIDTH = 512;
dimOfData = DEFAULT_IMAGE_HEIGHT * DEFAULT_IMAGE_WIDTH;

dimOfCoefficient = dimOfData + 10;
patchSize = 48;  % so called d, is the patch block size
pixelStep = 16;  % so called s, is the pixel step
horizontalPatchNum = (DEFAULT_IMAGE_WIDTH - patchSize)/pixelStep + 1;
verticalPatchNum = (DEFAULT_IMAGE_HEIGHT - patchSize)/pixelStep + 1;
patchNum = horizontalPatchNum * verticalPatchNum;

% trainDataFolderPath = '/Users/blue/Documents/MATLAB/104_1/DSP/Program/train data/plants/';


trainDataList = dir([trainDataFolderPath '*.png']);
[totalNumOfTrainData, ~] = size(trainDataList);
totalPatchNum = patchNum * totalNumOfTrainData;
disp('Construct Data Matrix:');
trainDataMatrix = zeros(patchSize^2, totalPatchNum);
for trainDataIdx = 1:totalNumOfTrainData	
	%% Reading training data
	imageName = trainDataList(trainDataIdx).name;
	disp([imageName ' - ' num2str(round(100*trainDataIdx/totalNumOfTrainData)) '%']);

	inputImage = imread([trainDataFolderPath imageName]);
	trainImage = rgb2gray(inputImage);

	[height width] = size(trainImage);
	if (height <= 512) && (width < 512)
		disp('(height < 512) && (width <= 512)');
		tempImage = uint8(zeros(DEFAULT_IMAGE_HEIGHT, DEFAULT_IMAGE_WIDTH));
		tempImage(1:height, 1:width) = trainImage;
		trainImage = tempImage;
	elseif (height == 512) && (width == 512)
		% disp('Normal');
	else
		disp('Else');
	end
	
	
	%% Patching
	for verticalIdx = 1:verticalPatchNum
		for horizontalIdx = 1:horizontalPatchNum
			patchLeft = (horizontalIdx-1)*pixelStep+1;
			patchRight = (horizontalIdx-1)*pixelStep+patchSize;
			patchUp = (verticalIdx-1)*pixelStep+1;
			patchDown = (verticalIdx-1)*pixelStep+patchSize;

			currentPatch = trainImage( patchUp:patchDown , patchLeft:patchRight );
			
			%% Ouput the patches
			patchFig = figure;
			hold on;
			set(patchFig, 'Visible', 'off');
			imshow(currentPatch);
			saveas(patchFig, ['./patches/plants_' imageName '_' num2str(verticalIdx) '_' num2str(horizontalIdx) '.png' ]);

			currentPatch = reshape(currentPatch, patchSize^2, 1);

			trainDataMatrixColIdx = (trainDataIdx-1)*patchNum + (horizontalIdx-1)*verticalPatchNum + verticalIdx;
			trainDataMatrix(:, trainDataMatrixColIdx) = currentPatch;
			% trainDataMatrix( (trainDataIdx-1)*patchNum + (verticalIdx-1)* verticalPatchNum + horizontalIdx, : ) = 
		end
	end
	


end








