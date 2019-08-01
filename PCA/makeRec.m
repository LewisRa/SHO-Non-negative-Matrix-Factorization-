% rate: t by m matrix, where t is the number of users and m the number of
% testimonies. Each entry is the user's predicted rating on the testimony 
% N: want to recommend top-N testimonies to the user
% rec: t by N matrix.
function rec = makeRec(rate,N)
t = size(rate,1);
m = size(rate,2);
rec = zeros(t,N);
for i = 1:t
    temp = [-rate(i,:)' (1:m)'];
    testrank = sortrows(temp,1);
    testrank = testrank(:,2)';
    rec(i,:) = testrank(1,1:N);
end
end