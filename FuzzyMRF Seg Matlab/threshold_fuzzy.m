function threshold = threshold_fuzzy(mu, precision, DATA_MAX)
%THRESHOLD_FUZZY set the threshold for each labels. the labels here are
%               expanded to (hard-1)*precision+1 labels.

n = (length(mu)-1)/2;
threshold = zeros(1,n*precision+2);
threshold(end) = DATA_MAX;
for i = 0:n-1
    for j = 1:precision
        interval = (mu(2*i+3) - mu(2*i+1))/(precision+1);
        threshold(i*precision+1+j) = mu(2*i+1) + j*interval;
    end
    
end
threshold = round(threshold);

end

