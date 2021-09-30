%% Load file
% Only load it if it isn't already in workspace so that you don't have to
% load it each time you run the script
if ~exist('straussman','var')
    straussman = readtable('Straussman_test.xlsx');
end

%% Find "bad values" in columns
% Note: this section wasn't really necessary because there were no empty or 
% nan values in the file, but you can use this "idea" for eliminating "bad
% values" in other data

% Create matrix size of straussman where an entry will be 1 if the
% corresponding element is "bad" and 0 if it is "good"
n_row = size(straussman,1);
n_col = size(straussman,2);
bad_idx_matrix = zeros(size(straussman));
double_idx = zeros(1,n_col);

for col = 1:n_col

    % If the data is of cell type, bad values are indicated by missing
    % values
    if iscell(straussman{:,col})
        empty_idx = cellfun(@isempty,straussman{:,col});
        bad_idx_matrix(:,col) = empty_idx;

    %If the data is of matrix type, bad values are indicated by nan values,
    % as well as 0 values if you so wish
    elseif ismatrix(straussman{:,col})
        double_idx(col) = 1;
        
        nan_idx = isnan(straussman{:,col});
        zero_idx = straussman{:,col} == 0;
        bad_idx_matrix(:,col) = nan_idx | zero_idx;
        
    end
end

%% Prune "bad rows" (method 1)
% ** Use this method (uncomment) if there is no sum column at the end **
% Prune rows where the sum of the 11th to end columns are 0, meaning all 
% the values are 0

% straussman_pruned = straussman;
% bad_row = sum(bad_idx_matrix(:,11:end),2) == n_col - 13;
% straussman_pruned(bad_row,:) = [];

%% Prune "bad rows" (method 2)
% ** Use this method (uncomment) if there is a sum column at the end **
straussman_pruned = straussman;
bad_row = straussman{:,end} == 0;
straussman_pruned(bad_row,:) = [];

%% Save new file
writetable(straussman_pruned,'straussman_pruned.csv')

%% Save new file, preview
writetable(straussman_pruned(1:200,:),'straussman_pruned_preview.csv')