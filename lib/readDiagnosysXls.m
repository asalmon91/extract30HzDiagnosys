function raw = readDiagnosysXls(in_ffname)
%readDiagnosysXls is a little like xlsread except for some reason that doesn't work on excel '97

raw = [];
current_line = [];
fid = fopen(in_ffname, 'r');
try
	while isempty(current_line) || iscell(current_line)
		current_line = fgetl(fid);
		if ischar(current_line)
			current_line = strsplit(current_line, '\t', 'CollapseDelimiters', false);
			raw = [raw; current_line]; %#ok<AGROW>
		elseif isnumeric(current_line)
			continue;
		end
	end
catch me
	fclose(fid);
	warning(me.message);
end
fclose(fid);

end

