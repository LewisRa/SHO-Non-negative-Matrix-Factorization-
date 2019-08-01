keyword=TK(:,1);
l=length(keyword);
h=zeros(1,l);
for i=1:l
    h(1,i)=f(keyword(i),key,b);
end
