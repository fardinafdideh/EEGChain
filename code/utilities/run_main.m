clc
diary off
diary(fullfile(cd, 'diary3.txt'))
tic
main
disp(['elapsed time: ',num2str(toc),''])
diary off