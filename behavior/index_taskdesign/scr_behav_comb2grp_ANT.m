% written by hao (2017/11/03)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% Basic Information Set up
nrun = 2;
res_file = 'res_SWUC_ANT';
scr_dir  = '/Users/hao1ei/xToolbox/scr_hao/Behavior/BrainDev_ANT';

%% Read E-Prime Data Index
for irun = 1:nrun
    res{irun} = load(fullfile(scr_dir,[res_file,num2str(irun),'.mat']));
    [irow,icol]=size(res{1, irun}.allres);
    for isub = 2:irow
        sublist{irun}{isub-1,1} = res{1, irun}.allres{isub,2};
    end
end

%% Acquire common sublist
sub_comm = intersect(sublist{1,1}, sublist{1,2});

%% Calculate mean value
allres = res{1,1}.allres(1,:);
for isubc = 1:length(sub_comm)
    [~,loc1] = ismember(sub_comm{isubc,1},res{1,1}.allres(:,2));
    [~,loc2] = ismember(sub_comm{isubc,1},res{1,2}.allres(:,2));
    
    allres{isubc+1,1} = cell2mat(res{1,1}.allres(loc1,1));
    allres{isubc+1,2} = cell2mat(res{1,1}.allres(loc1,2));
    allres{isubc+1,3} = cell2mat(res{1,1}.allres(loc1,3));
    allres{isubc+1,4} = cell2mat(res{1,1}.allres(loc1,4));
    
    vect1 = cell2mat(res{1,1}.allres(loc1,5:icol));
    vect2 = cell2mat(res{1,2}.allres(loc2,5:icol));
    vectm = (vect1 + vect2)/2;
    
    for ires = 5:icol
        allres{isubc+1,ires} = num2str(vectm(1,ires-4));
    end
end

%% Save Results
save_name = [res_file,'.csv'];

fid = fopen(save_name, 'w');
[nrows,ncols] = size(allres);
col_num = '%s';
for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
col_num = [col_num, '\n'];
for row_i = 1:nrows; fprintf(fid, col_num, allres{row_i,:}); end;
fclose(fid);

%% All Done
clear all
disp('All Done');