function [ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir)

[ALLEEG, EEG] = pop_newset(ALLEEG, EEG, 1, 'setname', dataName,...
    'savenew', fullfile(resultsDir, dataName), 'overwrite', 'on', 'gui', 'off');
EEG.comments = pop_comments(EEG.comments, '', ['',dataName,'.set was saved in the user-specified data directory.'], 1);
EEG = eeg_checkset(EEG);
