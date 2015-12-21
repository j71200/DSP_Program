% MOD algorithm
close('all')
clear
clc

trainDataFolderPath = './train data/one_plant/';
% trainDataFolderPath = './train data/plants/';
% trainDataFolderPath = './train data/wood/';
DEFAULT_IMAGE_HEIGHT = 512;
DEFAULT_IMAGE_WIDTH = 512;


% dimOfCoefficient = dimOfData + 10;
patchSize = 48;  % [48] so called d, is the patch block size
pixelStep = 16;  % [16] so called s, is the pixel step
horizontalPatchNum = (DEFAULT_IMAGE_WIDTH - patchSize)/pixelStep + 1;
verticalPatchNum = (DEFAULT_IMAGE_HEIGHT - patchSize)/pixelStep + 1;
patchNum = horizontalPatchNum * verticalPatchNum;
dimOfData = patchSize^2;


trainDataList = dir([trainDataFolderPath '*.png']);
[totalNumOfTrainData, ~] = size(trainDataList);
totalPatchNum = patchNum * totalNumOfTrainData;

%% Construct Data Matrix
disp('Start Constructing Data Matrix:');
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
			% close('all')
			% patchFig = figure;
			% hold on;
			% set(patchFig, 'Visible', 'off');
			% imshow(currentPatch);
			% saveas(patchFig, ['./patches/plants_' imageName '_' num2str(verticalIdx) '_' num2str(horizontalIdx) '.png' ]);

			currentPatch = reshape(currentPatch, patchSize^2, 1);

			trainDataMatrixColIdx = (trainDataIdx-1)*patchNum + (horizontalIdx-1)*verticalPatchNum + verticalIdx;
			trainDataMatrix(:, trainDataMatrixColIdx) = currentPatch;
		end
	end
end


%% MOD
startTime = clock;
startTime = ceil(startTime);
disp(['Start MOD at ' num2str(startTime(1)) '/' num2str(startTime(2)) '/' num2str(startTime(3)) ' ' num2str(startTime(4)) ':' num2str(startTime(5)) ]);
tic

K = dimOfData+1;
numIteration = 20;
errorFlag = 0;
L = ceil(dimOfData/2);
InitializationMethod = 'DataElements';
preserveDCAtom = 0;  % What's this...
TrueDictionary = [1, 2; 3, 4];
displayProgress = 1;

param = struct('K', K, 'numIteration', numIteration, 'errorFlag', errorFlag, 'L', L, 'InitializationMethod', InitializationMethod, 'preserveDCAtom', preserveDCAtom, 'TrueDictionary', TrueDictionary, 'displayProgress', displayProgress);

[Dictionary, output] = MOD(trainDataMatrix, param);
save(['var_of_MOD_' num2str(startTime(1)) '_' num2str(startTime(2)) '_' num2str(startTime(3)) '_' num2str(startTime(4)) '_' num2str(startTime(5))]);

toc
endTime = clock;
endTime = ceil(endTime);
% disp(['End MOD at ' num2str(endTime)]);
disp(['End MOD at ' num2str(endTime(1)) '/' num2str(endTime(2)) '/' num2str(endTime(3)) ' ' num2str(endTime(4)) ':' num2str(endTime(5)) ]);



