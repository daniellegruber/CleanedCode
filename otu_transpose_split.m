%% Extract data
meta = readcell('danielle_knight_new.xlsx','Sheet', 1);
meta_headers = meta(1,:);
raw = readcell('danielle_knight_new.xlsx','Sheet', 2);
raw{1,1} = 'Sample';
raw_headers = raw(1,:);

% Delete headers
meta(1,:) = [];
raw(1,:) = [];
%% Delete all rows that aren't primary tumor

% ** Meta table **
good_idx = strcmp(meta(:,17),'Primary Tumor' );
del_idx = ~good_idx;
del_samples = meta(del_idx,1);
meta_pruned = meta(good_idx,:);

meta_pruned = [meta_headers; meta_pruned];

% Save pruned file
writecell(meta_pruned,'meta_pruned.csv')

% ** Raw table **
del_idx = ismember(raw(:,1),del_samples);
good_idx = ~del_idx;
raw_pruned = raw(good_idx,:);
raw_pruned = [raw_headers; raw_pruned];

% Save pruned file
writecell(raw_pruned,'raw_pruned.csv')
%% Create new otu table

% Transpose pruned raw table
temp = raw_pruned;
temp = temp';

% Create empty table
n_rows = size(temp, 1) - 1;
n_cols = n_names + size(temp,2) - 1;

raw_transpose = table('Size',[n_rows, n_cols],'VariableTypes',...
    [repmat({'string'}, 1, n_names), repmat({'double'}, 1, size(temp,2) - 1)], ...
    'VariableNames',[names, temp(1,2:end)]);

%% Split rows by taxonomic groups using regexp
for r = 2:n_rows
    str = temp{r,1};
    split = strsplit(str,'.');
    
    % For each taxonomic group
    for n = 1:n_names
        
        % See if there are any matches for that group
        % (regexp finds strings that begin with the marker for that
        % taxonomic group and only contain letters or numbers)
        match = regexp(str,[markers{n},'[a-zA-Z-0-9]*[a-zA-Z-0-9]'],'match');
        match = char([match{:}]);
        
        % If no match found, say that the taxonomic group is unknown
        if isempty(match)
            raw_transpose{r-1,n} = string(['Unknown ', names{n}]);
        
        % If a match is found, enter that match into the column
        % corresponding to the taxonomic group
        else
            raw_transpose{r-1,n} = string(match(4:end));
        end
    end
    
end

%% Fill in the rest of the new table with the numerical measures
raw_transpose{:,length(names) + 1:end} = cell2mat(temp(2:end,2:end));

%% Save the new table
writetable(raw_transpose,'raw_transpose.csv')

%% Calculate percentages of unknown values
unknowns = contains(cellstr(raw_transpose{:,1:n_names}),'Unknown');
unknown_percentages = sum(unknowns,1)*100/(n_rows-1);
unknown_percentages = array2table(unknown_percentages);
unknown_percentages.Properties.VariableNames = names;
writetable(unknown_percentages,'unknown_percentages.csv')