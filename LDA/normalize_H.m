function H = normalize_H(H, type)
% function H = normalize_H(H, type)
%
% Normalize rows of H using type which can be:
%  1   - use 1-norm [default]
%  2   - use 2-norm
%  k   - multiply the 1-norm by k
%  'a' - means make sum(H(:))=1


if nargin < 2
    type = 0;
end

switch type
    case 1
        for i = 1:size(H,1)
            H(i,:) = H(i,:) ./ norm(H(i,:),1);
        end
        
    case 2
        for i = 1:size(H,1)
            H(i,:) = H(i,:) ./ norm(H(i,:),2);
        end
        
    case 'a'
        H = H./sum(H(:));
        
    case 0
        
    otherwise 
        for i = 1:size(H,1)
            H(i,:) = type*H(i,:) ./ norm(H(i,:),1);
        end
end
        