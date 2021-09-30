%% Load file
if ~exist('straussman1','var')
    load('straussman_rel_abundance.mat');
end

%% Normalize

normalizer = straussman1(end,2:end);
idx = cellfun(@isnumeric,normalizer);
normalizer = cell2mat(normalizer(idx));
normalizer = repmat(normalizer, size(straussman2,1)-1, 1);

temp = table2array(straussman2(2:end,11:end-4));
temp = temp ./ normalizer;
straussman2{2:end,11:end-4} = temp;
straussman2{2:end,end} = sum(temp,2);

%% Save new file
writetable(straussman2,'straussman_rel_abundance.csv')

%% Save new file, preview
writetable(straussman2(1:200,:),'straussman_rel_abundance_preview.csv')

%% Save new file

temp(temp ~= 0) = 1;
straussman3 = straussman2;
straussman3{2:end,11:end-4} = temp;
straussman3{2:end,end} = sum(temp,2);
writetable(straussman3,'straussman_rel_abundance2.csv')

%% Save new file, preview
writetable(straussman3(1:200,:),'straussman_rel_abundance_preview2.csv')