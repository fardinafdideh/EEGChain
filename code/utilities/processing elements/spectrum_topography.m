function [ALLEEG, EEG, cfg] = spectrum_topography(ALLEEG, EEG, cfg, params)

global paramsGlobal

[resultsDir, ~, cfg] = initialise(cfg, 'spectopo'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

dataflag = 1;
process = 'EEG';
timerange = [];

%%
while true
    params = paramsGlobal;
    h = {}; % Figures handles
    
    freqIdx = find(strcmp(params, 'freq'));
    if isempty(params{freqIdx + 1})
        figure
        [spectopo_outputs] = pop_spectopo(EEG, dataflag, timerange, process);
        close
        [~, idx] = findpeaks(mean(spectopo_outputs));
        params{freqIdx + 1} = idx - 1;
    end
    
    freqrangeIdx = find(strcmp(params, 'freqrange'));
    if isempty(params{freqrangeIdx + 1})
        params{freqrangeIdx + 1} = [0, EEG.srate/2];
    end
    
    h{1} = figure('units','normalized','outerposition',[0 0 1 1]);
    drawnow
    pop_spectopo(originalEEG, dataflag, timerange, process, params{:});
    drawnow
    save_fig(h, resultsDir);
    if cfg.interactive
        uiwait()
        redo = questdlg('Would you like to redo the processing block?', '','Yes','No', 'No');
        if strcmp(redo, 'No')
            break
        end % if strcmp(redo, 'No')
    else
        for i = 1 : length(h)
            close(h{i});
        end
        break
    end
end % while true

%%
EEG.comments = pop_comments(EEG.comments,'','Spectopo performed',1);

%%
function save_fig(h, resultsDir)
% export_fig(fullfile(resultsDir, 'spectopo'), '-png', '-nocrop');
saveas(h{1}, fullfile(resultsDir, 'spectopo'), 'png');

%% Saving parameters
% required = {'electrodes', 'on', ...
%     'freq', [], ...
%     'freqrange', []};
% optional = {};
% pathSave = '...\utilities\processing elements\spectrum_topography.mat';
% save(pathSave, 'required', 'optional')
