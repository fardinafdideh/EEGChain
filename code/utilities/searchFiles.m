function files = searchFiles(searchPath, searchWords, extension)

files = [];
for i = 1 : length(searchWords)
    files = [files; dir(fullfile(searchPath, '**', ['*',searchWords{i},'*.',extension,'']))];
end

[~, ia] = unique(cellfun(@num2str, strcat({files.folder}, {filesep}, {files.name}),'uni', 0));
repeated = ~ismember(1:length(files), ia); % Repeated
files(repeated) = [];

% Remove the following data, because it is too noisy
files(strcmp({files.name}, 'X.edf')) = [];

% Remove when there is baste or baz next to asli or task
files(cellfun(@(x)~isempty(x), cellfun(@(x)strfind(x, 'bast'), {files.name}, 'UniformOutput', false))) = [];
% Couldn't use the following because there was 'X.edf'. So removed manually
% files(cellfun(@(x)~isempty(x), cellfun(@(x)strfind(x, 'baz'), {files.name}, 'UniformOutput', false))) = [];
files(strcmp({files.name}, 'X.edf')) = [];

save(fullfile(searchPath, 'taskPaths'), 'files')