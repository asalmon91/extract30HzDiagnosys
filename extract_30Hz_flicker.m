%% Extract 30Hz flicker amplitude from ff-ERG
% Automatic extraction of the 30Hz flicker amplitude from the Diagnosys ff-ERG system for animals
% Alex Salmon - 2020.08.04 - Created

%% Imports
addpath(genpath('lib'));

%% Constants


%% Get user-input
path_root = uigetdir('.', 'Select root directory. Will find all compatible files in this tree');
if isnumeric(path_root)
	disp('Sorry to see you go!');
	return;
end

%% Recursive file search
search_results = subdir(fullfile(path_root, '*.xls'));

%% Process each file
amps = nan(numel(search_results), 2);
for ii=1:numel(search_results)
	% Check that this is the kind of file we're looking for
	if ~verifyDiagnosysFile(search_results(ii).name)
		continue;
	end
	
	% Process File
	[amps(ii, :), f_out] = procDiagnosysisFile(search_results(ii).name);
    
    % Save figure with raw data
    [xls_path, xls_name, ~] = fileparts(search_results(ii).name);
    savefig(f_out, fullfile(xls_path, sprintf('%s.fig', xls_name)));
end

%% Create a report
ffnames = {search_results.name}';
[in_paths, in_names, ~] = cellfun(@fileparts, ffnames, 'UniformOutput', false);

% Remove any incompatible files
remove = any(isnan(amps), 2);
in_paths(remove) = [];
in_names(remove) = [];
amps(remove, :) = [];

% Construct a table
tbl_header = {'Path', 'File name', 'Ch1 (nV)', 'Ch2 (nV)'};
tbl = [tbl_header; [in_paths, in_names, num2cell(amps)]];

% Write report
path_out = path_root;
fname_out = 'Summary_30Hz.xlsx';
writecell(tbl, fullfile(path_out, fname_out));

