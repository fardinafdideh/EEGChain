function [ALLEEG, EEG, cfg] = epoch_channel_rejection_manual(ALLEEG, EEG, cfg, params)

[resultsDir, dataName, cfg] = initialise(cfg, 'epochChanRejMan'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

%% Epoch & Channel Rejection
while true
    EEG = pop_select(originalEEG); % retaining and/or excluding specified time/latency, data point, channel, and/or epoch range(s).
    if cfg.interactive
        uiwait()
        redo = questdlg('Would you like to redo the processing block?', '','Yes','No', 'No');
        if strcmp(redo, 'No')
            break
        end % if strcmp(redo, 'No')
    else
        break
    end
end % while true

%%
[removedEpochsChans, cfg.independentChan] = findRemovedEpochsChannels(originalEEG, EEG, cfg.independentChan);
EEG.comments = pop_comments(EEG.comments,'',['Removed epochs with pop_select(): ', removedEpochsChans{1}, ' epochs'], 1);
EEG.comments = pop_comments(EEG.comments,'',['Removed channels with pop_select(): ', removedEpochsChans{2}, ''], 1);

EEG.elapsedTime = toc(cfg.initTime);

[ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set

%% Saving parameters
% required = {};
% optional = {};
% pathSave = '...\utilities\processing elements\epoch_channel_rejection_manual.mat';
% save(pathSave, 'required', 'optional')
