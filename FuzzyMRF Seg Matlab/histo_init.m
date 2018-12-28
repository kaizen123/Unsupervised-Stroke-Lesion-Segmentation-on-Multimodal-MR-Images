function [histo,mu,min_range,max_range] = histo_init(data_array, hard, fuzzy)
%HISTO_INIT initialize the Gaussian parameters, mainly for the averages(mu).
%
%
% In the original Tumour C++ Project, the sequence is like "Smooth the
% histogram -> Effective range of histogram -> Fill the holes in
% histogram". However, it doesn't fit for some specific data (like a big
% gap of 0 value). Hence the sequence is adjusted.
%
% The initialization of mu has changed! The new method is kmeans, while the
% former method is to find n highest peaks.
%% Set histogram
histo = histcounts(data_array, 1:(DATA_MAX+1)); % histogram of input data

%% Fill the holes in histogram
for i = 2:length(histo)
    if(histo(i)==0)
        histo(i) = histo(i-1);
    end
end
%% Smooth the histogram
for i = 2:(length(histo)-1)
    histo(i) = (histo(i-1)+histo(i)+histo(i+1))/3;
end

%% Remove Skull artifact (value smaller than 100)
% artifact_threshold = 100;
% histo(1:artifact_threshold) = 0;

%% Effective range of histogram
[amp_max, amp_loc] = max(histo);
amp_threshold = amp_max * 0.01;
tmp = find(histo(1:amp_loc(1))<amp_threshold);
min_range = tmp(end);
tmp = find(histo(amp_loc(end):end)<amp_threshold);
max_range = tmp(1)+amp_loc(end)-1;

%% Initialize mu of the histogram
[~, hard_mu] = kmeans(data_array', hard);
mu = zeros(1,hard+fuzzy);
hard_mu = sort(hard_mu);
mu(1:2:(hard+fuzzy)) = hard_mu;
for i = 1:fuzzy
    mu(2*i) = (mu(2*i-1)+mu(2*i+1))/2;
end

%% standardize the histogram
histo = histo / max(histo) *10;

%% Check and Log
if(~isempty(find(hard_mu<min_range)) || ~isempty(find(hard_mu>max_range)))
    writelog('Warning: some initial averages(mu) exceed the effective range! Results might be wrong!');
end

if(~isempty(find(diff(hard_mu)<((max_range-min_range)/hard/4))))
    writelog('Warning: some initial averages(mu) are too close! Results might be affected!');
end

end

