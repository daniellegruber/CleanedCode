%% Define taxonomic groups
% These will be used for column headers
names = {'Domain','Phylum','Class','Order','Family','Genus', 'Species'};

% These will be used for parsing strings (using regexp)
markers = cellfun(@(x) [x(1),'__'], lower(names) ,'UniformOutput',false);
markers{1} = 'k__';

%% Process strauss data

strauss_process;

%% Compare strauss and otu

compare_strauss_otu;

%% Process otu data

otu_transpose_split;

%% Create no tumor table

clean_no_tumor;

%% Create count and read tables

count_and_read_table;

%% Find otu measures

find_otu_measures;

%% Find strauss_measures

find_strauss_measures;

%% Find otu unknowns

find_otu_unknowns;

%% Find strauss unknowns

find_strauss_unknowns;

%% Process plated data and transpose otu data

process_plated_and_transpose_otu;
