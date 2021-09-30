%% Iterate over taxa types
% For each taxanomic group
for n = 1:n_names
    
    %% Create tables containing discordant and concordant taxa
    discord_tbl = table('Size',[0,3],'VariableTypes',{'string', 'double', 'double'},...
        'VariableNames',{'Name','Straussman','Knight'});
    discord_tbl1 = table('Size',[0,3],'VariableTypes',{'string', 'double', 'double'},...
        'VariableNames',{'Name','Straussman','Knight'});
    discord_tbl2 = table('Size',[0,3],'VariableTypes',{'string', 'double', 'double'},...
        'VariableNames',{'Name','Straussman','Knight'});
    concord_tbl = table('Size',[0,3],'VariableTypes',{'string', 'double', 'double'},...
        'VariableNames',{'Name','Straussman','Knight'});
    
    %% Create table comparing sums of strauss and otu
    comp_tbl = table('Size',[num_unique,3],'VariableTypes', ...
        {'string', 'double', 'double'}, 'VariableNames', {'Class','Strauss','Knight'});
    
    %% Create table comparing whether class is present or absent in strauss and otu
    presence_absence_tbl = table('Size',[num_unique,3],'VariableTypes', ...
        {'string', 'double', 'double'}, 'VariableNames', {'Class','Strauss','Knight'});

    %% Extract measures from existing csv files
    strauss_measures = readcell(['taxa_measures_', lower(names{n}), '.csv']);
    otu_measures = readcell(['otu_overlap_measures_', lower(names{n}), '.csv']);
    
    %% Extract data
    % Make sure all instances of unknown values are identified the same way
    % so separate categories aren't created
    strauss_measures(strcmp(strauss_measures(:,1),'Unknown')) = {['Unknown ', names{n}]};
    otu_measures(strcmp(otu_measures(:,1),'Unknown')) = {['Unknown ', names{n}]};
    
    % Index all the classes
    strauss_class = strauss_measures(2:end,1);
    otu_class = otu_measures(2:end,1);
    
    % Find the union of the strauss and otu classes
    % (the unique() function ensures there are no repeats)
    all_class = [strauss_class; otu_class];
    unique_class = unique(all_class);
    unique_class(ismissing(unique_class)) = [];
    
    num_unique = length(unique_class);
    
    %% Iterate over classes
    % For each class in the union set
    for u = 1:num_unique
        
        % See whether class occurs in strauss and/or otu
        strauss_idx = strcmp(unique_class(u), strauss_measures(:,1));
        otu_idx = strcmp(unique_class(u), otu_measures(:,1));
        
        %% Find sums
        % If the class doesn't exist in strauss, set sum to 0
        if sum(strauss_idx) == 0
            strauss_sum = 0;
            
        % If the class does exist in strauss, sum all measures
        else
            strauss_sum = strauss_measures{strauss_idx,3};
        end
        
        % If the class doesn't exist in otu, set sum to 0
        if sum(otu_idx) == 0
            otu_sum = 0;
        else
        
        % If the class does exist in otu, sum all measures
            otu_sum = otu_measures{otu_idx,3};
        end
        
        %% Add entries to sum comparison and presence/absence tables
        
        comp_tbl{u,1} = unique_class(u);
        comp_tbl{u,2} = strauss_sum;
        comp_tbl{u,3} = otu_sum;
        
        presence_absence_tbl{u,1} = unique_class(u);
        if strauss_sum > 0
            presence_absence_tbl{u,2} = 1;
        else
            presence_absence_tbl{u,2} = 0;
        end
        if otu_sum > 0
            presence_absence_tbl{u,3} = 1;
        else
            presence_absence_tbl{u,3} = 0;
        end
        
        %% Add entries to concordant/discordant tables
        
        % If class exists in strauss and otu, add to concordant table
        if (strauss_sum > 0) && (otu_sum > 0)
            idx = height(concord_tbl) + 1;
            concord_tbl{idx, 1} = unique_class(u);
            concord_tbl{idx, 2} = strauss_sum;
            concord_tbl{idx, 3} = otu_sum;
        else
            % Class does not exist in both strauss and otu, so add to
            % general discordant table
            idx = height(discord_tbl) + 1;
            discord_tbl{idx, 1} = unique_class(u);
            discord_tbl{idx, 2} = strauss_sum;
            discord_tbl{idx, 3} = otu_sum;
            
            % If the class exists in strauss but not otu, add to discord
            % table 1
            if strauss_sum > 0
                idx = height(discord_tbl1) + 1;
                discord_tbl1{idx, 1} = unique_class(u);
                discord_tbl1{idx, 2} = strauss_sum;
                discord_tbl1{idx, 3} = otu_sum;
                
            % If the class exists in otu but not strauss, add to discord
            % table 2
            else
                idx = height(discord_tbl2) + 1;
                discord_tbl2{idx, 1} = unique_class(u);
                discord_tbl2{idx, 2} = strauss_sum;
                discord_tbl2{idx, 3} = otu_sum;
            end
        end
        
        
    end
    
    %% Save tables to files
    
    if ~isempty(discord_tbl)
        temp = discord_tbl{:,2:3};
        temp(temp>0) = 1;
        discord_tbl_pa = table(discord_tbl.Name, temp(:,1),temp(:,2));
        discord_tbl_pa.Properties.VariableNames = discord_tbl.Properties.VariableNames;
        writetable(discord_tbl_pa,['new_discord_pa_', lower(names{n}), '.csv'])
    end

    if ~isempty(discord_tbl1)
        temp = discord_tbl1{:,2:3};
        temp(temp>0) = 1;
        discord_tbl1_pa = table(discord_tbl1.Name, temp(:,1),temp(:,2));
        discord_tbl1_pa.Properties.VariableNames = discord_tbl1.Properties.VariableNames;
        writetable(discord_tbl1_pa,['new_discord1_pa_', lower(names{n}), '.csv'])
    end

    if ~isempty(discord_tbl2)
        temp = discord_tbl2{:,2:3};
        temp(temp>0) = 1;
        discord_tbl2_pa = table(discord_tbl2.Name, temp(:,1),temp(:,2));
        discord_tbl2_pa.Properties.VariableNames = discord_tbl2.Properties.VariableNames;
        writetable(discord_tbl2_pa,['new_discord2_pa_', lower(names{n}), '.csv'])
    end
    
    writetable(discord_tbl,['new_discord_', lower(names{n}), '.csv'])
    writetable(discord_tbl1,['new_discord1_', lower(names{n}), '.csv'])
    writetable(discord_tbl2,['new_discord2_', lower(names{n}), '.csv'])
    writetable(concord_tbl,['new_concord_', lower(names{n}), '.csv'])
    
    writetable(comp_tbl,['compare_sums_', lower(names{n}), '.csv'])
    writetable(presence_absence_tbl,['compare_pa_', lower(names{n}), '.csv'])
end
