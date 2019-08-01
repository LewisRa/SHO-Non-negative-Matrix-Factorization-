%switch indexes and values of list such that list(index(i,1),1) = i
function index = newIndex(list)
list = unique(list);
n = max(list);
index = zeros(n,1);
list = sortrows(list,1);
for i = 1: size(list,1)
    index(list(i,1)) = i;
end
end