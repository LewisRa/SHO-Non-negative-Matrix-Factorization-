function a=f(x,p,q)
% f is a match function
%p,q are the list we input, x is the number we want to match,it is in p
if sum(p==x)==0
    a=0;
else t=q((p==x)==1);
    a=t(1);
end

