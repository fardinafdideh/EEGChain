function [ALLEEG, EEG, cfg] = low_pass_filter(ALLEEG, EEG, cfg, params)

global paramsGlobal


[resultsDir, dataName, cfg] = initialise(cfg, 'lowpass'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

%%
while true
    params = paramsGlobal;
    EEG = pop_eegfiltnew(originalEEG, params{:});
    h = gcf;
    drawnow
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
idx = find(strcmp(params, 'hicutoff'));
EEG.comments = pop_comments(EEG.comments,'', ['Low-pass filter applied: cutoff ',num2str(params{idx + 1}),'Hz'],1);

EEG.elapsedTime = toc(cfg.initTime);

[ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set

%%
function save_fig(h, resultsDir)
% export_fig(fullfile(resultsDir, 'Highpass filter frequency response'), '-png', '-nocrop');
saveas(h, fullfile(resultsDir, 'Lowpass filter frequency response'), 'png');

%% Saving parameters
% required = {'hicutoff', 30}; % - higher edge of the frequency pass band (Hz) {[]/0 -> highpass}
% optional = {%'filtorder', '?', ... - - filter order (filter length - 1). Mandatory even
%     'revfilt', 0, ... - [0|1] invert filter (from bandpass to notch filter) {default 0 (bandpass)}
%     'plotfreqz', 1, ... - [0|1] plot filter's frequency and phase response {default 0}
%     'minphase', 0, ... - scalar boolean minimum-phase converted causal filter {default false}
%     'usefftfilt', 0, ... - [0|1] scalar boolean use fftfilt frequency domain filtering {default false or 0}
%     };
% pathSave = '...\utilities\processing elements\high_pass_filter.mat';
% save(pathSave, 'required', 'optional')
