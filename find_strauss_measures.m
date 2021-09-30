%% Create dummy data structure to work with
strauss = readcell('straussman_d.csv');
temp = strauss(11:end,1:n_names);
temp2 =strauss(11:end,n_names+1:end);

%% Replace missing values
missing = cellfun(@ismissing,temp,'UniformOutput',false);
missing = find(cellfun(@(x) length(x), missing) == 1);
temp(missing) = {'Unknown'};

unknowns = contains(temp,'Unknown');
temp(unknowns) = {'Unknown'};

missing = cellfun(@ismissing,temp2,'UniformOutput',false);
non_missing = ~(cell2mat(missing));

%% Iterate over taxonomic groups
% For each taxonomic group
for n = 1:n_names
    
    % Find unique classes within taxonomic group
    unique_names = unique(temp(:,n));
    unique_names(ismissing(unique_names)) = [];
    num_unique = length(unique_names);
    
    % Create empty table
    taxa_measures = table('Size',[num_unique,8],'VariableTypes',...
        ['string', repmat({'double'}, 1, n_names)],'VariableNames', [names(n), measures]);
    
    % For each class
    for u = 1:num_unique
        
        % Index of rows with class
        idx = find(strcmp(unique_names(u), temp(:,n)));
         
        % For each row with that class
        sums = zeros(1,length(idx));
        for i = 1:length(idx)
            
            % Record the sum of values for that row
            sums(i) = sum(cell2mat(temp2(idx(i),non_missing(idx(i),:))));
        end
        
        % Record measures based on these sums
        taxa_measures{u,1} = unique_names(u);
        taxa_measures{u,2} = length(idx);
        taxa_measures{u,3} = sum(sums);
        taxa_measures{u,4} = mean(sums);
        taxa_measures{u,5} = std(sums);
        taxa_measures{u,6} = median(sums);
        taxa_measures{u,7} = max(sums);
        taxa_measures{u,8} = min(sums);
    end
    
    % Sort rows in descending order
    taxa_measures = sortrows(taxa_measures,3,'descend');
    
    % Save table
    writetable(taxa_measures,['taxa_measures_', lower(names{n}), '.csv'])
end

