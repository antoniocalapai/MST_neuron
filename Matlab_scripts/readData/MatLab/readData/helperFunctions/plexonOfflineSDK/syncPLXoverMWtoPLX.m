function y = syncPLXoverMWtoPLX(ts_trialstart, val_trialstart, mw_trialstarts, a, b)
% typ mit übergeben in datum  

y = nan(size(ts_trialstart,1),1);
if numel(val_trialstart) ~= size(ts_trialstart,1)
    disp('Seems like someone is evaluating the syncPLXoverMWtoPLX function')
    return
end

mw_ts_est = (double(a).*ts_trialstart) + double(b) ;
possible_tss = [mw_trialstarts.time_us];

for i=1:length(y)
    possible_ts = possible_tss([mw_trialstarts.data] == val_trialstart(i));
    %possible_ts = possible_tss([mw_trialstarts.data] == bitand((val_trialstart(i) + bin2dec('1000000000000000')), bin2dec('1111111111'))); 
    [val idx] = min(abs(possible_ts-mw_ts_est(i)));
    y(i) = possible_ts(idx);
end

y = (y - double(b)) ./ double(a);
