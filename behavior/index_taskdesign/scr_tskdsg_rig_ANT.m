% written by hao (2017/04/18)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% Basic Information Set Up
tsk_name = 'ANT2';
td_name  = 'ANT_rig_hao.m';

save_dir = '/Users/hao1ei/xFiles/Projects/BrainDev_ANT/TaskDesign/SWUC_198';
scr_dir  = '/Users/hao1ei/xToolbox/scr_hao/Behavior/BrainDev_ANT';

edata_file = '/Users/hao1ei/xFiles/Projects/BrainDev_ANT/EprimeData/SWUC_198/SWUC_ANT2.txt';
subj_file  = '/Users/hao1ei/xFiles/Projects/BrainDev_ANT/EprimeData/SWUC_198/SWUC_ANT2_list.txt';

%% Read E-Prime Data Index
index = {'Subject';
         'PracSlideTarget.OnsetTime';
         'PracSlideFixationStart.OnsetTime';
         'PracSlideTarget.ACC';
         'PracSlideTarget.RT';
         'FlankerType';
         'WarningType'};

%% Import E-prime_ID & Img_ID (ID_List)
fid = fopen(subj_file); sublist = {}; cnt_list = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt_list,:) = linedata{1}; cnt_list = cnt_list+1;%#ok<*SAGROW>
end
fclose(fid);

%% Import E-prime data (Edata)
fid = fopen(edata_file); edata_all = {}; cnt_edata = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    edata_all(cnt_edata,:) = linedata{1}; cnt_edata = cnt_edata+1;
end
fclose(fid);

allindex = edata_all(1,:);
for a = 1:length(index)
    for b = 2:length(edata_all)
        edata(b-1,a) = edata_all(b,strcmp(allindex,index{a,1}));
    end
end

%% Generate TaskDesign Only Corrcet Trials
for f = 1:length(sublist)
    %% Acquire Each Subject Edata Matrix
    [sub_trial,~] = find(str2double(edata(:,strcmp(index,'Subject')))==str2double(sublist{f,1}));
    sub_edata     = edata(sub_trial,:);
    
    %% Acquire Each Condition Onset & Duration
    NoCueOnset    = [];
    DoubCueOnset  = [];
    CentCueOnset  = [];
    SpatCueOnset  = [];
    InconFlkOnset = [];
    ConFlkOnset   = [];
    
    NoCueDurat    = [];
    DoubCueDurat  = [];
    CentCueDurat  = [];
    SpatCueDurat  = [];
    InconFlkDurat = [];
    ConFlkDurat   = [];
    
    onsets={};
    durations={};
    
    for g=1:length(sub_trial)
        % Acquire CueOnset & Duration
        if (str2double(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(g,1),strcmp(index,'WarningType')),'no'))
            NoCueOnset = [NoCueOnset,((cellfun(@str2num,edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.OnsetTime')))) - 600 ...
                - cellfun(@str2num,edata(sub_trial(1,1),strcmp(index,'PracSlideFixationStart.OnsetTime'))))/1000]; %#ok<*AGROW>
            NoCueDurat = [NoCueDurat,0.15];
        end
        
        if (str2double(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(g,1),strcmp(index,'WarningType')),'double'))
            DoubCueOnset = [DoubCueOnset,((cellfun(@str2num,edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.OnsetTime')))) - 600 ...
                - cellfun(@str2num,edata(sub_trial(1,1),strcmp(index,'PracSlideFixationStart.OnsetTime'))))/1000];
            DoubCueDurat = [DoubCueDurat,0.15];
        end
        
        if (str2double(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(g,1),strcmp(index,'WarningType')),'center'))
            CentCueOnset = [CentCueOnset,((cellfun(@str2num,edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.OnsetTime')))) - 600 ...
                - cellfun(@str2num,edata(sub_trial(1,1),strcmp(index,'PracSlideFixationStart.OnsetTime'))))/1000];
            CentCueDurat = [CentCueDurat,0.15];
        end
        
        if (str2double(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(g,1),strcmp(index,'WarningType')),'up') || ...
                str2double(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(g,1),strcmp(index,'WarningType')),'down'))
            SpatCueOnset = [SpatCueOnset,((cellfun(@str2num,edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.OnsetTime')))) - 600 ...
                - cellfun(@str2num,edata(sub_trial(1,1),strcmp(index,'PracSlideFixationStart.OnsetTime'))))/1000];
            SpatCueDurat = [SpatCueDurat,0.15];
        end
        
        % Acquire TargetOnset & Duration
        if (str2double(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(g,1),strcmp(index,'FlankerType')),'incongruent'))
            InconFlkOnset = [InconFlkOnset,(cellfun(@str2num,edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.OnsetTime'))) ...
                - cellfun(@str2num,edata(sub_trial(1,1),strcmp(index,'PracSlideFixationStart.OnsetTime'))))/1000];
            InconFlkDurat = [InconFlkDurat,(str2num(cell2mat(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.RT')))))/1000]; %#ok<*ST2NM>
        end
        
        if (str2double(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(g,1),strcmp(index,'FlankerType')),'congruent'))
            ConFlkOnset = [ConFlkOnset,(cellfun(@str2num,edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.OnsetTime'))) ...
                - cellfun(@str2num,edata(sub_trial(1,1),strcmp(index,'PracSlideFixationStart.OnsetTime'))))/1000];
            ConFlkDurat = [ConFlkDurat,(str2num(cell2mat(edata(sub_trial(g,1),strcmp(index,'PracSlideTarget.RT')))))/1000];
        end
    end
    %% Create Onset & Duration
    onsets{1,1} = NoCueOnset;
    onsets{1,2} = DoubCueOnset;
    onsets{1,3} = CentCueOnset;
    onsets{1,4} = SpatCueOnset;
    onsets{1,5} = InconFlkOnset;
    onsets{1,6} = ConFlkOnset;
    
    durations{1,1} = NoCueDurat;
    durations{1,2} = DoubCueDurat;
    durations{1,3} = CentCueDurat;
    durations{1,4} = SpatCueDurat;
    durations{1,5} = InconFlkDurat;
    durations{1,6} = ConFlkDurat;
    
    %% Save task design
    yearID = ['20',sublist{f,2}(1:2)];
    td_dir = fullfile(save_dir,yearID,sublist{f,2},'fmri',tsk_name,'task_design');
    
    mkdir (td_dir)
    cd (td_dir)
    
    tskdsg=fopen(td_name, 'a');
    
    fprintf(tskdsg,'%s\n',['sess_name     = ''',tsk_name,''';']);
    
    fprintf(tskdsg,'%s\n','names{1}      = [''NoCue''];');
    fprintf(tskdsg,'%s','onsets{1}     = [');
    for i=1:length(onsets{1,1})
        fprintf(tskdsg, '%.3f', onsets{1,1}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s','durations{1}  = [');
    for i=1:length(durations{1,1})
        fprintf(tskdsg, '%.3f', durations{1,1}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    
    fprintf(tskdsg,'%s\n','names{2}      = [''DoubCue''];');
    fprintf(tskdsg,'%s','onsets{2}     = [');
    for i=1:length(onsets{1,2})
        fprintf(tskdsg, '%.3f', onsets{1,2}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s','durations{2}  = [');
    for i=1:length(durations{1,2})
        fprintf(tskdsg, '%.3f', durations{1,2}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    
    fprintf(tskdsg,'%s\n','names{3}      = [''CentCue''];');
    fprintf(tskdsg,'%s','onsets{3}     = [');
    for i=1:length(onsets{1,3})
        fprintf(tskdsg, '%.3f', onsets{1,3}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s','durations{3}  = [');
    for i=1:length(durations{1,3})
        fprintf(tskdsg, '%.3f', durations{1,3}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    
    fprintf(tskdsg,'%s\n','names{4}      = [''SpatCue''];');
    fprintf(tskdsg,'%s','onsets{4}     = [');
    for i=1:length(onsets{1,4})
        fprintf(tskdsg, '%.3f', onsets{1,4}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s','durations{4}  = [');
    for i=1:length(durations{1,4})
        fprintf(tskdsg, '%.3f', durations{1,4}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s\n','names{5}      = [''InconFlk''];');
    fprintf(tskdsg,'%s','onsets{5}     = [');
    for i=1:length(onsets{1,5})
        fprintf(tskdsg, '%.3f', onsets{1,5}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s','durations{5}  = [');
    for i=1:length(durations{1,5})
        fprintf(tskdsg, '%.3f', durations{1,5}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s\n','names{6}      = [''ConFlk''];');
    fprintf(tskdsg,'%s','onsets{6}     = [');
    for i=1:length(onsets{1,6})
        fprintf(tskdsg, '%.3f', onsets{1,6}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s','durations{6}  = [');
    for i=1:length(durations{1,6})
        fprintf(tskdsg, '%.3f', durations{1,6}(1,i));
        fprintf(tskdsg, '%s', ',');
    end
    fprintf(tskdsg, '%s\n','];');
    
    fprintf(tskdsg,'%s\n','rest_exists   = ''1'';');
    fprintf(tskdsg,'%s\n','save task_design.mat sess_name names onsets durations rest_exists');
    
    fclose(tskdsg);
end

%% All Done
cd (scr_dir)
clear
disp('All Done');