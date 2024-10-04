function dirOI = makeDir(dirOI)

if ~exist(dirOI, 'dir')
    mkdir(dirOI)
end