function [] = suicm_label(data_in, data_label, n, DATA_MAX, hard, fuzzy, precision)
%SUICM_LABEL Selective Updating ICM
%   'Selective' 

%% Log status
writelog('Selective Updating ICM...');

%% Calculate statistical parameters
% for each label, calculate its average and variance
mu = zeros(1,n);
sigma = zeros(1,n);
for i = 1:n
    cal_data = data_in(find(data_label==i));
    if(num(cal_data)<=1)
        if(num(cal_data)<1)
            mu(i) = 0;
        else
            mu(i) = cal_data;
        end
        sigma(i) = 100;
        writelog('Warning: Some labels get too less voxels,\nresults might be incorrect.');
        continue;
    end
    mu(i) = mean(cal_data);
    sigma(i) = var(cal_data);
end

%% Prepare for ICM Energies
% U1: -log(P(x)) Energy for the intensity-and-label pair.
u_pre = zeros(n, DATA_MAX+1);
% Calculate U1 for pure class
x = 0:DATA_MAX; % Starts calculating fron grey level 0
for i = 1:hard
    ssigma = sigma((i-1)*precision+1);
    mmu = mu((i-1)*precision+1);
    u_pre((i-1)*precision+1,:) = log(sqrt(2*pi)*ssigma) + (x - mmu).^2/(2*ssigma^2);
end
% Calculate U1 for fuzzy class
for i = 1:fuzzy
    for j = 1:precision-1
        sigma1 = sigma((i-1)*precision+1);
        sigma2 = sigma(i*precision+1);
        ssigma = sqrt(((1-j/precision)*sigma1)^2 + (j/precision*sigma2)^2);
        mu1 = mu((i-1)*precision+1);
        mu2 = mu(i*precision+1);
        mmu = (1-j/precision)*mu1 + j/precision*mu2;
        u_pre((i-1)*precision+1+j,:) = log(sqrt(2*pi)*ssigma) + (x - mmu).^2/(2*ssigma^2);
    end
end

%% Prepare for ICM iterations
update_flag = ones(size(data_in));
change_count = size(data_in,1)*size(data_in,2)*size(data_in,3);
iter_count = 1;
TOLERANCE = change_count*precision/1000000;
ITER_MAX = 20;
BETA_ICM_1 = 0.8;
BETA_ICM_2 = 0.8;

%% Iteration begins
writelog('Luckily the preparation for iteration goes well! Iteration now starts...');

while(change_count>TOLERANCE && ITER_COUNT<=ITER_MAX)
    msg = strcat('SU-ICM Performing iteration: ',num2str(iter_count));
    writelog(msg);
    change_count = 0;
    % For each voxel, calculate its optimal label with minimal energy
    % U: U1+U2  U2: Energy for neighborhood
    u = cal_energy(n,u_pre,data_label, data_in, BETA_ICM_1, BETA_ICM_2);
    % Compare energies and redetermine the label
    opt_label = compare_energy(u);
    % Make sure that voxels with 0 grey level don't change
    opt_label(data_in==0) = 0;
    % Count the changed voxels
    change_count = length(find(opt_label~=data_label));
    % Update the selective-update-flags
    % This step follows the C++ project, however, since the calculation is
    % done using matrix operation, it's unnecessary or troublesome to use
    % selective-update flags.
    homo = selective_update(opt_label);
    update_flag(find(homo>4)) = 0; 
    
    iter_count = iter_count + 1;
end

%% Log status
writelog('Selective Updating ICM finished.');

end

function u = cal_energy(n, u1_pre, data_label, data_grey, BETA_ICM_1, BETA_ICM_2)
% Calculate energy U=U1+U2
% u1_pre: n*DATA_MAX U1
[x,y,z] = size(data_label);
u = zeros(n,x,y,z);
% Calculate energy on all labels for each voxels
for i = 1:n
    u(i,:,:,:) = u1_pre(i,data_grey+1); % make sure that grey level 0 has its u.
    u(i,:,:,:) = u(i,:,:,:) + cal_energyU2_hv(data_label,i) * BETA_ICM_1;
    u(i,:,:,:) = u(i,:,:,:) + cal_energyU2_diag(data_label,i) * BETA_ICM_2;
end

% Add the multifractal energy U3
% not finished yet.

end

function U2_hv = cal_energyU2_hv(data_label,label_core)
% Calculate the first part of Energy U2 by checking homogeniety of
% Horizonal-Vertical Neighbors (6)
U2_hv = zeros(size(data_label));
[x,y,z] = size(data_label);
% top
temp_label = zeros(size(data_label));
temp_label(:,:,2:z) = data_label(:,:,1:z-1);
U2_hv = U2_hv + (temp_label==label_core);
% down
temp_label = zeros(size(data_label));
temp_label(:,:,1:z-1) = data_label(:,:,2:z);
U2_hv = U2_hv + (temp_label==label_core);
% left
temp_label = zeros(size(data_label));
temp_label(:,2:y,:) = data_label(:,1:y-1,:);
U2_hv = U2_hv + (temp_label==label_core);
% right
temp_label = zeros(size(data_label));
temp_label(:,1:y-1,:) = data_label(:,2:y,:);
U2_hv = U2_hv + (temp_label==label_core);
% back
temp_label = zeros(size(data_label));
temp_label(2:x,:,:) = data_label(1:x-1,:,:);
U2_hv = U2_hv + (temp_label==label_core);
% front
temp_label = zeros(size(data_label));
temp_label(1:x-1,:,:) = data_label(2:x,:,:);
U2_hv = U2_hv + (temp_label==label_core);
end

function U2_diag = cal_energyU2_diag(data_label,label_core)
% Calculate the second part of Energy U2 by checking homogeniety of Diagnal
% Neighbors (12)
U2_diag = zeros(size(data_label));
[x,y,z] = size(data_label);
% xy plane
U2_diag(1:x-1,1:y-1,:) = U2_diag(1:x-1,1:y-1,:) + (data_label(2:x,2:y,:)==label_core);
U2_diag(1:x-1,2:y,:) = U2_diag(1:x-1,2:y,:) + (data_label(2:x,1:y-1,:)==label_core);
U2_diag(2:x,1:y-1,:) = U2_diag(2:x,1:y-1,:) + (data_label(1:x-1,2:y,:)==label_core);
U2_diag(2:x,2:y,:) = U2_diag(2:x,2:y,:) + (data_label(1:x-1,1:y-1,:)==label_core);
% xz plane
U2_diag(1:x-1,:,1:z-1) = U2_diag(1:x-1,:,1:z-1) + (data_label(2:x,:,2:z)==label_core);
U2_diag(1:x-1,:,2:z) = U2_diag(1:x-1,:,2:z) + (data_label(2:x,:,1:z-1)==label_core);
U2_diag(2:x,:,1:z-1) = U2_diag(2:x,:,1:z-1) + (data_label(1:x-1,:,2:z)==label_core);
U2_diag(2:x,:,2:z) = U2_diag(2:x,:,2:z) + (data_label(1:x-1,:,1:z-1)==label_core);
% yz plane
U2_diag(:,1:y-1,1:z-1) = U2_diag(:,1:y-1,1:z-1) + (data_label(:,2:y,2:z)==label_core);
U2_diag(:,1:y-1,2:z) = U2_diag(:,1:y-1,2:z) + (data_label(:,2:y,1:z-1)==label_core);
U2_diag(:,2:y,1:z-1) = U2_diag(:,2:y,1:z-1) + (data_label(:,1:y-1,2:z)==label_core);
U2_diag(:,2:y,2:z) = U2_diag(:,2:y,2:z) + (data_label(:,1:y-1,1:z-1)==label_core);
end

function opt_label = compare_energy(u)
% Compare energies and return the label with the minimum energy
% u: n*x*y*z
[~,opt_label] = min(u);
opt_label = squeeze(opt_label);
end

function homo = selective_update(data_label)
% Calculate the homogeniety of each voxel, 6-neighbors
homo = zeros(size(data_label));
[x,y,z] = size(data_label);
homo(2:x,:,:) = homo(2:x,:,:) + (data_label(1:x-1,:,:)==data_label(2:x,:,:));
homo(1:x-1,:,:) = homo(1:x-1,:,:) + (data_label(2:x,:,:)==data_label(1:x-1,:,:));
homo(:,2:y,:) = homo(:,2:y,:) + (data_label(:,1:y-1,:)==data_label(:,2:y,:));
homo(:,1:y-1,:) = homo(:,1:y-1,:) + (data_label(:,2:y,:)==data_label(:,1:y-1,:));
homo(:,:,2:z) = homo(:,:,2:z) + (data_label(:,:,1:z-1)==data_label(:,:,2:z));
homo(:,:,1:z-1) = homo(:,:,1:z-1) + (data_label(:,:,2:z)==data_label(:,:,1:z-1));
end
