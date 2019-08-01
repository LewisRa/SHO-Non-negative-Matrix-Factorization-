function A=tkmatrix(t)
% we want to build a matrix to of testimony id and keyword id 



a=t(:,1);
b=t(:,2);
l=length(a);
m=max(a);
n=max(b);
A=zeros(m,n);
for i=1:l
    A(a(i),b(i))=A(a(i),b(i))+1;
end
