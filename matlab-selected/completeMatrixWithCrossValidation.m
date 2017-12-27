function [ completedMatrix, testError, overallError, lowResidual, matrix, recommendedKeywords ] = completeMatrixWithCrossValidation(file, k, normalize, numIterationsForCompletion, numTimesToDoCompletion, entryType, useZeros, method, fold, numberOfFolds, alpha, beta)
%COMPLETE MATRIX WITH CV Builds a user-keyword matrix with Shoah data and then completes
%it via matrix factorization in order to make recommendations. unknown
%entries are reprented with NaN. can be also be a complete matrix.

%   file = csv file with the data: column headers are niceUserID, UserID,
%     niceKeywordID, KeywordID, FrequencyEntry, BinaryEntry (the nice IDs start at one and
%     don't skip any numbers so they correspond directly to matrix indices)
%     (the frequency entry is what goes in the matrix when entryType = 2)
%     (the binary entry is what goes in the matrix when entryType = 1)
%   k = number of latent features, inner dimension in matrix factorization
%   normalize = boolean value, true if you want user-keywords matrix to be
%     normalized, false otherwise. normalizes by dividing each entry by its
%     row sum.
%   numIterationForCompletion = input to wnmfrule, max number of iterations
%   numTimesToDoCompletion = number of times that matrix completion will be
%     done - result with lowest residual will be taken (since algorithm
%     converges to local optimum)
%   entryType = 1: binary entries, 2: frequency entries, 3: log base 10 of
%       frequency entries
%   zeros = boolean, false if the unobserved values are NaN, true otherwise
%   method = 0 - wnmfrule matrix completion, 1 - vsmf matrix factorization,
%       2 - naive column averages to complete the matrix, 3 - regularized
%       wnmfrule (weightedNMFFrobeniusNorm)
%   fold = which fold the cross validation is on (1 to numberOfFolds)
%   numberOfFolds = number of folds the cross validation will have (so we
%       know which subset of the data to mask)
%   alpha = regularization parameter for weightedNMFFrobeniusNorm
%   beta = regularization parameter for weightedNMFFrobeniusNorm

%   completedMatrix = matrix, approximation of the original matrix, product of the
%       two factors A,Y
%   testError = float, RMSE on test set
%   overallError = float, RMSE on all previously known entries of matrix
%   lowResidual = float, lowest residual error after completing the matrix
%       the specified number of times
%   matrix = matrix, original matrix with test set masked
%   recommended keywords = 50x20 matrix with recommended keywords for first
%       50 users (gives niceKeywordID not actual keywordID)

data = csvread(file);
numberKeywords = max(data(:,3));
numberUsers = max(data(:,1));

%create the matrix to do matrix completion on (users = rows, keywords =
%columns, entries are the number of times the user searched the keyword)
if(useZeros)
    matrix = zeros(numberUsers, numberKeywords);
else
    matrix = nan(numberUsers, numberKeywords);
end
for row = 1:length(data(:, 1))
    mrow = data(row, 1);
    mcol = data(row, 3);
    binaryEntry = data(row, 6);
    frequencyEntry = data(row,5);
    if(entryType == 1)
        matrix(mrow,mcol) = binaryEntry;
    elseif(entryType == 2)
        matrix(mrow, mcol) = frequencyEntry;
    elseif(entryType == 3)
        matrix(mrow, mcol) = log10(frequencyEntry+1)+1;
    end
end

%normalize entries in the matrix - divide each entry in a row by the row sum
rowSums = ones(1,length(matrix(:,1)));
if(normalize)
    for row = 1:length(matrix(:,1))
        rowSums(row) = nansum(matrix(row,:));
        matrix(row,:) = matrix(row,:)/rowSums(row);
    end
end

%take out the test set
testResults = nan(numberUsers, numberKeywords);
numberEntries = length(data(:,1));
foldLength = numberEntries/numberOfFolds;
startPoint = int16(foldLength*(fold-1))+1;
endPoint = int16(foldLength*fold);
for entry = startPoint:endPoint
    mrow = data(entry, 1);
    mcol = data(entry, 3);
    mFrequencyEntry = data(entry, 5);
    mBinaryEntry = data(entry, 6);
    %put entry in test set
    if(entryType == 1) %binary
        testResults(mrow,mcol) = mBinaryEntry;
    elseif(entryType == 2) %frequency
        testResults(mrow, mcol) = mFrequencyEntry;
    elseif(entryType == 3)
        testResults(mrow, mcol) = log10(mFrequencyEntry+1)+1;
    end
    if(useZeros) %reset entry in matrix to be 0 or NaN
        matrix(mrow,mcol) = 0;
    else
        matrix(mrow, mcol) = NaN;
    end
end

%normalize matrix again (now the training set)
if(normalize)
    for row = 1:length(matrix(:,1))
        rowSums(row) = nansum(matrix(row,:));
        matrix(row,:) = matrix(row,:)/rowSums(row);
    end
end

%do matrix completion
options = struct();
if(method == 0)
    options.dis = false;
    options.distance='ls';
    options.iter=numIterationsForCompletion;
    options.residual=1e-4;
    options.tof=1e-4;
elseif(method == 1)
    options.alpha2=0;
    options.alpha1=.1;
    options.lambda2=0;
    options.lambda1=.1;
    options.t1=true;
    options.t2=true;
    options.kernel='linear';
    options.kernelizeAY=0;
    options.param=[];
    options.iter=numIterationsForCompletion;
    options.dis=true;
    options.residual=1e-4;
    options.tof=1e-4;
elseif(method == 3)
    options.dis = false;
    options.distance='ls';
    options.iter=numIterationsForCompletion;
    options.residual=1e-4;
    options.tof=1e-4;
end

bestA = 1;
bestX = 1;
lowResidual = 1000;
finalResidual = 1000;
for iter = 1:numTimesToDoCompletion
    %calculate for general matrix
    if(method == 0)
        [A,X,numIter,tElapsed,finalResidual] = wnmfrule(sparse(matrix), k, options);
    elseif(method == 1)
        [A,X,AtA,numIter,tElapsed,finalResidual] = vsmf(sparse(matrix), k, options);
    elseif(method == 3)
        [A,X,numIter,tElapsed,finalResidual] = weightedNMFFrobeniusNorm(sparse(matrix), k, alpha, beta, options);
    end
    if(finalResidual < lowResidual)
        lowResidual = finalResidual;
        bestA = A;
        bestX = X;
    end
end

if(method == 2)
    completedMatrix = naiveAverage(matrix, false);
elseif(method == 1 || method == 0 || method == 3)
    completedMatrix = bestA*bestX;
end


%now see how much the prediction matrix differs from the testResults matrix
% on the masked entries (calculate rooted mean squared error)
maskMatrix = ~isnan(testResults);
zeroTestResults = testResults;
zeroTestResults(~maskMatrix) = 0; %turn NaN entries to 0
numTestResults = sum(sum(maskMatrix));
testError = sqrt(norm((zeroTestResults-completedMatrix).*maskMatrix, 'fro')/numTestResults);

maskMatrix2 = ~isnan(matrix);
zeroMatrix = matrix;
zeroMatrix(~maskMatrix2) = 0; %turn NaN entries to 0
numEntries = length(zeroMatrix(:,1))*length(zeroMatrix(1,:));
overallError = sqrt(norm((zeroTestResults+zeroMatrix-completedMatrix).*(maskMatrix+maskMatrix2), 'fro')/numEntries);


%get the top 20 recommended keywords for the first 50 users
recommendedKeywords = zeros(50,20);
for user = 1:50
    userKeywordVector = [1:length(completedMatrix(1,:)); completedMatrix(user, :)];
    userKeywordVector = sortrows(userKeywordVector',-2)'; %sort in descending order
    for i = 1:20
        recommendedKeywords(user,i) = userKeywordVector(1, i);
    end
end
end

