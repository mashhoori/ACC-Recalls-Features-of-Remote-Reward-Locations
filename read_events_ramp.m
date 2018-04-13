function [epoch_times, trial_events ] = read_events_ramp(cheetah_events_file, labview_log_file)
% read_events_ramp   reads data from effort/ramp experiment raw data files
%                    converts into a more usable format
%                    also checks for and coverts labview timestamps into
%                    cheetah time-frame by comparing two files
%                    can be run without labview_log_file to get epoch_times
% [epoch_times seqevents] = read_events_ramp(cheetah_events_file, labview_log_file);
% cheetah_events_file is the cheetah record of experimental events.  It is
%           recorded as a binary Events.Nev file but must be converted to text for
%           this program to read it.  Use dat2txt_dos or similar program to
%           convert.  Here's an example:
%           !c:\matlab\bin\dat2txt_dos /o:EV /f:C:\matlab\effort_ramp\R1068_01\events.nev
%
%           Note that you can also replace cheetah_events_file with the
%           top-level directory for a particular data set, ommit second
%           argument and it will automatically find Events.txt and
%           EffortVSReward...txt files.
%
% labview_log_file = file of experimental events and timestamps generated
%           by labview control program.  
% 
% epoch_times is an array of the start and stop times of each behavioral epoch
%           they are in microseconds (same as cheetah timestamps)
%           these epochs are denoted by "a" and "b" events inserted into the events.dat file
%           during recording session.
%       epoch_times =
%           [start1 stop1]
%           [start2 stop2]
%           ...
% trial_events[number of trials] - structure array with extracted info for each trial
%       trial_events.feeder_dur[3] - duration in ms for feeder 0 (left), 
%                                    1 (right) and 2 (base)
%       trial_events.gates[2] - 0=blocked, 1=open for gates 0 and 1
%       trial_events.heights[2] - height of ramp 0 and 1 in inches
%       trial_events.feeder_ts[3] - time of feeder opening, feeder 0,1,2 
%       trial_events.feeder_off_ts[3] - time of feeder close, feeder 0,1,2
%       trial_events.choice[1]  - 0 for feeder 0 choice, 1 for feeder 1
%
% Note all timestamps (ts) in trial_events are in NLX reference frame - 
% offset has been added to laview log file events to compensate.  NaN
% values mean ts was not assigned for that trial (i.e., if rat turned left,
% the right feeder ts is NaN)
% 
% Examples:   
% Standard calling technique:
% >> [epoch_times, trial_events ] = read_events_ramp('c:\matlab\effort_ramp\R1353_20\events.txt', 'c:\matlab\effort_ramp\R1353_20\EffortVSReward_2013-11-06_1343_R53_-28_Test_20.txt')
%
% Short version calling technique where program will auto-find event and
% log files:
% >> [epoch_times, trial_events ] = read_events_ramp('c:\matlab\effort_ramp\R1353_20')
% 
% >> trial_events(2)  % this gives trial info for second trial
%
% ans = 
%        feeder_dur: [200 600 200]
%             gates: [0 1.00]
%           heights: [0 0]
%         feeder_ts: [NaN 2195840999.60 2192223785.60]
%     feeder_off_ts: [NaN 2196441004.60 2192423787.60]
%            choice: 1.00
% 
% >> trial_events(10).feeder_dur  % gives feeder pulse durations for 10th trial
% ans =
%          200         600         200
%

% DRE 2014-02-20

% temp for debug
if nargin == 0
     %labview_log_file = 'c:\matlab\effort_ramp\R0935_30\EffortVSReward_2012-11-22_1427_R98_-3_Test_30.txt'
     %cheetah_events_file = 'c:\matlab\effort_ramp\R0935_30\Events.txt'
     
     labview_log_file = 'C:\Users\a.mashhoori\Desktop\Proj\P1958_25p\EffortVSReward_2014-09-02_1721_R58_2_Test_25.txt';
     cheetah_events_file = 'C:\Users\a.mashhoori\Desktop\Proj\P1958_25p\Events.txt';
end;

% shortcut - if user passes in only a directory, find event and log file
% automatically within that directory
if nargin == 1 && isdir(cheetah_events_file)
    file1 = recursiveFindFile(cheetah_events_file, 'EffortVSReward_*.txt');
    labview_log_file = file1{1};
    file2 = recursiveFindFile(cheetah_events_file, 'Events*.txt');
    cheetah_events_file = file2{1};
    if isempty(file1{1}) || isempty(file2{1})
        disp('files not found in specified directory');
        return;
    end;
    disp('Using files:');
    disp(file1{1});
    disp(file2{1});
    files_found = true;
end;

% %%%%%%%%%%%%%%%%%%%%%%% READ NEURALYX EVENTS FILE %%%%%%%%%%%%%%%%%%
% from events file we extract times of feeders and times of start and stop
% of each epoch (denoted by "a" and "b" events entered by user during
% recording
end_of_line_char = 10;

epoch_times = zeros(1,2);  % 
if ~isempty(cheetah_events_file)
    fid = fopen(cheetah_events_file);
    if fid==-1
        error(['Could not open file: ' cheetah_events_file]);
    end;

    end_of_line_char = 10;

    i = 1;
    epoch_row = 0;
    last_flag = '';

    [newdata] = fread(fid, inf, 'uchar');  % read the entire file into a string
    filedata = char(newdata);
    fclose(fid);
    line_ends = find(filedata==end_of_line_char);
    start_strpos = 1;

    % pre-allocate storage for faster execution
    num_lines = length(line_ends);
    feeder_timestamps_nlx = zeros(num_lines,1);
    
    for j = 1:length(line_ends)

        curline = filedata(start_strpos:line_ends(j)-2)';  % note we skip back two places to avoid the linespace and carriage return that are both used in dos text files for a return
        %disp(curline)
        start_strpos = line_ends(j)+1;

        % deal with header and blank lines
        if length(curline)<5 || all(curline(1:4)=='none')
            continue;
        end;
        [ts] = sscanf(curline, '%*i,%*i,%*i,%lf');
        [eventstr] = sscanf(curline, ...
            '%*i,%*i,%*i,%*lf,%*i,%*i,%*i,%*i,%*i,%*i,%*i,%*i,%*i,%*i,%*i,%*i,%*i,%60c');
        [m, n] = size(eventstr);
        if m>n  % needed for version matlab 7.5
            eventstr = char(eventstr');
        end;
        ttltxti = strfind(eventstr, '(0x');

        if ~isempty(ttltxti) && length(eventstr)>=38

            ttlvalstr = eventstr(ttltxti+3:ttltxti+6); % note: values look like:
                % 0xE080, we strip off the 0x
            ttlvalbin = dec2bin(hex2dec(ttlvalstr),16);  % (e.g., 0000000000000010)
            % the 15th bit flips on for feeder opens and off when feeder closes
            
            if ttlvalbin(15)=='1'
                feeder_timestamps_nlx(i) = ts;
                i = i+1;
            end;
            
        else  % if ~isempty(ttltxti) & length(eventstr)>=38
            % NOW PROCESS ANY NON-TTL INPUT
            % Process the User entered event codes which denote epochs

            cur_event_flag = sscanf(eventstr, '%s');  % remove white space
            switch cur_event_flag
                case 'a'
                    if ~isempty(last_flag) && (last_flag == 'a')
                        disp(['Warning: Missing "b" event flag before "a" at timestamp ' num2str(ts)])
                    end;
                    epoch_row = epoch_row + 1;
                    epoch_times(epoch_row, 1) = ts;
                    last_flag = 'a';
                case 'b'
                    if last_flag ~= 'a'
                        disp(['Warning: "b" event flag without "a" at timestamp ' num2str(ts)])
                        epoch_row = epoch_row + 1;
                    end;
                    epoch_times(epoch_row, 2) = ts;
                    last_flag = 'b';
                case 'StartingRecording'

                case 'StoppingRecording'
                    
                otherwise
                    disp(['Warning: Unknown User Input Event, "' eventstr '" , at timestamp ' num2str(ts)])
            end;

        end;  % if ~isempty(ttltxti) & length(eventstr)>=38

    end;

    % CUT OFF NON-ALLOCATED VALUES FROM THE END OF LISTS
    % note that we pre-allocated space for these variables,
    % set to the number of lines in the file.
    % Since not every line is a valid event, there are extra zeros
    % at the end of every variable.  Here, we remove those zeros.
    feeder_timestamps_nlx = feeder_timestamps_nlx(1:i-1,:);

end;

% in case user just wanted event times
if nargin==1 && ~files_found
    return;
end;

 fid = fopen(labview_log_file);
 if fid == -1
     error(['Could not open file: ' labview_log_file]);
 end
 
 [newdata, readcnt] = fread(fid, inf, 'uchar');
 filedata = char(newdata);
 fclose(fid);

 line_ends = find(filedata == end_of_line_char);
 start_strpos = 4;
 
 num_lines = length(line_ends);
 importdata= zeros(num_lines, 10);

k = 1;

for j = 1:length(line_ends)
    curline = filedata(start_strpos:line_ends(j) - 2)';
    
    start_strpos = line_ends(j)+1;
    str_i = strmatch('%', curline);
    
    % ignore comments
    if str_i ==1
        continue;
    end
    
    c = sscanf(curline, '%lf,%lf,%i,%i,%i,%i,%i,%i,%i,%i')';
    
    importdata(k, 1:length(c)) = c;
    
    k = k+1;
    
end

% FIND OFFSET BETWEEN NEURALYNX AND NI (LABVIEW) TIMERS. 
% note labview log file contains two columns of timestamps - first is timestamps that were
% received from cheetah over netcom, which are really sloppy.  The second
% timestamps come from the NI card clock (via labview), which is driven by the cheetah
% pulse output and is very accurate.  
% the labview log contains all experiment events while the cheetah events
% file contains only the time of sync pulses, which are event type 1 in the
% labview log.  However, these events are sent whenever feeder opens, so we
% use event 30 (with state=1) instead.

% trim off extra zeros at end of matrix
newmatrix = importdata(1:(k-1),:);
pp = newmatrix(newmatrix(:, 2) ~= 0, [1, 2] );


% extract times of feeder opening
% note feeder_timestamps_lv has two columns - first is netcom-derived cheetah timestamps, second are NI-derived hardware timestamps
feeder_timestamps_lv = (newmatrix(newmatrix(:,3)==30 & newmatrix(:,4)==1,1:2));

% COMPUTE THE TRUE OFFSET BETWEEN NEURALYNX AND LABVIEW CLOCKS
%   we take the difference between each feeder event for both events and 
%   labview (LV) files.  We take a block of 10 labview differences and
%   slide it over the event file differences until we find the best match.
%   This gives one estimate of the offset between LV and EV files.
%   Next, we take the next block of 10 trials from LV and repeat.
%   We then take the median offset from all of these estimates
%   as the true offset.  
%   The small blocks were necessary because in some cases the LV file is
%   missing specific feeder events.  Hence, if we just tried to slide all
%   the LV diffs against all the EV diffs, they don't match very well.  We
%   have to take it in chunks that are small enough so that the majority of
%   chunks will not be missing values and we'll get a good match.
%
%   Note that the first timestamp comes from cheetah via netcom so is not
%   very accurate and so we don't even use it for this evaluation.

block_size = 10;
all_offsets = zeros(length(feeder_timestamps_lv)-block_size-1,1);
diff_ts_nlx = diff(feeder_timestamps_nlx);
diff_ts_lv = diff(feeder_timestamps_lv);
%n_nlx_ts = length(feeder_timestamps_nlx);

for i = 1:length(diff_ts_lv)-block_size
%     if mod(i,100)==0
%         disp(['computing Neuralynx/Labview offset for block ' num2str(i) '/' num2str(length(diff_ts_lv)-block_size)]);
%     end;
    cur_ts_diff_lv = diff_ts_lv(i:i+block_size-1,2);
    abs_diff = zeros(1,length(diff_ts_nlx)-block_size-1);
    for j = 1:length(diff_ts_nlx)-block_size-1;
        cur_ts_diff_nlx = diff_ts_nlx(j:j+block_size-1);
        abs_diff(j) = sqrt(sum((cur_ts_diff_nlx - cur_ts_diff_lv).^2)); 
    end;
    [~, best_match_j(i)] = min(abs_diff);
    
    all_offsets(i) = mean(feeder_timestamps_nlx(best_match_j(i):best_match_j(i)+block_size-1) - feeder_timestamps_lv(i:i+block_size-1,2));
    
end;

all_offsets2 = pp(:, 1) - pp(:, 2);

best_offset2 = median(all_offsets2);
best_offset = median(all_offsets);  % this is how much further nlx is ahead of labview timestamp
                                       % we need to add this value to
                                       % labview NI clock timestamps to get
                                       % corresponding cheetah timestamps

 best_offset = best_offset2;                                      
                                       
disp(['timestamp offset:  cheetah event file ts - NI ts = ' num2str(best_offset) ' microsec']); 

%best_offset = 0;
% now read data again, this time extracting trial information which we will
% convert into the neuralynx timeframe.  

% PARSE TRIAL START AND EVENT INFO FROM FILE STRING
% On first pass, we find all the
% 'State = ' commands and read all numeric data into a variable

 num_lines = length(line_ends);
 importdata= zeros(num_lines, 10);
 start_strpos = 1;

k = 1;
trial_start_info = struct([]);
trial_start_i = 0;

for j = 1:length(line_ends)
    curline = filedata(start_strpos:line_ends(j) - 2)';
    
    start_strpos = line_ends(j)+1;
    
    % process '% State = ' comments - these indicate start of trial
    % ignore other comments
    comment = strncmp('%', curline, 1);
    if comment
        if strncmp('% State =', curline, 9)
            curline2 = curline;
            curline2(curline2==',') = ' ';  % remove commas and replace with space
            c  = textscan(curline2,'%% State = %d %d %d %d %f %f %s %s');
            trial_start_i = trial_start_i + 1;
            trial_start_info(trial_start_i).line_no = j;
            trial_start_info(trial_start_i).trial_no = c{1};
            trial_start_info(trial_start_i).feeder_dur = [c{2} c{3} c{4}];
            trial_start_info(trial_start_i).heights = [c{5} c{6}];
            trial_start_info(trial_start_i).gates = [-1 -1];  % note that 1 = open, 0 is blocked, -1 indicates error in reading info from file
            if strncmp(c{7}, 'True', 4)
                trial_start_info(trial_start_i).gates(1) = 1;
            end;
            if strncmp(c{7}, 'False', 4)
                trial_start_info(trial_start_i).gates(1) = 0;
            end;
            if strncmp(c{8}, 'True', 4)
                trial_start_info(trial_start_i).gates(2) = 1;
            end;
            if strncmp(c{8}, 'False', 4)
                trial_start_info(trial_start_i).gates(2) = 0;
            end;
        end
    end
    
    if ~comment
        c = sscanf(curline, '%lf,%lf,%i,%i,%i,%i,%i,%i,%i,%i')';
        % note first line of importdata will be file line number, used to
        % comparing with trial_start_info data from '% State = ' lines
        importdata(k, 1:length(c)+1) = [j c];
        k = k+1;
    end;
      
end

% PROCESS THE TRIALS
trial_events = struct([]);  % create empty structure
trial_cnt = 0;
for i = 1:length(trial_start_info)-1 % note we omit last trial, which is usually incomplete

    % find start and stop of current trial events in file line numbers
    block_start = trial_start_info(i).line_no + 1;
    block_end = trial_start_info(i+1).line_no - 1;
    
    % now convert those numbers into an index into the importdata array
    start_i = find(importdata(:,1)== block_start);
    end_i = find(importdata(:,1)== block_end);
    
    % look for any feeder events in this block
    % if not found, this is a spurious trial start - this can happen if the
    % rat backtracks (i.e., goes from zone 2 back to zone 1 the short way)
    if ~any(importdata(start_i:end_i, 4)==30)
        disp(['Skipping State Event on line: ' num2str(trial_start_info(i).line_no) ' State Event #: ' num2str(i) ' because no feeder events found after that event']);
        continue
    end;
    trial_cnt = trial_cnt + 1;
    
    trial_events(trial_cnt).feeder_dur = trial_start_info(i).feeder_dur;  % how long feeders stayed open, in ms for feeder [0 1 2]
    trial_events(trial_cnt).gates = trial_start_info(i).gates;            % state of gates # 0 and 1 where 0 = blocked and 1 = open
    trial_events(trial_cnt).heights = trial_start_info(i).heights;        % height of ramp 0 and ramp 1, in inches
    
    trial_events(trial_cnt).feeder_ts = [NaN NaN NaN];
    trial_events(trial_cnt).feeder_off_ts = [NaN NaN NaN];
    for bi = block_start:block_end
        cur_event = importdata(importdata(:,1)==bi,2:end);
        % extract ts for feeder open events
        
        if(numel(cur_event) < 4)
            continue
        end
        
        if cur_event(3)==30 && cur_event(4) == 1
            switch cur_event(5)
                case 0
                    if ~isnan(trial_events(trial_cnt).feeder_ts(1))
                        disp('Warning:  multiple zone 0 rewards within same trial block');
                        disp(['Current ts (NI value): ' num2str(cur_event(2))]);
                    end;
                    trial_events(trial_cnt).feeder_ts(1) = cur_event(2) + best_offset;  % timestamp in microseconds, NLX reference
                case 1
                    if ~isnan(trial_events(trial_cnt).feeder_ts(1))
                        disp('Warning:  multiple zone 1 rewards within same trial block');
                        disp(['Current ts (NI value): ' num2str(cur_event(2))]);
                    end;
                    trial_events(trial_cnt).feeder_ts(2) = cur_event(2) + best_offset;
                case 2
                    if ~isnan(trial_events(trial_cnt).feeder_ts(1))
                        disp('Warning:  multiple zone 2 rewards within same trial block');
                        disp(['Current ts (NI value): ' num2str(cur_event(2))]);
                    end;
                    trial_events(trial_cnt).feeder_ts(3) = cur_event(2) + best_offset;
            end;    
        end;
        % extract ts for feeder close events
        if cur_event(3)==30 && cur_event(4) == 0
            switch cur_event(5)
                case 0
                    trial_events(trial_cnt).feeder_off_ts(1) = cur_event(2) + best_offset;  % timestamp in microseconds, NLX reference
                case 1
                    trial_events(trial_cnt).feeder_off_ts(2) = cur_event(2) + best_offset;
                case 2
                    trial_events(trial_cnt).feeder_off_ts(3) = cur_event(2) + best_offset;
            end;    
        end;
        
        
    end;  % for bi - trial block loop
    % sanity check - check to make sure feeder open events were read
    if isnan(trial_events(trial_cnt).feeder_ts(1)) && isnan(trial_events(trial_cnt).feeder_ts(2))
        disp(['No choice arm feeder onset at file line: ' num2str(trial_start_info(i).line_no) ' Trial #: ' num2str(trial_cnt) ' ...Fixing from EV file']);
        
        % find zone entry event, then use this to find nearest feeder event
        % in cheetah events file and use the timestamp from that
        ze_i = find(importdata(start_i:end_i, 4)==5 & (importdata(start_i:end_i, 6)==0 | importdata(start_i:end_i, 6)==1)); 
        if ~isempty(ze_i) && length(ze_i) == 1
            zone_entry_ts = importdata(ze_i - 1 + start_i,2);
            % look for best matching cheetah events file timestamp after
            % zone entry
            feeder_ts_after = feeder_timestamps_nlx(feeder_timestamps_nlx> zone_entry_ts);
            [min_val min_i] = min(feeder_ts_after - zone_entry_ts);
            best_match_ts = feeder_ts_after(min_i);
            selected_zone = importdata(ze_i - 1 + start_i,6);
            if min_val<260000  % validate - feeder open should happen with 260 ms of zone entry - checked this against other data sets
                trial_events(trial_cnt).feeder_ts(selected_zone + 1) = best_match_ts; % no offset added because ts comes from EV file
            else
                disp('Possible bad match of feeder ts to zone entry - cannot fix missing feeder ts');
            end;
        else
            disp('Warning: could not find corresponding zone entry - cannot fix missing feeder ts');
        end;
        
    end;
    if isnan(trial_events(trial_cnt).feeder_ts(3))
        disp(['Warning: No base feeder onset event at file line: ' num2str(trial_start_info(i).line_no) ' Trial #: ' num2str(trial_cnt)]);
    end;
    if ~isnan(trial_events(trial_cnt).feeder_ts(1))
        trial_events(trial_cnt).choice = 0;      
    else
        trial_events(trial_cnt).choice = 1;
    end;       
    
end;
return;
