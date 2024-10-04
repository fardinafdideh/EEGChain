function [removedEpochsChans, independentChan] = findRemovedEpochsChannels(originalEEG, EEG, independentChan)

removedEpochsChans = cell(2, 1);

%% Epochs
removedEpochs = size(originalEEG.data, 2) - size(EEG.data, 2);
removedEpochsChans{1} = num2str(removedEpochs);

%% Channels
removedChansIdx = ~ismember({originalEEG.chanlocs(:).labels}, {EEG.chanlocs(:).labels});
if any(removedChansIdx)
    removedEpochsChans{2} = strjoin({originalEEG.chanlocs(removedChansIdx).labels},', '); 
    independentChan = independentChan - length(find(removedChansIdx));
else
    removedEpochsChans{2} = 'Nothing';
end 
