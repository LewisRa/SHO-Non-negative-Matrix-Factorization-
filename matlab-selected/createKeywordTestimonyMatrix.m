function [ keywordTestimonyMatrix ] = createKeywordTestimonyMatrix( file1, file2, file3, entryType, normalize )
%CREATE KEYWORD TESTIMONY MATRIX Uses the three keyword-testimony files to
%create a sparse matrix where the rows are keywords (or keyword types) and the
%columns are testimonies.
% file1, file2, file3 = file3 with niceIntCode, IntCode, niceKeywordID,
%   KeywordID, and weight (3 files because there are ~2,500,000 entries in
%   the keywordType-testimony table and Excel can only have somewhere
%   around 1,000,000 rows, so the first two tables have 1 million rows and
%   the third table has the rest of the data)
% entryType = 1: binary, 2: frequency (uses weight as entry)

data1 = csvread(file1,0); 
data2 = csvread(file2,0); 
data3 = csvread(file3,0);
disp('making the matrix now')
if(entryType == 1)
    keywordTestimonyMatrix = sparse([data1(:,3); data2(:,3); data3(:,3)], [data1(:,1); data2(:,1); data3(:,1)], 1);
elseif(entryType == 2)
    keywordTestimonyMatrix = sparse([data1(:,3); data2(:,3); data3(:,3)], [data1(:,1); data2(:,1); data3(:,1)],...
        [data1(:,5); data2(:,5); data3(:,5)]);
end
disp('matrix made')

%normalize entries in the matrix - divide each entry in a row by the row sum
if(normalize)
    numrows = length(keywordTestimonyMatrix(:,1));
    keywordTestimonyMatrix = spdiags (sum (keywordTestimonyMatrix,2), 0, numrows, numrows)*keywordTestimonyMatrix;
end
disp('normalized')

end

