function [ALLEEG, EEG, cfg] = ica(ALLEEG, EEG, cfg, params)

global paramsGlobal

[resultsDir, dataName, cfg] = initialise(cfg, 'ica'); % Initialise variables

searchParams = {'icatype', 'extended', 'stop'};

originalEEG = EEG; % Store an original copy needed for redoing the rejection process

%%
while true
    params = paramsGlobal;
    
    paramsICA = cell(1, 2*length(searchParams));
    for i = 1 : length(searchParams)
        idx = find(strcmp(params, searchParams{i}));
        paramsICA{2*i - 1} = searchParams{i};
        paramsICA{2*i} = params{idx + 1};
    end
    
    h = {}; % Figures handles
    EEG = pop_runica(originalEEG, 'pca', cfg.independentChan, 'interrupt', 'on', paramsICA{:}); % Needs pop_comments
    
    EEG.elapsedTime = toc(cfg.initTime);
    
    [ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set
    
    EEG = iclabel(EEG);
    
    [amp, ind] = max(EEG.etc.ic_classification.ICLabel.classifications, [], 2); % {'Brain'  'Muscle'  'Eye'  'Heart'  'Line Noise'  'Channel Noise'  'Other'}
    
    noisyCompThrIdx = find(strcmp(params, 'noisyCompThr'));
    artICsVal = false(size(ind));
    for i = 1 : length(artICsVal)
        artICsVal(i) = amp(i) > params{noisyCompThrIdx + 1}(ind(i));
    end
    
    noisyCompLabelIdx = find(strcmp(params, 'noisyCompLabel'));
    noisyCompLabel = params{noisyCompLabelIdx + 1};
    noisyCompLabel = find(noisyCompLabel);
    artICsLabel = false(size(ind));
    for i = 1 : length(noisyCompLabel)
        artICsLabel = or(artICsLabel, ind == noisyCompLabel(i));
    end
    
    rejectIdx = find(and(artICsLabel, artICsVal)); % Change following pop_comments correspondingly
    EEG.reject.gcompreject(rejectIdx) = 1; % Needs EEG.comments
    
    EEG = pop_selectcomps(EEG, 1:size(EEG.icaweights,1));
    h{1} = gcf;
    drawnow
    
    for i = 1 : size(EEG.icaweights, 1)
        if exist('pop_prop_extended', 'file')
            pop_prop_extended(EEG, 0, i, NaN, {}, {}, 1, 'ICLabel'); % , typecomp, chanorcomp, winhandle, spec_opt, erp_opt, scroll_event, classifier_name, varargin
        elseif exist('pop_prop', 'file')
            pop_prop(EEG, 0, i, NaN, {}); % , typecomp, chanorcomp, winhandle, spec_opt, erp_opt, scroll_event, classifier_name, varargin
        end
        h{end+1} = gcf;
        drawnow
    end
    
    if ~isempty(rejectIdx)
        EEG = pop_subcomp_noPop(EEG, rejectIdx, 1);
        h{end+1} = gcf;
    end
    
    if cfg.interactive
        uiwait()
        redo = questdlg('Would you like to redo the processing block?', '','Yes','No', 'No');
        if strcmp(redo, 'No')
            save_fig(h, size(EEG.icaweights, 1), resultsDir);
            break
        else
            for i = 1 : length(h)
                try
                    close(h{i})
                catch
                    disp('An error was handled!')
                end
            end
        end % if strcmp(redo, 'No')
    else
        save_fig(h, size(EEG.icaweights, 1), resultsDir);
        break
    end
end % while true

%%
EEG.comments = pop_comments(EEG.comments,'',['ICA performed. PCA: ',num2str(cfg.independentChan),''],1); % For pop_runica

EEG.comments = pop_comments(EEG.comments,'', ... % For EEG.reject.gcompreject
    ['Threshold for artifact IC removal: Brain',num2str(params{noisyCompThrIdx + 1}(1)*100),...
    '%, Muscle',num2str(params{noisyCompThrIdx + 1}(2)*100),...
    '%, Eye',num2str(params{noisyCompThrIdx + 1}(3)*100),...
    '%, Heart',num2str(params{noisyCompThrIdx + 1}(4)*100),...
    '%, Line Noise',num2str(params{noisyCompThrIdx + 1}(5)*100),...
    '%, Channel Noise',num2str(params{noisyCompThrIdx + 1}(6)*100),...
    '%, Other',num2str(params{noisyCompThrIdx + 1}(7)*100),'%.'],1);

if ~isempty(rejectIdx)
    EEG = eeg_checkset(EEG);
    EEG.comments = pop_comments(EEG.comments,'',['Rejected ICs: ', char(strjoin(string(rejectIdx),', ')),''],1);
end

EEG.elapsedTime = toc(cfg.initTime);

[ALLEEG, EEG] = saveSet(ALLEEG, EEG, [dataName, '_removedIC'], resultsDir); % Save and comment EEG set

%%
function save_fig(h, IcNb, resultsDir)
% export_fig(fullfile(resultsDir, 'allComps'), '-png', '-nocrop');
saveas(h{1}, fullfile(resultsDir, 'allComps'), 'png');

for i = 1 : IcNb
    %     export_fig(fullfile(resultsDir,['IC_',num2str(i),'']), '-png', '-nocrop');
    saveas(h{i+1}, fullfile(resultsDir,['IC_',num2str(i),'']), 'png');
end
if length(h) == IcNb+2
    saveas(h{end}, fullfile(resultsDir, 'Signal before and after artifact IC removal'), 'png');
end

for i = 1 : length(h)
    try
        close(h{i})
    catch
        disp('An error was handled!')
    end
end

%% Saving parameters
% required = {'icatype', 'runica', ...
%     'extended', 1, ...
%     'stop', 1e-7, ...
%     'noisyCompThr', [0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9], ...
%     'noisyCompLabel', [0, 1, 1, 1, 1, 1, 0]};
% optional = {};
% pathSave = '...\utilities\processing elements\ica.mat';
% save(pathSave, 'required', 'optional')
