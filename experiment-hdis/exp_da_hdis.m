function exp_da_hdis(varargin)
% Domain adaptation experiment on the heart disease dataset

% Parse hyperparameters
p = inputParser;
addOptional(p, 'cix', []);
addOptional(p, 'clf', 'slda');
addOptional(p, 'nC', 3);
addOptional(p, 'nR', 1);
addOptional(p, 'nF', 5);
addOptional(p, 'lr', 'geom');
addOptional(p, 'prep', {''});
addOptional(p, 'maxIter', 1e4);
addOptional(p, 'xTol', 1e-10);
addOptional(p, 'alpha', 1);
addOptional(p, 'lambda', []);
addOptional(p, 'gamma', .1);
addOptional(p, 'useGamma', true);
addOptional(p, 'iwe', 'kmm');
addOptional(p, 'clip', 1000);
addOptional(p, 'NN', []);
addOptional(p, 'NM', []);
addOptional(p, 'dataName', 'heart_disease');
addOptional(p, 'saveName', 'results/');
parse(p, varargin{:});

% Report which classifier
disp(['Running: ' p.Results.clf]);

% Load dataset
try
    load(p.Results.dataName)
catch
    cd('../data/hdis')
    [D,y,domains,~] = get_hdis('save', true, 'impute', true);
    copyfile heart_disease.mat ../../experiment-hdis/
    cd('../../experiment-hdis')
end 
disp(['Loaded dataset: ' p.Results.dataName]);

% Preprocess data
D = da_prep(D, p.Results.prep);

% Source-Target combinations
nD = length(domains)-1;
cc = [nchoosek(1:nD,2); fliplr(nchoosek(1:nD,2))];
if isempty(p.Results.cix)
    cmbl = 1:size(cc,1);
else
    cmbl = p.Results.cix;
end

for n = cmbl
    
    % Split out source and target
    ixS = domains(cc(n,1))+1:domains(cc(n,1)+1);
    ixT = domains(cc(n,2))+1:domains(cc(n,2)+1);
    
    % Run estimator
    switch p.Results.clf
        
        % Source classifiers
        case 'slda'
            exp_da_sda(D(ixS, :),y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'lambda',p.Results.lambda, 'clf', 'lda');
        case 'sqda'
            exp_da_sda(D(ixS, :),y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'lambda',p.Results.lambda, 'clf', 'qda');
        case 'sls'
            exp_da_sls(D(ixS, :),y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'lambda',p.Results.lambda);
            
        % Domain-adaptive classifiers
        case 'tcp-lda'
            exp_da_tcp(D(ixS,:), y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'maxIter', p.Results.maxIter, 'xTol', p.Results.xTol, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'alpha', p.Results.alpha, 'lambda', p.Results.lambda, 'clf', 'tcp-lda');
        case 'tcp-qda'
            exp_da_tcp(D(ixS,:), y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'maxIter', p.Results.maxIter, 'xTol', p.Results.xTol, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'alpha', p.Results.alpha, 'lambda', p.Results.lambda, 'clf', 'tcp-qda', 'lr', p.Results.lr);
        case 'tcp-ls'
            exp_da_tcp(D(ixS,:), y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'maxIter', p.Results.maxIter, 'xTol', p.Results.xTol, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'alpha', p.Results.alpha, 'lambda', p.Results.lambda, 'clf', 'tcp-ls');
        case 'kmm-lsq'
            exp_da_iwc(D(ixS,:), y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'maxIter', p.Results.maxIter, 'xTol', p.Results.xTol, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'iwe', 'kmm', 'clf', 'lsq');
        case 'kmm-lr'
            exp_da_iwc(D(ixS,:), y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'maxIter', p.Results.maxIter, 'xTol', p.Results.xTol, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'iwe', 'kmm', 'clf', 'lr');
        case 'rba'
            exp_da_rba(D(ixS,:), y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'maxIter', p.Results.maxIter, 'xTol', p.Results.xTol, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'gamma', p.Results.gamma, 'lambda', p.Results.lambda,'clip', p.Results.clip, 'iwe', p.Results.iwe);
        case 'rcsa'
            exp_da_rcsa(D(ixS,:), y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'maxIter', p.Results.maxIter, 'xTol', p.Results.xTol, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'useGamma', p.Results.useGamma, 'lambda', p.Results.lambda);
        case 'tca'
            exp_da_tca(D(ixS,:), y(ixS), D(ixT,:), y(ixT), 'NN', p.Results.NN, 'nR', p.Results.nR, 'nF', p.Results.nF, 'maxIter', p.Results.maxIter, 'xTol', p.Results.xTol, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'lambda', p.Results.lambda, 'nC', p.Results.nC);
            
        % Target classifiers
        case 'tlda'
            exp_da_tda(D(ixT,:), y(ixT), 'NM', p.Results.NM, 'nR', p.Results.nR, 'nF', p.Results.nF, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'lambda',p.Results.lambda, 'clf', 'lda');
        case 'tqda'
            exp_da_tda(D(ixT,:), y(ixT), 'NM', p.Results.NM, 'nR', p.Results.nR, 'nF', p.Results.nF, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'lambda',p.Results.lambda, 'clf', 'qda');
        case 'tls'
            exp_da_tls(D(ixT, :),y(ixT),'NM', p.Results.NM, 'nR', p.Results.nR, 'nF', p.Results.nF, 'saveName', [p.Results.saveName p.Results.dataName '_prep' p.Results.prep{logical(cellfun(@isstr, p.Results.prep))}  '_cc' sprintf('%1i', n) '_nR' num2str(p.Results.nR) '_'], 'lambda',p.Results.lambda);
        otherwise
            disp(['Classifier not recognized']);
    end
end

end
