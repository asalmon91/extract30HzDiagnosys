function isCompatible = verifyDiagnosysFile(in_ffname)
%verifyDiagnosysFile TODO: Documentation!

%% Default
isCompatible = false;

%% Constants
FIRST_CELL = 'Contents Table';

%% Check file for expected first cell
fid = fopen(in_ffname, 'r');
try
	first_line = strsplit(fgetl(fid), '\t');
	fclose(fid);
	isCompatible = strcmp(first_line{1}, FIRST_CELL);
catch me
	fclose(fid);
	% TODO: Handle any expected errors and don't warn
	warning(me.message);
end

end

