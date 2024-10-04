function [ALLEEG, EEG, cfg] = signal_browsing_spectrum_topo(ALLEEG, EEG, cfg, params)

global paramsGlobal

[resultsDir, ~, cfg] = initialise(cfg, 'signalBrowsingSpecTopo'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

icacomp = 1;
superpose = 0;
reject = 0;

while true
    h = {}; % Figures handles
    
    %% Signal Browsing (needs pop_comments)
    pop_eegplot(originalEEG, icacomp, superpose, reject);
    h{1} = gcf;
    drawnow;
    save_fig(h, resultsDir, 'signalBrowsing');
    
    if cfg.interactive
        uiwait();
        redo = questdlg('Would you like to redo the processing block?', '','Yes','No', 'No');
        if strcmp(redo, 'No')
            break
        end % if strcmp(redo, 'No')
    else
        %         save_fig(h, resultsDir);
        for i = 1 : length(h)
            close(h{i});
        end
        break
    end
end % while true

EEG.comments = pop_comments(EEG.comments,'','Browsing signal',1); % For Signal Browsing

dataflag = 1;
process = 'EEG';
timerange = [];

while true
    params = paramsGlobal;
    h = {}; % Figures handles
    
    %% Spectrum Topography
    freqIdx = find(strcmp(params, 'freq'));
    if isempty(params{freqIdx + 1})
        [spectopo_outputs] = pop_spectopo(EEG, dataflag, timerange, process, 'plot', 'off');
        [~, idx] = findpeaks(mean(spectopo_outputs));
        params{freqIdx + 1} = idx - 1;
    end
    
    freqrangeIdx = find(strcmp(params, 'freqrange'));
    if isempty(params{freqrangeIdx + 1})
        params{freqrangeIdx + 1} = [0, EEG.srate/2];
    end
    
    h{1} = figure('units','normalized','outerposition',[0 0 1 1], 'visible','off');
    drawnow;
    pop_spectopo_mod(EEG, dataflag, timerange, process, params{:}); % Modified not to display figures on the fly
    drawnow;
    
    save_fig(h, resultsDir, 'spectopo');
    
    if cfg.interactive
        uiwait();
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

EEG.comments = pop_comments(EEG.comments,'','Spectopo performed',1); % For Spectrum Topography

function save_fig(h, resultsDir, figName)
saveas(h{1}, fullfile(resultsDir, figName), 'png');

%% Saving parameters
% required = {'electrodes', 'on', ...
%     'freq', [], ...
%     'freqrange', []};
% optional = {};
% pathSave = '...\utilities\processing elements\signal_browsing_spectrum_topo.mat';
% save(pathSave, 'required', 'optional')
