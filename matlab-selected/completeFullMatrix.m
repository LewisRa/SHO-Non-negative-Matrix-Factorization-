function [ completedMatrix, lowResidual, matrix] = completeFullMatrix(file, rowOffset, columnOffset, k, normalize, numIterationsForCompletion, numTimesToDoCompletion, entryType, useZeros, method, inMatrixAlready)
%COMPLETE FULL MATRIX Build a user-keyword matrix with data in file and then completes
%it in order to make recommendations (similar to
%completeMatrixWithCrossValidation but uses all the data with no test set)
%   file = csv file with the data: column headers are niceUserID, UserID,
%     niceKeywordID, KeywordID, TimesSearched (the nice IDs start at one and
%     don't skip any numbers so they correspond directly to matrix indices)
%   k = number of latent features, inner dimension in matrix factorization
%   normalize = boolean value, true if you want user-keywords matrix to be
%     normalized, false otherwise. normalizes by dividing each entry by its
%     row sum.
%   numIterationForCompletion = input to wnmfrule, max number of iterations
%   numTimesToDoCompletion = number of times that matrix completion will be
%     done - result with lowest residual will be taken (since algorithm
%     converges to local optimum)\
%   entryType = 1: binary entries, 2: frequency entries, 3: log base 10 of
%       frequency entries
%   zeros = boolean, false if the unobserved values are NaN, true otherwise
%   method = 0 - wnmfrule matrix completion, 1 - vsmf matrix factorization,
%       2 - naive column averages to complete the matrix, 3 - regularized
%       wnmfrule (weightedNMFFrobeniusNorm)
%   inMatrixAlready = boolean, true if the csv file holds the data in
%       matrix form (rows = users, columns = testimonies, unknown entries = 0), 
%       false if the csv file holds the data in table form
%       (column headers are niceUserID, UserID, niceKeywordID, KeywordID, 
%       TimesSearched - nice IDs go from 1 to number of users/keywords)

%   completedMatrix = matrix, approximation of the given matrix using
%       matrix factorization
%   lowResidual = float, lowest residual from doing matrix completion
%       (lowest value of objective function)
%   matrix = matrix on which matrix completion/factorization is performed
data = csvread(file, rowOffset, columnOffset);

numberKeywords = max(data(:,3));
numberUsers = max(data(:,1));

%create the matrix to do matrix completion on (users = rows, keywords =
%columns, entries are the number of times the user searched the keyword)
if(~inMatrixAlready)
    if(useZeros)
        matrix = zeros(numberUsers, numberKeywords);
    else
        matrix = nan(numberUsers, numberKeywords);
    end
    for row = 1:length(data(:, 1))
        mrow = data(row, 1);
        mcol = data(row, 3);
        entry = data(row, 5);
        if(entryType == 1)
            matrix(mrow,mcol) = 1;
        elseif(entryType == 2)
            matrix(mrow, mcol) = entry;
        elseif(entryType == 3)
            matrix(mrow, mcol) = log10(entry)+1;
        end
    end
else %have a matrix with zeros and frequency entries
    matrix = data;
    for row = 1:length(matrix(:,1))
        for col = 1:length(matrix(row,:))
            if(matrix(row,col) == 0)
                if(~useZeros)
                    matrix(row,col) = NaN;
                end
            elseif(entryType == 1)
                matrix(row, col) = 1;
            elseif(entryType == 3)
                matrix(row,col) = log10(matrix(row,col))+1;
            end
        end
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
        [A,X,numIter,tElapsed,finalResidual] = weightedNMFFrobeniusNorm(sparse(matrix), k, options);
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