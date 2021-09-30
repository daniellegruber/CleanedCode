% Load data
strauss = readcell('straussman_d.csv');

% Create dummy data structure
temp = strauss(10:end,1:n_names);

% Find and replace missing values
missing = cellfun(@ismissing,temp,'UniformOutput',false);
missing = find(cellfun(@(x) length(x), missing) == 1);
temp(missing) = {'Unknown'};

% Find unknown values
unknowns = contains(temp,'Unknown');

% Calculate percentages
unknown_percentages = sum(unknowns,1)*100/(size(temp,1)-1);
unknown_percentages = array2table(unknown_percentages);
unknown_percentages.Properties.VariableNames = names;

% Save table
writetable(unknown_percentages,'unknown_percentages.csv')