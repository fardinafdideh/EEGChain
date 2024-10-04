function [resultsDir, dataName, cfg] = initialise(cfg, newProc) 

resultsDir = cfg.resultsDir;
% dataName = [cfg.dataName, '_', newProc];
dataName = newProc;
cfg.dataName = dataName;
dataName = ['step ', num2str(cfg.step), '__', dataName];
cfg.step = cfg.step + 1;
resultsDir = makeDir(fullfile(resultsDir, dataName)); % Make directory
