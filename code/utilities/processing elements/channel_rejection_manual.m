function [ALLEEG, EEG, cfg] = channel_rejection_manual(ALLEEG, EEG, cfg, params)

[resultsDir, dataName, cfg] = initialise(cfg, 'chanRejMan'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

%%
while true
    EEG = pop_rejchan(originalEEG); % reject artifacts channels in an EEG dataset using joint probability of the recorded electrode.
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
EEG.comments = pop_comments(EEG.comments,'',['Removed channels with pop_rejchan(): ', removedEpochsChans{2}, ''], 1);

EEG.elapsedTime = toc(cfg.initTime);

[ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set

%% Saving parameters
% required = {};
% optional = {};
% pathSave = '...\utilities\processing elements\channel_rejection_manual.mat';
% save(pathSave, 'required', 'optional')
