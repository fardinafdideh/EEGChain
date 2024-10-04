function varargout = eegchain(varargin)
% EEGCHAIN MATLAB code for eegchain.fig
%      EEGCHAIN, by itself, creates a new EEGCHAIN or raises the existing
%      singleton*.
%
%      H = EEGCHAIN returns the handle to a new EEGCHAIN or the handle to
%      the existing singleton*.
%
%      EEGCHAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEGCHAIN.M with the given input arguments.
%
%      EEGCHAIN('Property','Value',...) creates a new EEGCHAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eegchain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eegchain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eegchain

% Last Modified by GUIDE v2.5 02-Oct-2024 14:39:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @eegchain_OpeningFcn, ...
    'gui_OutputFcn',  @eegchain_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before eegchain is made visible.
function eegchain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eegchain (see VARARGIN)

% Choose default command line output for eegchain
handles.output = hObject;

clc
%%
path_current = matlabpath;
% Check if the toolbox directory is present in the path
if ~any(strfind(path_current, 'eeglab'))
    eeglabDir = uigetdir('C:\', 'EEGLAB not found in the MATLAB path! Select the EEGLAB''s root directory!');
%     addpath(eeglabDir)
%     feval(fullfile(eeglabDir, 'eeglab.m'))
eegChainDir = pwd;
cd(eeglabDir)
 eeglab nogui
cd(eegChainDir)
    [~,name,ext] = fileparts(eeglabDir);
    eeglabVer = [name,ext];
else
    eeglabDir = fileparts(which('eeglab'));
    [~,name,ext] = fileparts(eeglabDir);
    eeglabVer = [name,ext];
end

handles.rawDataDir = fullfile(eeglabDir, 'sample_data');

addpath(genpath(fullfile(pwd, 'utilities')))
comments = {};
comments = [comments; ['EEGLAB ver. ',eeglabVer,'']];
eeglab
close

handles.processingConfigName = 'Unknown';

option_singleVal = 0;
pop_editoptions('option_single', option_singleVal);
comments = [comments; ['option_single set to ',num2str(option_singleVal),'']];
handles.comments = comments;

%%
pipelineElementsPath = fullfile(pwd, 'utilities', 'processing elements');
ProcessingElements = dir(fullfile(pipelineElementsPath, '*.m'));
ProcessingElementsCell = cellfun(@(x)(x(1:end-2)), {ProcessingElements([ProcessingElements.isdir] == 0).name}, 'UniformOutput', false);
for i = 1 : length(ProcessingElementsCell)
    matPath = fullfile(pipelineElementsPath, [ProcessingElementsCell{i}, '.mat']);
    if exist(matPath, 'file')
        handles.defaultParameters.(ProcessingElementsCell{i}) = load(matPath);
    end
end

handles.chanLocFilePath = [];
handles.dataPath = [];

handles.listbox1.String = ProcessingElementsCell;
handles.processingTypeIdx = 1;
handles.pipelineElements = [];
handles.pipelineElementIdx = 1;
handles.dataPath = [];
handles.dataPathIdx = 1;
handles.edit1.String = [];
set(handles.edit1, 'Min', 0, 'Max', 2, 'horizontalAlignment', 'left');
handles.edit2.String = 'Unknown';
handles.pushbutton1.String = '>';
handles.pushbutton1.FontSize = 12;
handles.pushbutton1.FontWeight = 'bold';
handles.pushbutton2.String = '<';
handles.pushbutton2.FontSize = 12;
handles.pushbutton2.FontWeight = 'bold';
handles.pushbutton10.String = '^';
handles.pushbutton10.FontSize = 12;
handles.pushbutton10.FontWeight = 'bold';
handles.pushbutton11.String = 'v';
handles.pushbutton11.FontSize = 12;
handles.pushbutton11.FontWeight = 'bold';
handles.pushbutton3.String = 'Start';
handles.pushbutton4.String = 'Load';
handles.pushbutton5.String = 'Open';
handles.pushbutton3.Enable = 'off';
handles.pushbutton5.Enable = 'off';
handles.pushbutton7.Enable = 'off';
handles.pushbutton8.String = 'Load';
handles.uipanel1.Title = 'EEGChain: EEGLAB-based Toolbox for Building, Managing, Automating, and Reproducing Batch EEG Processing Pipelines';
handles.text2.String = 'Processing Blocks';
handles.text3.String = 'Processing Pipeline';
handles.text4.String = 'Parameters';
handles.text5.String = 'Raw Data Paths';
handles.text6.String = 'Config. Name';
handles.processingTypeIdx = 1;
handles.pipelineElements = [];
handles.pipelineElementsParams = [];
handles.pipelineElementIdx = 0;
handles.interactive = 1;
set(handles.checkbox1, 'Value', handles.interactive)
handles.dataPath = [];
handles.currentDataPath = [];
handles.dataPathIdx = 1;

handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);
handles = update(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eegchain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eegchain_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
handles.processingTypeIdx = hObject.Value;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

if isempty(hObject.Value)
    handles.pipelineElementIdx = 0;
else
    handles.pipelineElementIdx = hObject.Value;
end
try % Removes step number
    handles.pipelineElements = cellfun(@(x)x(end), cellfun(@(x)strsplit(x, '-'), hObject.String, 'UniformOutput', false));
catch
    handles.pipelineElements = hObject.String;
end
handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);
handles = update(handles); % update params

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

processingTypeIdx = handles.processingTypeIdx;
processingType = handles.listbox1.String(processingTypeIdx);

tmp = handles.pipelineElements;
tmp{end + 1} = nan;
tmp(handles.pipelineElementIdx + 2 : end) = tmp(handles.pipelineElementIdx + 1 : end - 1);
tmp(handles.pipelineElementIdx + 1) = processingType;
handles.pipelineElements = tmp;

params = [];
params.required = handles.defaultParameters.(processingType{1}).required;
params.optional = handles.defaultParameters.(processingType{1}).optional;

tmp = handles.pipelineElementsParams;
tmp{end + 1} = nan;
tmp(handles.pipelineElementIdx + 2 : end) = tmp(handles.pipelineElementIdx + 1 : end - 1);
tmp(handles.pipelineElementIdx + 1) = {params};
handles.pipelineElementsParams = tmp;

% handles.pipelineElements = [handles.pipelineElements ; processingType];
handles.pipelineElementIdx = handles.pipelineElementIdx + 1;
handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);
handles = update(handles);
guidata(hObject,handles)

function params = update_paramsList(pipelineElementsParams, pipelineElementIdx)
if pipelineElementIdx > 0
    required = arrange_parameters(pipelineElementsParams{pipelineElementIdx}.required);
    optional = arrange_parameters(pipelineElementsParams{pipelineElementIdx}.optional);
    params = [required, optional];
else
    params = [];
end
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% pipelineElementIdx = handles.pipelineElementIdx;
if isempty(handles.pipelineElements)
    return
end
handles.pipelineElements(handles.listbox2.Value) = [];
handles.pipelineElementsParams(handles.listbox2.Value) = [];
handles.pipelineElementIdx = max([0, handles.pipelineElementIdx-1]);
handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);
handles = update(handles);
guidata(hObject,handles)


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
contents = cellstr(get(hObject,'String'));
handles.dataPathIdx = get(hObject, 'Value');
if handles.dataPathIdx > 0
    handles.currentDataPath = contents{handles.dataPathIdx};
end
handles = update(handles);

% handles.currentDataPath = handles.listbox3.String{handles.listbox3.Value};
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
params = get(hObject,'String');
func = handles.pipelineElements{handles.pipelineElementIdx};
handles.pipelineElementsParams{handles.pipelineElementIdx} = update_params(params, handles.defaultParameters.(func));
handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);

global paramsGlobal
paramsGlobal = paramsArrangement(handles.pipelineElementsParams{handles.pipelineElementIdx}, ...
    handles.pipelineElements{handles.pipelineElementIdx});

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = update(handles)
handles.listbox2.String = cell(length(handles.pipelineElements), 1);
for i = 1 : length(handles.pipelineElements)
    handles.listbox2.String{i} = ['',num2str(i),'-',handles.pipelineElements{i},''];
end
if handles.pipelineElementIdx > 0
    handles.listbox2.Value = handles.pipelineElementIdx;
end
handles.edit1.String = handles.params;
handles.listbox1.Value = handles.processingTypeIdx;
set(handles.edit2,'String', handles.processingConfigName);
set(handles.checkbox1, 'Value', handles.interactive)
handles.listbox3.String = handles.dataPath;
handles.listbox3.Value = handles.dataPathIdx;
if isempty(handles.dataPath)
    handles.text5.String = 'Raw Data Paths (0/0)';
else
    handles.text5.String = ['Raw Data Paths (',num2str(handles.dataPathIdx),'/',num2str(length(handles.dataPath)),')'];
end


function parameters_pair = arrange_parameters(parameters)
parameters_pair = cell(1, length(parameters)/2);
for i = 1 : 2 : length(parameters)
    if isempty(parameters{i+1})
        parameters_pair{(i + 1)/2} = [parameters{i}, ' = ', '[]'];
    elseif isnumeric(parameters{i+1}) % numeric
        if length(parameters{i+1}) == 1
            parameters_pair{(i + 1)/2} = [parameters{i}, ' = ', num2str(parameters{i+1})];
        else
            parameters_pair{(i + 1)/2} = [parameters{i}, ' = [', num2str(parameters{i+1}), ']'];
        end
    elseif islogical(parameters{i+1}) % numeric
        parameters_pair{(i + 1)/2} = [parameters{i}, ' = ', num2str(double(parameters{i+1}))];
    elseif iscellstr(parameters{i+1}) % cell string
        error('To be completed')
    elseif iscell(parameters{i+1}) % cell
        error('To be completed')
    elseif ~isempty(parameters{i+1}) % string
        parameters_pair{(i + 1)/2} = [parameters{i}, ' = ', parameters{i+1}];
    end
end


function updatedParams = update_params(newParams, currentParams)
updatedParams = currentParams;
currentParamsFields = fields(currentParams);
for i = 1 : length(currentParamsFields)
    params = currentParams.(currentParamsFields{i});
    for j = 1 : 2 : length(params) - 1 % Current params
        newParams = cellfun(@(x)(split(x, '=')), newParams, 'UniformOutput', false);
        paramSel = cellfun(@(x)(any(strcmp(strtrim(x), strtrim(params{j})))), newParams);
        newValue = strtrim(newParams{paramSel}{2});
        if ~isnan(str2double(newValue)) % scalar
            params{j+1} = str2double(newValue);
        elseif newValue(1) == '[' || newValue(1) == '{' % sets (matrix, cell)
            params{j+1} = eval(newValue);
        else % string
            params{j+1} = newValue;
        end
    end
    updatedParams.(currentParamsFields{i}) = params;
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.dataPath) && ~isempty(handles.processingConfigName)
    handles.comments = [handles.comments; ['Processing config. name: ',handles.processingConfigName,'']];
    
    for i = 1 : length(handles.dataPath) % loops through dataset
        handles.initTime = tic;
        handles.dataPathIdx = i;
        handles.currentDataPath = handles.dataPath{handles.dataPathIdx};
        handles = update(handles);
        [handles.resultsDir, isDirExist] = resultDir_maker(handles.dataPath{i}, handles.processingConfigName);
        if isDirExist
            msg = ['There is already a folder for this dataset and configuration. Change the configuration name.'];
            warning(msg)
            if handles.interactive
                warndlg(msg, 'Warning') % Commented to allow the pipeline to run smoothly without stop
            end
            continue % Skips
        end
        [ALLEEG, EEG, handles.originalEEGChanlocsLabels] = load_data(handles.processingConfigName, handles.chanLocFilePath, handles.dataPath{i}, handles.comments, handles.resultsDir);
        if isempty(ALLEEG)
            continue
        end
        handles = run_pipeline(hObject,handles, ALLEEG, EEG, handles.pipelineElements, ...
            handles.pipelineElementsParams, handles.originalEEGChanlocsLabels, handles.interactive, handles.resultsDir, handles.processingConfigName);
    end
    isempty(handles.processingConfigName)
end
if isempty(handles.dataPath)
    msg = 'Please select raw dataset!';
    warndlg(msg, 'Warning')
    warning(msg)
end
if isempty(handles.processingConfigName)
    msg = 'Please specify a name for configuration ("Config. Name")!';
    warndlg(msg, 'Warning')
    warning(msg)
end

guidata(hObject,handles)


function [resultsDir, isDirExist] = resultDir_maker(dataPath, processingConfigName)
[~, dataName] = fileparts(dataPath);
resultsDir = fullfile(pwd, 'results', dataName, ['config ', processingConfigName]);
if ~exist(resultsDir, 'dir')
    isDirExist = 0;
    mkdir(resultsDir)
else
    isDirExist = 1;
end


function handles = run_pipeline(hObject,handles, ALLEEG, EEG, pipelineElements, pipelineElementsParams, originalEEGChanlocsLabels, interactive, resultsDir, processingConfigName)

global paramsGlobal

cfg = [];
cfg.resultsDir = resultsDir;
cfg.dataName = ''; % dataName
cfg.step = 1;
cfg.interactive = interactive;
cfg.originalEEGChanlocsLabels = originalEEGChanlocsLabels;
% cfg.noisyCompThr = 0.9; % Threshold for IC rejection
cfg.initTime = handles.initTime;
cfg.independentChan = EEG.nbchan; % Needed for ICA, each time there is channel removal or CAR it will be decreased
for i = 1 : length(pipelineElements)
    handles.pipelineElementIdx = i;
    handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);
    handles = update(handles);
    params = paramsArrangement(pipelineElementsParams{i}, pipelineElements{i});
    
    paramsGlobal = paramsArrangement(handles.pipelineElementsParams{i}, handles.pipelineElements{i});
    eval(['[ALLEEG, EEG, cfg] = ', pipelineElements{i},'(ALLEEG, EEG, cfg, params);'])
    % if params are updated during interactive procedure
    
    switch handles.pipelineElements{i}
        case {'rereferencing', 'channel_interp'} % paired with paramsArrangement
            paramsGlobal = [handles.pipelineElementsParams{i}.required(1), paramsGlobal];
    end
    
    for ii = 1 : 2 : length(paramsGlobal)-1
        if any(strcmp(handles.pipelineElementsParams{i}.optional, paramsGlobal{ii}))
            idx = find(strcmp(handles.pipelineElementsParams{i}.optional, paramsGlobal{ii}));
            handles.pipelineElementsParams{i}.optional{idx+1} = paramsGlobal{ii+1};
        elseif any(strcmp(handles.pipelineElementsParams{i}.required, paramsGlobal{ii}))
            idx = find(strcmp(handles.pipelineElementsParams{i}.required, paramsGlobal{ii}));
            handles.pipelineElementsParams{i}.required{idx+1} = paramsGlobal{ii+1};
        end
    end
    
    if ~isempty(paramsGlobal)
        handles.params = arrange_parameters(paramsGlobal);
    else
        handles.params = [];
    end
    
    handles = update(handles);
end

pipelineElementsParams = handles.pipelineElementsParams;
pipelineElements = handles.pipelineElements;
save(fullfile(resultsDir, ['config_',processingConfigName,'.mat']), ...
    'pipelineElementsParams', 'pipelineElements', 'interactive')
guidata(hObject,handles)

function params = paramsArrangement(pipelineElementsParams, pipelineElements)
switch pipelineElements
    case {'rereferencing', 'channel_interp'}
        params = [pipelineElementsParams.required(2), pipelineElementsParams.optional];
    otherwise
        params = [pipelineElementsParams.required, pipelineElementsParams.optional];
end


% function [ALLEEG, EEG, dataName] = load_data(rawDataDir, processingConfig, locFilePath, locFile, comments)
function [ALLEEG, EEG, originalEEGChanlocsLabels] = load_data(processingConfig, locFilePath, dataFilePath, comments, resultsDir)
% dataFileExt = '.set';
% [dataFile,dataFilePath] = uigetfile(fullfile(rawDataDir, ['*', dataFileExt]),'Select EEG data file.');
% if dataFilePath ~= 0
%     if strcmp(dataFile(end - 2 : end), 'set')
% dataFile = split(dataFilePath, filesep);
[~, dataFileName, dataExt] = fileparts(dataFilePath);
comments = [comments; ['Raw dataset name: ',[dataFileName, dataExt],'']];
%         dataName = dataFile(1 : end - dataFileExtLen);
if strcmp(dataExt, '.set')
    EEG = pop_loadset('filename', dataFilePath); % , 'loadmode',
elseif strcmp(dataExt, '.edf')
    EEG = pop_biosig(dataFilePath, 'channels', 3:16);
end

% % To make sure there are enough channels in the beginning
% if EEG.nbchan ~= 14
%     msg = [dataFilePath, 'was discarded, because of the number of channels: ',num2str(EEG.nbchan),''];
%     comments = [comments; msg];
%     disp(msg)
%     [ALLEEG, EEG, originalEEGChanlocsLabels] = deal([], [], []);
%     return
% end

EEG.comments = pop_comments(EEG.comments,'', comments,1);
EEG.pipeline = processingConfig;
% if EEG.srate >= 1024 % Resample to 512 Hz if sample rate too high
%     EEG = pop_resample(EEG, 512);
%     EEG = eeg_checkset(EEG);
%     EEG.comments = pop_comments(EEG.comments,'','Resampled to 512 Hz',1);
%     % % %         dataName = [dataName '_resampled'];
% end
%%%%%%%%% Before adding channel info, check if it is not already loaded
% EEG=pop_chanedit(EEG, 'load',fullfile(locFilePath,locFile)); % Load channel locations
EEG=pop_chanedit(EEG, 'load', locFilePath); % Load channel locations
originalEEGChanlocsLabels = EEG.chanlocs; % Needed for channel interpolation
f = figure('visible', 'off');
topoplot([],EEG.chanlocs,'style','blank','electrodes','labelpoint','chaninfo',EEG.chaninfo);
% drawnow
cfg = [];
cfg.resultsDir = resultsDir;
cfg.dataName = ''; % dataName
cfg.step = 0;
[resultsDir, dataName] = initialise(cfg, 'load'); % Initialise variables

% export_fig(fullfile(resultsDir, 'Channel location'), '-png', '-nocrop');
saveas(gcf, fullfile(resultsDir, 'Channel location'), 'png');
close(f)

% locFile = split(locFilePath, filesep);
[~, locFileName, locExt] = fileparts(locFilePath);
EEG.comments = pop_comments(EEG.comments,'',['Channel locations, ',[locFileName, locExt],', loaded'],1);
ALLEEG = EEG;
[ALLEEG, EEG] = saveSet(ALLEEG, EEG, dataName, resultsDir); % Save and comment EEG set


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

handles.processingConfigName = get(hObject,'String');

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles) % Load
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataFileExt = '.mat';
[paramsFile,paramsFilePath] = uigetfile(fullfile(pwd, ['*', dataFileExt]),'Select params file.');
if paramsFilePath ~= 0
    load(fullfile(paramsFilePath,paramsFile))
    if exist('pipelineElementsParams', 'var') && exist('pipelineElements', 'var') && exist('interactive', 'var') % Correct *.mat was loaded
        handles.pipelineElementsParams = pipelineElementsParams;
        handles.pipelineElements = pipelineElements;
        handles.interactive = interactive;
        %         processingConfigName = split(paramsFilePath, filesep);
        %         handles.processingConfigName = processingConfigName{end - 1};
        % set(handles.edit2,'String', handles.processingConfigName);
        handles.pipelineElementIdx = 1;
        handles.processingTypeIdx = 1;
        % handles.listbox1.Value = handles.processingTypeIdx;
        handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);
        handles = update(handles);
    else
        error('The right file was not selected.')
    end
end
guidata(hObject,handles)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

resultsFoldeName = 'results';
configFolderName = ['config ', handles.processingConfigName];
if ~isempty(handles.currentDataPath) && ~isempty(handles.processingConfigName)
    [~, dataName] = fileparts(handles.currentDataPath);
    if isfolder(fullfile(pwd, resultsFoldeName, dataName, configFolderName))
        winopen(fullfile(pwd, resultsFoldeName, dataName, configFolderName))
    else
        msg = 'The specified folder doesn''t exist!';
        warndlg(msg, 'Warning')
        warning(msg)
    end
end
if isempty(handles.currentDataPath)
    msg = 'Please first select raw dataset!';
    warndlg(msg, 'Warning')
    warning(msg)
end
if isempty(handles.processingConfigName)
    msg = 'Please specify a name for configuration ("Config. Name")!';
    warndlg(msg, 'Warning')
    warning(msg)
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

handles.interactive = get(hObject,'Value');
guidata(hObject,handles)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dataPath(handles.dataPathIdx) = [];
if handles.dataPathIdx <= length(handles.dataPath) && ~isempty(handles.dataPath)
    %     handles.dataPathIdx = length(handles.dataPath);
    handles.currentDataPath = handles.dataPath{handles.dataPathIdx};
elseif handles.dataPathIdx > length(handles.dataPath) && ~isempty(handles.dataPath)
    handles.dataPathIdx = length(handles.dataPath);
    handles.currentDataPath = handles.dataPath{handles.dataPathIdx};
else
    handles.chanLocFilePath = [];
    handles.currentDataPath = [];
    handles.dataPathIdx = 1;
    handles.pushbutton3.Enable = 'off';
    handles.pushbutton5.Enable = 'off';
    handles.pushbutton7.Enable = 'off';
end
handles = update(handles);
guidata(hObject,handles)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataFileExt = {'.edf', '.set'}; % Assumed all have the same length
totDataFileExt = '.mat';
locExt = {'.ced', '.locs'};

tmp = pwd;
cd(handles.rawDataDir)
[dataFile,dataFilePath] = uigetfile({['*', dataFileExt{2}]; ['*', dataFileExt{1}]},... {fullfile(handles.rawDataDir, ['*', dataFileExt{1}]); fullfile(handles.rawDataDir, ['*', dataFileExt{2}])}
    'Select EEG data file.', 'MultiSelect', 'on');
cd(tmp)

if dataFilePath ~= 0 %(~iscell(dataFile) && any(dataFile ~= 0)) || iscell(dataFile)
    if isempty(handles.chanLocFilePath)
        tmp = pwd;
        cd(handles.rawDataDir)
        [locFile,locFilePath] = uigetfile({['*', locExt{2}]; ['*', locExt{1}]},'Select channel location file.');
        cd(tmp)
        if locFilePath ~= 0
            handles.chanLocFilePath = fullfile(locFilePath, locFile);
        else
            warning('Channel location file need to be selected.')
        end
    end
    if ~isempty(handles.chanLocFilePath)
        if ~iscell(dataFile)
            dataFile = {dataFile};
        end
        for j = 1 : length(dataFile)
            if ismember(dataFile{j}(end - length(dataFileExt{1}) + 1 : end), dataFileExt)
                dataName = dataFile{j}(1 : end - length(dataFileExt{1}));
                handles.resultsDir = fullfile(pwd, 'results', dataName, handles.processingConfigName);
                if exist(handles.resultsDir, 'dir')
                    msg = ['The configuration name, ',handles.processingConfigName,', already exists for dataset, ',dataName,', please change the name.'];
                    warndlg(msg, 'Warning')
                    warning(msg)
                    continue
                end
                handles.dataPath = [handles.dataPath; {fullfile(dataFilePath, dataFile{j})}];
                handles.dataPath = unique(cellfun(@num2str, handles.dataPath,'uni', 0));
                handles.dataPathIdx = 1;
                handles.currentDataPath = handles.dataPath{handles.dataPathIdx};
                handles = update(handles);
                handles.pushbutton3.Enable = 'on';
                handles.pushbutton5.Enable = 'on';
                handles.pushbutton7.Enable = 'on';
            elseif strcmp(dataFile{j}(end - length(totDataFileExt)+1 : end), totDataFileExt) % mat
                load(fullfile(dataFilePath, dataFile{j})) % loads 'files'
                
                path = {};
                for i = 1 : length(files)
                    path(i, 1) = {fullfile(files(i).folder, files(i).name)};
                    dataName = files(i).name(1 : end - length(totDataFileExt));
                    handles.resultsDir = fullfile(pwd, 'results', dataName, handles.processingConfigName);
                    if exist(handles.resultsDir, 'dir')
                        msg = ['The configuration name, ',handles.processingConfigName,', already exists for dataset, ',dataName,', please change the name.'];
                        warndlg(msg, 'Warning')
                        warning(msg)
                        continue
                    end
                end
                handles.dataPath = [handles.dataPath; path];
                handles.dataPath = unique(cellfun(@num2str, handles.dataPath,'uni', 0));
                handles.dataPathIdx = 1;
                handles.currentDataPath = handles.dataPath{handles.dataPathIdx};
                handles = update(handles);
                handles.pushbutton3.Enable = 'on';
                handles.pushbutton5.Enable = 'on';
                handles.pushbutton7.Enable = 'on';
            end
        end
    end
else
    warning('No new dataset was selected.')
end
guidata(hObject,handles)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pipelineElementIdx ~= 1
    
    tmp = handles.pipelineElements(handles.pipelineElementIdx);
    handles.pipelineElements(handles.pipelineElementIdx) = handles.pipelineElements(handles.pipelineElementIdx - 1);
    handles.pipelineElements(handles.pipelineElementIdx - 1) = tmp;
    
    tmp = handles.pipelineElementsParams(handles.pipelineElementIdx);
    handles.pipelineElementsParams(handles.pipelineElementIdx) = handles.pipelineElementsParams(handles.pipelineElementIdx - 1);
    handles.pipelineElementsParams(handles.pipelineElementIdx - 1) = tmp;
    handles.pipelineElementIdx = handles.pipelineElementIdx - 1;
    handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);
    handles = update(handles);
    guidata(hObject,handles)
end

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pipelineElementIdx ~= length(handles.pipelineElements)
    
    tmp = handles.pipelineElements(handles.pipelineElementIdx);
    handles.pipelineElements(handles.pipelineElementIdx) = handles.pipelineElements(handles.pipelineElementIdx + 1);
    handles.pipelineElements(handles.pipelineElementIdx + 1) = tmp;
    
    tmp = handles.pipelineElementsParams(handles.pipelineElementIdx);
    handles.pipelineElementsParams(handles.pipelineElementIdx) = handles.pipelineElementsParams(handles.pipelineElementIdx + 1);
    handles.pipelineElementsParams(handles.pipelineElementIdx + 1) = tmp;
    
    handles.pipelineElementIdx = handles.pipelineElementIdx + 1;
    handles.params = update_paramsList(handles.pipelineElementsParams, handles.pipelineElementIdx);
    handles = update(handles);
    guidata(hObject,handles)
end
