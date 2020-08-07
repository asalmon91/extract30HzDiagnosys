function [amp_30Hz_nV_ch1_ch2, f_out] = procDiagnosysisFile(in_ffname)
%procDiagnosysisFile TODO: Documentation!
% TODO: Contents Table and Data Table TOC could make it simpler to find things
% TODO: do more than just 30Hz
% TODO: figure out which channel belongs to which eye

%% Constants
% Stimulus
STIM_TABLE_LABEL = 'Stimulus Table';
STIM_TABLE_WD = 3;
STEP_LABEL = 'Step';
DESC_LABEL = 'Description';
TRG_STIM_SUBSTR = '30Hz';

% Data
DATA_TABLE_LABEL = 'Data Table';
% CHANNEL_LABEL = 'Chan';
DATA_START = 4; % 4th row of raw

%% Read the whole table
raw = readDiagnosysXls(in_ffname);
head_1 = raw(1, :); % Table headers
head_2 = raw(2, :); % Data headers

%% Find the stimulus table
% Find stimulus columns
stim_c = strcmpi(head_1, STIM_TABLE_LABEL);
stim_c(find(stim_c):find(stim_c)+STIM_TABLE_WD -1) = true;
step_c = stim_c & strcmpi(head_2, STEP_LABEL);
desc_c = stim_c & strcmpi(head_2, DESC_LABEL);
% Determine row of target stimulus
trg_row = find(contains(raw(:, desc_c), TRG_STIM_SUBSTR));
% Determine step # of target stimulus
step_id = raw{trg_row, step_c}; %#ok<FNDSB> raw is really tall, this saves ~1kB

%% Find the data table
% Find data table starting column
data_c = strcmpi(head_1, DATA_TABLE_LABEL);
data_c(find(data_c):end) = true; % Data table is always last
% Find the recording of interest
trg_step_c = data_c & strcmpi(head_2, sprintf('%s %i', STEP_LABEL, round(str2double(step_id))));
t_ms = raw(DATA_START:end, trg_step_c);
c1_nV = raw(DATA_START:end, find(trg_step_c) +1);
c2_nV = raw(DATA_START:end, find(trg_step_c) +2);

%% Filter time and recording arrays
% Convert arrays to double
t_ms = cell2mat(cellfun(@str2double, t_ms, 'uniformoutput', false));
c1_nV = cell2mat(cellfun(@str2double, c1_nV, 'uniformoutput', false));
c2_nV = cell2mat(cellfun(@str2double, c2_nV, 'uniformoutput', false));

t_filt = ~isnan(t_ms) & t_ms >= 0; % Remove empty rows and pre-stimulus rows
% Filter arrays and convert to int32
t_ms = int32(t_ms(t_filt));
c1_nV = int32(c1_nV(t_filt));
c2_nV = int32(c2_nV(t_filt));

%% Time specifications:
Fs = 1000; % samples per second
dt = 1/Fs; % seconds per sample
StopTime = 0.5; % seconds
t = (0:dt:StopTime-dt)';
N = size(t,1);

%%Sine wave:
% Fc = 12;                       % hertz
% x = cos(2*pi*Fc*t);

%% Fourier Transform:
c1_fft = abs(fftshift(fft(c1_nV)))./N;
c2_fft = abs(fftshift(fft(c2_nV)))./N;

%% Frequency specifications:
dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz

%% Extract 30Hz amplitude
% Filter spectrum to 30±10Hz band
% TODO: don't hard-code so bad
f_filt = f >= 26 & f <= 34;
ch1_30Hz_amp_nV = interp1(f(f_filt), c1_fft(f_filt), 30);
ch2_30Hz_amp_nV = interp1(f(f_filt), c2_fft(f_filt), 30);

% ch1_30Hz_amp_nV = max(abs(c1_fft(f_filt))./N);
% ch2_30Hz_amp_nV = max(abs(c2_fft(f_filt))./N);

%% Package output
amp_30Hz_nV_ch1_ch2 = [ch1_30Hz_amp_nV; ch2_30Hz_amp_nV];

%% Plot the spectrum:
if nargout == 2
	legend_labels = {'Ch1', 'Ch2', 'Ch1 30Hz', 'Ch2 30Hz'};
	fnm = 'arial';
	fsz = 16;
	fw = 'bold';

	% Raw signal
	f_out = figure;
	subplot(1,3,1);
	hold on;
	plot(t_ms, c1_nV./1e3, '-r');
	plot(t_ms, c2_nV./1e3, '-b');
	hold off;
	xlim([0, 500]);
	xlabel('Time (ms)', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	ylabel('Amplitude (\muV)', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	set(gca, 'tickdir', 'out');
	legend(legend_labels, 'location', 'northeast', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	title('Averaged recording');

	subplot(1,3,2);
	hold on;
	plot(f, c1_fft./1e3, '-r');
	plot(f, c2_fft./1e3, '-b');
	hold off;
	xlabel('Frequency (Hz)', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	ylabel('Magnitude Response (\muV)', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	set(gca, 'tickdir', 'out');
	legend(legend_labels, 'location', 'northeast', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	title('Response Density');
	
	subplot(1,3,3);
	hold on;
	plot(f(f_filt), c1_fft(f_filt)./1e3, '-r');
	plot(f(f_filt), c2_fft(f_filt)./1e3, '-b');
	plot(30, ch1_30Hz_amp_nV./1e3, 'xr')
	plot(30, ch2_30Hz_amp_nV./1e3, 'xb')
	hold off;
	xlabel('Frequency (Hz)', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	ylabel('Magnitude Response (\muV)', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	set(gca, 'tickdir', 'out');
	legend(legend_labels, 'location', 'northeast', 'fontname', fnm, 'fontsize', fsz, 'fontweight', fw);
	title('Filtered Response')
	
	% Title
	[~, erg_name, ~] = fileparts(in_ffname);
	st = suptitle(erg_name);
	st.Interpreter = 'none';
end


end

