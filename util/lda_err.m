function [err,pred,post,AUC] = lda_err(pi_k, mu_k, Si, X,y)
% Function to compute LDA error rate

% Data shape
K = length(pi_k);
[N,~] = size(X);

pk = zeros(N,K);
for k = 1:K
    pk(:,k) = pi_k(k)*max(realmin, mvnpdf(X,mu_k(k,:),Si));
end
post = pk./sum(pk,2,'omitnan');

% Compute mean classification error
[~,pred] = max(post, [], 2);
err = mean(pred~=y);

% Compute AUC
if numel(unique(y))==1
    AUC = NaN;
else
    [~,~,~,AUC] = perfcurve(y,post(:,1),1);
end

end
