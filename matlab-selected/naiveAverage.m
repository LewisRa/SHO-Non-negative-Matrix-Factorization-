function [completeMatrix] = naiveAverage(matrix, rows)
%NAIVE AVERAGE completes the user-keyword matrix by filling in the unknown
%entries with the row or column average (depending on the parameter "rows"
%   matrix: incomplete matrix where unnknown entries have NaN
%   rows: true if entries are filled in by row average, false if entry is
%       filled in by column average
%   completeMatrix: matrix, the completed input matrix
completeMatrix = matrix;
if(rows)
    for row = 1:length(completeMatrix(:,1))
        avg = nanmean(completeMatrix(row,:));
        if(isnan(avg))
            avg = 0;
        end
        for col = 1:length(completeMatrix(row,:))
            if(isnan(completeMatrix(row,col)))
                completeMatrix(row,col) = avg;
            end
        end
    end
else
    for col = 1:length(completeMatrix(1,:))
        avg = nanmean(completeMatrix(:,col));
        if(isnan(avg))
            avg = 0;
        end
        for row = 1:length(completeMatrix(:,col))
            if(isnan(completeMatrix(row,col)))
                completeMatrix(row,col) = avg;
            end
        end
    end
end
end