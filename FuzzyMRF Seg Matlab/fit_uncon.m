function [mu, sigma, weight] = fit_uncon(histo, mu)
%FIT_UNCON Function to carry out the fitting operation, using Unconstrained
%           Levenberg-Marquardt Method
%  
% weight: 1*classes array. Weight of Gaussian distribution.
% sigma: 1*classes array. Sigma of Gaussian distribution.

%% Log status
writelog('Gaussian fitting processing...');

%% Initialize weight and sigma
sigma_value = round(length(histo)/2/length(mu));
weight = histo(mu) * 2.5066 * sigma_value;
sigma = sigma_value * ones(1,length(mu));

%% Calculate Jacobian Expression of Gaussian Distribution
syms wweight mmu ssigma x;
G = 0.3989 * wweight / ssigma * exp(-(x-mmu)^2/2/ssigma^2); % 1/sqrt(2*pi) = 0.3989
jac_Exp = jacobian(G,[wweight, mmu, ssigma]);

%% Determine the error threshold e
[f,s] = generate_f(histo, weight, mu, sigma);
jac = generate_jac(histo, weight, mu, sigma, jac_Exp);
H = jac'*jac;   % Hessian Matrix
e = 0.01*norm(jac'*f');

%% Iteration
updateJ = 0;
lambda = 0.01;
BETA_FIT = 5;
iter_count = 0;
while(iter_count <= 50)
    % iteration stops
    if(norm(jac'*f') < e)
        break;
    end
    % if the parameters are updated, then calculate jac, H, f
    if(updateJ == 1)
        jac = generate_jac(histo, weight, mu, sigma, jac_Exp);
        H = jac'*jac;   % Hessian Matrix
    end
    % Calculate step d, Estimate possible new parameters
    d = -(H + lambda*eye(3*length(mu)))\(jac'*f');  % (3*Gaussnum) * 1
    weight2 = weight + d(1:3:3*length(mu))';
    mu2 = mu + d(2:3:3*length(mu))';
    sigma2 = sigma + d(3:3:3*length(mu))';
    [f2,s2] = generate_f(histo, weight2, mu2, sigma2);
    if(s2 < s)
        lambda = lambda / BETA_FIT;
        weight = weight2;
        mu = mu2;
        sigma = sigma2;
        f = f2;
        s = s2;
        updateJ = 1;
    else
        updateJ = 0;
        lambda = lambda * BETA_FIT;
    end
    iter_count = iter_count + 1;
end

%% Sort the Gaussian parameters by mu
[mu, order] = sort(mu);
weight = weight(order);
sigma = sigma(order);

%% Log status
msg = strcat('Gaussian Fitting finished. Iteration times: ', num2str(iter_count));
writelog(msg);

end

%% Differences between histogram and mix-Gaussian distribution in each gray-level, Square Error
function [f,s] = generate_f(histo, weight, mu, sigma)
tmp = zeros(size(histo));
for i = 1:length(mu)
    tmp = tmp + weight(i)*normpdf(1:length(histo),mu(i),sigma(i));
end
f = histo - tmp;
s = sum(f.*f);  % square error
end

%% Jacobian Matrix with current parameters
function jac = generate_jac(histo, weight, mu, sigma, jac_Exp)
% jac: length * (3*gauss_num) matrix.
jac = zeros(length(histo),3*length(mu));
x = (1:length(histo))';
for i = 1:length(mu)
    wweight = weight(i);
    mmu = mu(i);
    ssigma = sigma(i);
    jac(:,(i-1)*3+1:i*3) = eval(jac_Exp);
end
end