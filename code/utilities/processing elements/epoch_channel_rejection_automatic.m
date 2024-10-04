function [ALLEEG, EEG, cfg] = epoch_channel_rejection_automatic(ALLEEG, EEG, cfg, params)

global paramsGlobal

[resultsDir, dataName, cfg] = initialise(cfg, 'epochChanRejAuto'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

%% Epoch & Channel Rejection
while true
    params = paramsGlobal;
    [EEG, isFigure] = pop_clean_rawdata_vis(originalEEG, params{:}); % retaining and/or excluding specified time/latency, data point, channel, and/or epoch range(s).
    save_fig(isFigure, resultsDir);
    if cfg.interactive
        uiwait()
        redo = questdlg('Would you like to redo the processing block?', '','Yes','No', 'No');
        if strcmp(redo, 'No')
            break
        end
    else
        if ~isempty(isFigure)
            close(isFigure)
        end
        break
    end
end % while true

%%
[removedEpochsChans, cfg.independentChan] = findRemovedEpochsChannels(originalEEG, EEG, cfg.independentChan);
EEG.comments = pop_comments(EEG.comments,'',['Removed epochs with pop_clean_rawdata(): ', removedEpochsChans{1}, ' epochs'], 1);
EEG.comments = pop_comments(EEG.comments,'',['Removed channels with pop_clean_rawdata(): ', removedEpochsChans{2}, ''], 1);

EEG.elapsedTime = toc(cfg.initTime);

[ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set

%%
function save_fig(isFigure, resultsDir)
if ~isempty(isFigure)
    %         savefig(fullfile(resultsDir, 'cleaned.fig'))
    saveas(isFigure, fullfile(resultsDir, 'cleaned'), 'png');
end % if isFigure

%% Saving parameters
% required = {
%     'Highpass','off',...
%     'FlatlineCriterion',5,...
%     'LineNoiseCriterion',4,...
%     'ChannelCriterion',0.800000000000000,...
%     'BurstCriterion',20,...
%     'Distance','Euclidian',...
%     'WindowCriterionTolerances',[-Inf,7],...
%     'WindowCriterion',0.250000000000000,...
%     'BurstRejection','on'
%     };
% optional = {};
% pathSave = '...\utilities\processing elements\epoch_channel_rejection_automatic.mat';
% save(pathSave, 'required', 'optional')
