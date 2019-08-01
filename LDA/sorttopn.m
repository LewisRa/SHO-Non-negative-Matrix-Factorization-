function x=sorttopn(A,n)
[sortedX,sortingIndices] = sort(A,'descend');
x=sortingIndices(1:n);