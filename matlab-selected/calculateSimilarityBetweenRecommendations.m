function [ similarity ] = calculateSimilarityBetweenRecommendations( recommendations1, recommendations2 )
%calculateSimilarityBetweenRecommendations Calculates the similarity between two sets of recommendations
%   (for each user, counts the number of keyword recommendations that are
%    the same and adds up all these and divides by numKeywords*numUsers)
% recommendations1 = matrix where rows are users, columns are recommended
%   keywords in order of recommendation (best fit = index 1, so on)
% recommendations2 = another matrix where rows are users, columns are recommended
%   keywords in order of recommendation (best fit = index 1, so on) (same
%   dimension as recommendations1, same users too)

numUsers = length(recommendations1(:,1));
numRecommendations = length(recommendations1(1,:));

similarity = 0;
for user = 1:numUsers
    %get the number of keywords that are recommended in both
    for index = 1:numRecommendations
        rec1Keyword = recommendations1(user, index);
        if(any(recommendations2(user,:) == rec1Keyword))
            similarity = similarity + 1;
        end
    end
end
similarity = similarity/(numUsers*numRecommendations);
end

