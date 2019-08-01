function A=keymatrix(a,b,c,type)
% we want to build a matrix to turn list into a matrx
% type 1 is a binary matrix and type 2 is a frequency matrix
a1=unique(a);
b1=unique(b);
m=max(a1)-min(a1)+1;
n=max(b1)-min(b1)+1;
A=zeros(m,n);
l=length(a);
for i=1:l
    if type==1
    A(a(i),b(i))=1;
    else A(a(i),b(i))=c(i);
    end
end

    
