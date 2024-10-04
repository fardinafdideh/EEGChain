function [ALLEEG, EEG, cfg] = line_noise_removal(ALLEEG, EEG, cfg, params)
% https://github.com/sccn/cleanline
% [Eeglablist] CleanLine plugin not removing 60hz noise?
% (https://sccn.ucsd.edu/pipermail/eeglablist/2020/015126.html)

global paramsGlobal

[resultsDir, dataName, cfg] = initialise(cfg, 'lineNoiseRemoved'); % Initialise variables

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

%%
while true
    params = paramsGlobal;
    
    ChanCompIndicesIdx = find(strcmp(params, 'ChanCompIndices'));
    if isempty(params{ChanCompIndicesIdx + 1})
        params{ChanCompIndicesIdx + 1} = 1:originalEEG.nbchan;
    end
    
    EEG = pop_cleanline(originalEEG, params{:});
    PlotFiguresIdx = find(strcmp(params, 'PlotFigures'));
    save_fig(params{PlotFiguresIdx + 1}, EEG.nbchan, resultsDir);
    if cfg.interactive
        uiwait()
        redo = questdlg('Would you like to redo the processing block?', '','Yes','No', 'No');
        if strcmp(redo, 'No')
            break
        end % if strcmp(redo, 'No')
    else
        close
        break
    end
end % while true

%%
EEG.comments = pop_comments(EEG.comments,'','Line noise was removed using pop_cleanline()',1);

EEG.elapsedTime = toc(cfg.initTime);

[ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set


function save_fig(isPlot, nbchan, resultsDir)
if isPlot
    for i = nbchan : -1 : 1
        %        export_fig(fullfile(resultsDir,['chan_',num2str(i),'']), '-png', '-nocrop');
        saveas(gcf, fullfile(resultsDir,['chan_',num2str(i),'']), 'png');
        close
    end
    %     export_fig(fullfile(resultsDir,'windowOvlpSmoothFn'), '-png', '-nocrop');
    saveas(gcf, fullfile(resultsDir,'windowOvlpSmoothFn'), 'png');
end

%% Saving parameters
% required = {'LineFrequencies',[50 100], ...
%     'ScanForLines',true, ...
%     'LineAlpha',0.01, ...
%     'Bandwidth',2, ...
%     'SignalType','Channels', ...
%     'ChanCompIndices',[] , ...
%     'SlidingWinLength', 4, ... EEG.pnts/EEG.srate
%     'SlidingWinStep', 4, ... EEG.pnts/EEG.srate
%     'SmoothingFactor',100, ...
%     'PaddingFactor',2, ...
%     'PlotFigures',true, ...
%     'ComputeSpectralPower',true, ...
%     'NormalizeSpectrum',false, ...
%     'VerbosityLevel',1, ...
%     };
% optional = {};
% pathSave = '...\utilities\processing elements\line_noise_removal.mat';
% save(pathSave, 'required', 'optional')