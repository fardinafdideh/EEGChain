src_file_set = 'F:\EEGLAB\eeglab2024.0\sample_data\eeglab_data.set';
src_file_fdt = 'F:\EEGLAB\eeglab2024.0\sample_data\eeglab_data.fdt';
files = [];
files.name = [];
files.folder = [];
for i = 1 : 100
    files(i).name = ['eeglab_data_',num2str(i),'.set'];
    files(i).folder = ['F:\EEGLAB\sample_data\dir_',num2str(i),''];
    mkdir(files(i).folder)
    copyfile(src_file_set, fullfile(files(i).folder, files(i).name));
    copyfile(src_file_fdt, fullfile(files(i).folder, ['eeglab_data_',num2str(i),'.fdt']));
end
save('F:\EEGLAB\sample_data\dataPaths.mat', 'files')