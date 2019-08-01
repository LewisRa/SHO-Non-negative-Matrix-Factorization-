function newAdj = cpctAdj(index1,index2,adj)
n = size(adj,1);
newAdj = zeros(n,2);
for i = 1:n
    uid = adj(i,1);
    tid = adj(i,2);
    newAdj(i,1) = index1(uid);
    %newAdj(i,2) = tid;
    newAdj(i,2) = index2(tid);
end
%newAdj = newAdj(newAdj(:,2)>0,:);
newAdj(any(newAdj==0,2),:) = [];
end