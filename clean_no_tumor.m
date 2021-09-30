%% Load data
no_tumor = readtable('danielle_no_tumor.xlsx');

%% Remove rows where column 254 = 0
no_tumor(no_tumor{:,254} == 0,:) = [];

%% Save new file
writetable(no_tumor,'no_tumor.csv')
