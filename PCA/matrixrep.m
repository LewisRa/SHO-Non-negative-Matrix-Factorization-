% Turn the compact adjacency list into a m-by-n frequency matrix
% m = max(adj(:,1));
% n = max(adj(:,2));
function x = matrixrep(adj,m,n)
% m = max(adj(:,1));
% n = max(adj(:,2));
x = zeros(m,n);
for i = 1:size(adj,1)
    tid = adj(i,1);
    kid = adj(i,2);
    x(tid,kid) = 1;
   % x(tid,kid) = x(tid,kid)+ 1;
end
end
