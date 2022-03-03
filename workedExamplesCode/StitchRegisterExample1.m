%% Example 1a (two 20X 3x3 scans, single z plane)

% move ND2 files to the directory in which you'll use them (projDir). The
% Scan struct will save absolute file paths referencing these files
projDir='/Users/iandardani/Code/pixyDuck/workedExamplesData/Ex1/';
cd(projDir)

%% Make Scan
Tchan=readtable('Tchan.csv');
ND2files={'Ex1 read1 20X.nd2';'Ex1 strip1 20X.nd2'};
Scan=makeScanObject(ND2files,...
                'refRound',1,...
                'channelLabels',Tchan,...
                'numControlPointsPerRegistration',4);
% default numControlPointsPerRegistration is 9, which is recommended.
% But for smaller datasets (a 3x3 grid) it might throw an error with so few points

save(fullfile(projDir,filesep,'ScanObject1a.mat'),'Scan', '-v7.3') % save the Scan struct

%% Stitch and output TIFF files: 1x2 subregions, innerBoxIntersect, using 'channelPrefixes'
tifNameFormat={'channelPrefixes','_','channelExposureTimesMs','ms_','channelLabels'};

load(fullfile(projDir,filesep,'ScanObject1a.mat')) % load Scan
makeStitches(Scan,...
    'SubregionArray',[1 2],...
    'tifNameFormat',tifNameFormat,...
    'tiffOutParentDir',projDir,...
	'ScanBounds','innerBoxIntersect')%,...

%% Stitch and output TIFF files: 2x3 subregions, outerBoxUnion, only a subset of the subregions, using channelNames
tifNameFormat={'R','round','_','channelNames','_','channelLabels'};
makeStitches(Scan,...
    'SubregionArray',[2 3],...
    'tifNameFormat',tifNameFormat,...
    'tiffOutParentDir',projDir,...
 	'ScanBounds','outerBoxUnion',...
    'StitchSubregionSubsetOnly', [1 3; 2 3])

%% Optionally, analyze this data with dentist2:

% FIRST navigate to the folder of the subregion with the TIFF files

launchGUI=true; %set launchGUI=false in order to run in a loop to process spots for all subregions in a batch. Then, afterwards, turn to true to QC check these. The second time you run launchD2ThresholdGUI there will be a spots.csv table in the folder, and it will take these instead of finding spots again

preStitchedScanFilelist=...
    {'R1_DAPI_50ms.tif', 'R1_YFP_100ms_UBC.tif', 'R1_CY3_250ms_ITGA3.tif',...
    'R1s_DAPI_50ms.tif', 'R1s_YFP_100ms.tif',    'R1s_CY3_250ms.tif',...    
    'R1_Brightfield_50ms.tif','R1_YFP_2000ms_UBC.tif',...
    };
channelTypes={...
    'dapi','FISH','FISH',...
    'other','FISH','FISH',...
    'other','other'};
% notice that the 2nd round DAPI is an 'other' channel. The R1 dapi
sigma=0.4; % for 20X, 1x1 binning
%              R1    R1    R2  R2
%              YFP  CY3   YFP  CY3
thresholds=   [45    40    45    40]; % these are optional as an input
aTrousMinThreshFactor=1.5; % only output spots into spots.csv that are 1.5-fold lower than the threshold (if one is provided), otherwise 1.5-fold lower than the autothreshold for a given block). Eg. if threshold provided is 45, then every spots 30 or greater will be in spots.csv, although all spots <45 will have valid=false

% run dentist2
launchD2ThresholdGUI('preStitchedScanFilelist',preStitchedScanFilelist,...
    'launchGUI',launchGUI,...
    'sigma',sigma,...
    'channelTypes',channelTypes,...
    'thresholds',thresholds,...
    'aTrousMinThreshFactor',aTrousMinThreshFactor);