function W = normalize_W(W, type)
% function W = normalize_W(W, type)
%
% Normalize columns of W using:
%  1 - use 1-norm [default]
%  2 - use 2-norm
%  k - multiply the 1-norm by k

if nargin < 2
    type = 1;
end

switch type
    case 1
        for j = 1:size(W,3)
            for i = 1:size(W,2)
                W(:,i,j) = W(:,i,j) ./ norm(W(:,i,j),1);
            end
        end
        
    case 2
        for j = 1:size(W,3)
            for i = 1:size(W,2)
                W(:,i,j) = W(:,i,j) ./ norm(W(:,i,j),2);
            end
        end
        
    case 0
        
    otherwise 
        for j = 1:size(W,3)
            for i = 1:size(W,2)
                W(:,i,j) = type*W(:,i,j) ./ norm(W(:,i,j),1);
            end
        end
end
        