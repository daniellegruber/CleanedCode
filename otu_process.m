%% Load data

if ~exist('OTU_test','var')
    OTU_test = readcell('otufortesting.xlsx');
    OTU_test = OTU_test';
end

%% Create table

column_names = [names,OTU_test(1,2:end)];
variable_types = [repmat({'string'}, 1, n_names), repmat({'double'}, 1, size(OTU_test(1,2:end),2))];
OTU_test_tbl = table('Size',[size(OTU_test,1)-1, length(variable_types)],'VariableTypes',...
    variable_types,'VariableNames',column_names);

%% Insert nums

nums = cell2mat(OTU_test(2:end,2:end));
OTU_test_tbl{:,n_names+1:end} = nums;
%% Split names

for r = 1:size(nums,1)
    str = OTU_test{r+1,1};
    split = strsplit(str,'.');
    
    for n = 1:n_names
        match = regexp(split,[markers{n},'\w*\w'],'match');
        match = char([match{:}]);
        if isempty(match)
            OTU_test_tbl{r,n} = string(['Unknown ', names{n}]);
        else
            OTU_test_tbl{r,n} = string(match(4:end));
        end
    end
    
end

%% Save new file
writetable(OTU_test_tbl,'OTU_test_tbl.csv')
writetable(OTU_test_tbl(1:200,:),'OTU_test_tbl_preview.csv')