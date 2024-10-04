function [ALLEEG, EEG, cfg] = rereferencing(ALLEEG, EEG, cfg, params)

global paramsGlobal

[resultsDir, dataName, cfg] = initialise(cfg, 'reref'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

%%
while true
    params = paramsGlobal;
    EEG = pop_reref(originalEEG, params{:});
    if isempty(params{1}) % CAR
        cfg.independentChan = cfg.independentChan - 1;
    end
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
EEG.comments = pop_comments(EEG.comments,'','Re-referencing',1);

EEG.elapsedTime = toc(cfg.initTime);

[ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set

%% Saving parameters
% required = {'ref', []};
% optional = {'interpchan', 'off', ... - [channel location structure | integer array | [] | 'off']. Channels to interpolate prior to re-referencing the data. If [], channels will be found by comparing all the channels (type = EEG) in the current EEG.chanlocs structure against EEG.urchanlocs. A channel location  structure of the channels to be interpolated can be provided as an input, as well as the index of the channels into the EEG.urchanlocs.Default:'off'
%     'exclude', [], ... - [integer array] List of channels to exclude. Default: none.
%     'keepref', 'off', ... - ['on'|'off'] keep the reference channel. Default: 'off'.
% %     'refloc', 'none', ... - [structure] Previous reference channel structure. Default: none.
%     };
% pathSave = '...\utilities\processing elements\rereferencing.mat';
% save(pathSave, 'required', 'optional')
