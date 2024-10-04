function [ALLEEG, EEG, cfg] = channel_interp(ALLEEG, EEG, cfg, params)

global paramsGlobal

[resultsDir, dataName, cfg] = initialise(cfg, 'chanInterp'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

%%
chanOrig = cfg.originalEEGChanlocsLabels;

while true
    params = paramsGlobal;
    EEG = pop_interp(originalEEG, chanOrig, params{:});
    h = figure;
    if cfg.interactive
        uiwait()
        redo = questdlg('Would you like to redo the processing block?', '','Yes','No', 'No');
        if strcmp(redo, 'No')
            break
        end % if strcmp(redo, 'No')
    else
        close(h)
        break
    end
end % while true

%%
chanLabelOrig = {chanOrig.labels};
chanLabelNow = {EEG.chanlocs.labels};
interpIdx = ~ismember(chanLabelOrig, chanLabelNow);
interpChans = {chanLabelOrig{interpIdx}};
EEG.comments = pop_comments(EEG.comments,'',['Interpolated channels: ' strjoin(interpChans,', ')],1);

EEG.elapsedTime = toc(cfg.initTime);

[ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set

%% Saving parameters
% required = {'method', 'spherical'};
% optional = {};
% pathSave = '...\utilities\processing elements\channel_interp.mat';
% save(pathSave, 'required', 'optional')
