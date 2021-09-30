%% Count table for knight_no_virus data
% Load data
knight_no_virus = readtable('knight_no_virus.xlsx');

% Column names
column_names = cell(1,n_names*2);
for n = 1:n_names
    column_names(2*(n-1)+1:2*n) = [names(n), cellstr([names{n}, ' Count'])];
end

% Create empty tables
knight_count = table('Size',[0,n_names*2],'VariableTypes',...
    repmat({'string', 'double'}, 1, n_names),'VariableNames',column_names);

% For each taxonomic group
for n = 1:n_names
    
    % Find unique class within that taxonomic group
    unique_names = unique(knight_no_virus{:,n});
    unique_names(ismissing(unique_names)) = [];
    num_unique = length(unique_names);
    
    % For each of these classes
    for u = 1:num_unique
        
        % Find the number of times they appear in the otu data
        knight_count{u,2*(n-1)+1} = unique_names(u);
        knight_count{u,2*n} = length(find(strcmp(unique_names(u), OTU_test_tbl{:,n})));
    end
    
    % Sort the rows in descending order
    [~,idx] = sort(knight_count{:,2*n},'descend');
    knight_count{:,2*(n-1)+1:2*n} = knight_count{idx,2*(n-1)+1:2*n};
end

% Save new file
writetable(knight_count,'knight_count.csv')

%% Count table for strauss data
% Load data
straussman = readtable('straussman_test_pruned.csv');
straussman_excerpt = straussman(:,4:3+n_names);

% For each taxonomic group
for n = 1:n_names
    
    % Make sure all instances of unknown values are identified the same way
    % so separate categories aren't created
    unknown_idx = strfind(straussman_excerpt{:,n},'Unknown');
    unknown_idx = ~cellfun(@isempty,unknown_idx);
    if length(find(unknown_idx)) ~= 0
        straussman_excerpt(unknown_idx,n) = {['Unknown ', names{n}]};
    end
end

% Create empty table
straussman_count = table('Size',[0,n_names*2],'VariableTypes',...
    repmat({'string', 'double'}, 1, n_names),'VariableNames',column_names);

% For each taxonomic group
for n = 1:n_names
    
    % Find unique class within that taxonomic group
    unique_names = unique(straussman_excerpt{:,n});
    unique_names(ismissing(unique_names)) = [];
    num_unique = length(unique_names);
    
    % For each of these classes
    for u = 1:num_unique
        
        % Find the number of times they appear in the strauss data
        straussman_count{u,2*(n-1)+1} = unique_names(u);
        straussman_count{u,2*n} = length(find(strcmp(unique_names(u), straussman_excerpt{:,n})));
    end
    
    % Sort the rows in descending order
    [~,idx] = sort(straussman_count{:,2*n},'descend');
    straussman_count{:,2*(n-1)+1:2*n} = straussman_count{idx,2*(n-1)+1:2*n};
end

%% Save new file
writetable(straussman_count,'straussman_count.csv')

%% Compare counts

% For each taxonomic group
for n = 1:n_names
    
    % Find the union of the strauss and otu classes
    % (the unique() function ensures there are no repeats)
    unique_names = unique(vertcat(knight_count{:,2*(n-1)+1},straussman_count{:,2*(n-1)+1}));
    unique_names(ismissing(unique_names)) = [];
    num_unique = length(unique_names);
    
    % Create empty table
    count_tbl = table('Size',[num_unique,3],'VariableTypes',{'string', 'double', 'double'},...
        'VariableNames',{'Name','Straussman','Knight'});
    
    % For each class in the union set
    for u = 1:num_unique
        count_tbl{u,1} = unique_names(u);
        count_tbl{u,2} = length(find(strcmp(unique_names(u), straussman_excerpt{:,n})));
        count_tbl{u,3} = length(find(strcmp(unique_names(u), OTU_test_tbl{:,n})));
    end
    
    % Save table
    writetable(count_tbl,['count_', lower(names{n}), '.csv'])
    
end

%% Create overlap table
knight_count = readtable('knight_count.csv');
straussman_count =readtable('straussman_count.csv');

% Create empty table
overlap_tbl = table('Size',[n_names,5],'VariableTypes',{'string', 'double', 'double','double','double'},...
    'VariableNames',{'Name','Straussman','Knight','Overlap','Overlap Percentage'});

% For each taxonomic group
for n = 1:n_names
    
    overlap_tbl{n,1} = string(names{n});
    
    % Find unique strauss classes within taxonomic group
    unique_strauss = unique(straussman_count{:,2*(n-1)+1});
    
    % Remove empty and unknown values
    empty_idx = cellfun(@isempty,unique_strauss);
    unknown_idx = contains(unique_strauss,'Unknown');
    unique_strauss(empty_idx | unknown_idx) = [];
    
    % Find unique otu classes within taxonomic group
    unique_knight = unique(knight_count{:,2*(n-1)+1});
    
    % Remove empty and unknown values
    empty_idx = cellfun(@isempty,unique_knight);
    unknown_idx = contains(unique_knight,'Unknown');
    unique_knight(empty_idx | unknown_idx) = [];
    
    % Record number of unique classes
    overlap_tbl{n,2} = length(unique_strauss);
    overlap_tbl{n,3} = length(unique_knight);
    
    % Find the union of the strauss and otu classes
    unique_names = unique(vertcat(unique_knight, unique_strauss));
    num_unique = length(unique_names);
    
    % For each class in the union set
    overlaps = 0;
    for u = 1:num_unique
        
        % Find number of instances of class in strauss and otu data
        strauss_num = length(find(strcmp(unique_names(u), straussman_excerpt{:,n})));
        knight_num = length(find(strcmp(unique_names(u), OTU_test_tbl{:,n})));
        
        % If class exists in strauss and otu, add 1 to overlaps
        if (strauss_num > 0) && (knight_num > 0)
            overlaps = overlaps + 1;
        end
        
    end
    
    % Record number of overlaps and percentage of overlaps
    overlap_tbl{n,4} = overlaps;
    overlap_tbl{n,5} = overlaps/num_unique * 100;
    
end

writetable(overlap_tbl,'overlap_tbl.csv')

%% Create tables containing discordant and concordant taxa

% Create empty tables
discord_tbl = table('Size',[0,3],'VariableTypes',{'string', 'double', 'double'},...
    'VariableNames',{'Name','Straussman','Knight'});
discord_tbl1 = table('Size',[0,3],'VariableTypes',{'string', 'double', 'double'},...
    'VariableNames',{'Name','Straussman','Knight'});
discord_tbl2 = table('Size',[0,3],'VariableTypes',{'string', 'double', 'double'},...
    'VariableNames',{'Name','Straussman','Knight'});
concord_tbl = table('Size',[0,3],'VariableTypes',{'string', 'double', 'double'},...
    'VariableNames',{'Name','Straussman','Knight'});

% For each taxanomic group
for n = 1:n_names
    
    % Find the union of the strauss and otu classes
    % (the unique() function ensures there are no repeats)
    unique_names = unique(vertcat(knight_count{:,2*(n-1)+1},straussman_count{:,2*(n-1)+1}));
    unique_names(ismissing(unique_names)) = [];
    unique_names(cellfun(@isempty,unique_names)) = [];
    num_unique = length(unique_names);
    
    % For each class in the union set
    for u = 1:num_unique
        
        % Length of number of occurances in strauss and/or otu
        strauss_num = length(find(strcmp(unique_names(u), straussman_excerpt{:,n})));
        knight_num = length(find(strcmp(unique_names(u), OTU_test_tbl{:,n})));
        
        % If class exists in strauss and otu, add to concordant table
        if (strauss_num > 0) && (knight_num > 0)
            idx = height(concord_tbl) + 1;
            concord_tbl{idx, 1} = unique_names(u);
            concord_tbl{idx, 2} = strauss_num;
            concord_tbl{idx, 3} = knight_num;
            
        else
            % Class does not exist in both strauss and otu, so add to
            % general discordant table
            idx = height(discord_tbl) + 1;
            discord_tbl{idx, 1} = unique_names(u);
            discord_tbl{idx, 2} = strauss_num;
            discord_tbl{idx, 3} = knight_num;
            
            % If the class exists in strauss but not otu, add to discord
            % table 1
            if strauss_num > 0
                idx = height(discord_tbl1) + 1;
                discord_tbl1{idx, 1} = unique_names(u);
                discord_tbl1{idx, 2} = strauss_num;
                discord_tbl1{idx, 3} = knight_num;
                
            % If the class exists in otu but not strauss, add to discord
            % table 2
            else
                idx = height(discord_tbl2) + 1;
                discord_tbl2{idx, 1} = unique_names(u);
                discord_tbl2{idx, 2} = strauss_num;
                discord_tbl2{idx, 3} = knight_num;
            end
        end
        
        
    end
    
    % Save tables
    writetable(discord_tbl,['discord_', lower(names{n}), '.csv'])
    writetable(discord_tbl1,['discord1_', lower(names{n}), '.csv'])
    writetable(discord_tbl2,['discord2_', lower(names{n}), '.csv'])
    writetable(concord_tbl,['concord_', lower(names{n}), '.csv'])
    
end

%% Create read table

% For each taxonomic group
for n = 1:n_names
    
    % Find the union of the strauss and otu classes
    unique_names = unique(vertcat(knight_count{:,2*(n-1)+1},straussman_count{:,2*(n-1)+1}));
    unique_names(ismissing(unique_names)) = [];
    unique_names(cellfun(@isempty,unique_names)) = [];
    num_unique = length(unique_names);
    
    % Create empty table
    read_tbl = table('Size',[num_unique,3],'VariableTypes',{'string', 'double', 'double'},...
        'VariableNames',{'Name','Straussman','Knight'});
    
    % For each class in the union set
    for u = 1:num_unique
        read_tbl{u,1} = unique_names(u);
        
        % Sum the values for all instances of the class
        read_tbl{u,2} = sum(straussman{strcmp(unique_names(u), straussman_excerpt{:,n}),end});
        read_tbl{u,3} = sum(OTU_test_tbl{strcmp(unique_names(u), OTU_test_tbl{:,n}),11:end}, 'all');
    end
    
    % Save tables
    writetable(read_tbl,['read_', lower(names{n}), '.csv'])
    
end
