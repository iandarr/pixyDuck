function fitSpots(channels)
% fitSpots(channels)
%   calls TwoStageSpotFitProcessedData for the input channels for all objects in current directory

    if ischar(channels)
        channels={channels};
    end


    dataAdder = improc2.processing.DataAdder();
    unprocessedFittedData = improc2.nodeProcs.TwoStageSpotFitProcessedData();
    
    for iChannel=1:length(channels)
        channelToFit=channels{iChannel};
        dataAdder.addDataToObject(unprocessedFittedData, channelToFit, [channelToFit,':Fitted'])
    end
    
    dataAdder.repeatForAllObjectsAndQuit();
    improc2.processing.updateAll %STARTED at 6:16pm for GFP_ser1, ended 6:29pm = 13min. That was for default thresholds.
  
end