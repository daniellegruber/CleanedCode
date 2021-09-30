% Create dummy data structure
temp = table2cell(otu_overlap_transpose);
temp2 = cellstr(temp(:,1:n_names));

% Find unknowns
unknowns = contains(temp2,'Unknown');

% Calculate percentages
unknown_percentages = sum(unknowns,1)*100/size(temp2,1);
unknown_percentages = array2table(unknown_percentages);
unknown_percentages.Properties.VariableNames = names;

% Save table
writetable(unknown_percentages,'unknown_percentages_otu.csv')