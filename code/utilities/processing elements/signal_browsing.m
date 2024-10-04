function [ALLEEG, EEG, cfg] = signal_browsing(ALLEEG, EEG, cfg, params)

[resultsDir, dataName, cfg] = initialise(cfg, 'signalBrowsing'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

icacomp = 1;
superpose = 0;
reject = 0;

%%
while true
    pop_eegplot(originalEEG, icacomp, superpose, reject);
    h = gcf;
    save_fig(h, resultsDir);
    
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
EEG.comments = pop_comments(EEG.comments,'','Browsing signal',1);

% [ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set

%%
function save_fig(h, resultsDir)
% savefig(fullfile(resultsDir, 'signalBrowsing.fig'))
saveas(h, fullfile(resultsDir, 'signalBrowsing'), 'png');

%% Saving parameters
% required = {};
% optional = {};
% pathSave = '...\utilities\processing elements\signal_browsing.mat';
% save(pathSave, 'required', 'optional')
