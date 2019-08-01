% Use pca to complete the user-testimony matrix
% UKlist: m-by-2 adjacency list, where the first column is the userID and the
% second column is the keywordID that the user has searched
% TKlist: n-by-2 adjacency list, where the first column is the testimonyID,
% and the second column is the keywordID in the testimony. 
% r: threshold of percentage explained; usually r = 0.90
% UTmat: u-by-t matrix normalized by rows, where rows are users and 
%        columns are testimonies. Each entry is the user's predicted  
%        rating on the testimony on a scale of 0 to 1. 
% N: top-N recommended videos
% UserID: recommend videos to this user
% TIDIntCode: t-by-2 matrix, where the first column is the testimonyID, and
% the second column is the corresponding IntCode
function RecIntCode = MCpca(UK,TK,r,N,UserID,TIDIntCode)
uid = UK(:,1);
uindex =newIndex(uid);
tid = TK(:,1);
tindex = newIndex(tid);
kid = TK(:,2);
kindex = newIndex(kid);
UKlist = cpctAdj(uindex,kindex,UK);
TKlist = cpctAdj(tindex,kindex,TK);
n = max([max(UKlist(:,2)) max(TKlist(:,2))]);
u = max(UKlist(:,1));
t = max(TKlist(:,1));
UKmat = matrixrep(UKlist,u,n);
TKmat = matrixrep(TKlist,t,n);
[coeff,score,~,~,explained,~] = pca(TKmat);
k = 1;
p = explained(k,1);
while p<r
    k = k+1;
    p = p+explained(k,1);
end
UTmat = UKmat*coeff(:,1:k)*(score(:,1:k)');
rowmin = max(-UTmat');
UTmat = normr(UTmat+repmat(rowmin',1,t));
recmat = makeRec(UTmat,N);
id = uindex(UserID,1);
RecTID = recmat(id,:);
RecIntCode = zeros(1,N);
for i = 1:N
    test = tid(RecTID(1,i),1);
    intcode = TIDIntCode(test,2);
    RecIntCode(1,i) = intcode;
end

end