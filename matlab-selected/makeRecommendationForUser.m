function [userTestimonyVector, topNTestimonies] = makeRecommendationForUser(userKeywordMatrixFile, userKeywordFile, ...
    keywordTestimonyMatrix, keywordTestimonyFile1, keywordTestimonyFile2, keywordTestimonyFile3, user, n)
%Recommends testimonies (IntCode) for the user to watch given a completed
%user-keyword matrix and keyword-testimony matrix (or user-type and
%type-testimony matrices).
%   -userKeywordMatrix = completed matrix with users on the rows, keywords on
%       the columns
%   -userKeywordFile = file of niceUserID, UserID, niceKeywordID, KeywordID so
%       we have a map between IDs
%   -keywordTestimonyMatrix = matrix with keywords on the rows, testimonies on
%       the columns
%   -keywordTestimonyFile1,2,3 = file of niceIntCode, IntCode, niceKeywordID,
%       KeywordID so we have a map between IDs
%   -user = the user we want to make recommendations for (as UserID)
%   -n = how many testimonies to recommend
disp('reading in data')
userKeywordMatrix = csvread(userKeywordMatrixFile);

userKeywordData = csvread(userKeywordFile);
keywordTestimonyData = [csvread(keywordTestimonyFile1,0); csvread(keywordTestimonyFile2,0); csvread(keywordTestimonyFile3,0)];

disp('finding index of user')
indexOfUser = userKeywordData(find(userKeywordData(:,2) == user, 1),1); %convert from UserID to niceUserID

disp('creating user testimony vector')
%create a vector that represents the user's interest in each testimony
userTestimonyVector = [1:length(keywordTestimonyMatrix(1,:)); userKeywordMatrix(indexOfUser, :)*keywordTestimonyMatrix];

disp('sorting user testimony vector')
%create matrix where first row is niceIntCode and second row is the user's
%preferences for the testimonies
userTestimonyVector = sortrows(userTestimonyVector',-2)';

topNTestimonies = zeros(1,n);
for i = 1:n
    niceIntCode = userTestimonyVector(1, i);
    intCode = keywordTestimonyData(find(keywordTestimonyData(:,1) == niceIntCode, 1),2);
    topNTestimonies(i) = intCode;
end

end