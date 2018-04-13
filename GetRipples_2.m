function ripples_bool = GetRipples_2(folderPath, timepoints)

[ts, eeg, header, nog] = load_csc([folderPath, 'EEG_Diff_4-3.ncs']);
ts = ts * 1000;
filter_coefficients = BPF_FIR_150_250Hz_Order200_Fs2000;
eegFiltered = filtfilt(filter_coefficients.Numerator, 1, eeg);
eegFiltered = zscore(eegFiltered);


startIndex = timepoints(1);
endIndex = timepoints(end);

eegFiltered = eegFiltered(ts >= startIndex & ts <= endIndex);
ts = ts(ts >= startIndex & ts <= endIndex);

%%

[ripples, sd, bad] = FindRipples([ts/1000 eegFiltered]);
ripples_indx = round(ripples(:, [1 3]) * 1000);

ripples_bool = zeros(1, length(timepoints));
for i = 1:length(ripples_indx)
    ripples_bool( timepoints >= ripples_indx(i, 1) & timepoints <= ripples_indx(i, 2) )  = 1;      
end


end