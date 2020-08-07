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
	display_on = true;
	amps(ii, :) = procDiagnosysisFile(search_results(ii).name, display_on);
end





