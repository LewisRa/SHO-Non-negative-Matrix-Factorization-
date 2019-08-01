resultlsa=zeros(31750,10);
for i=1:31750
    resultlsa(i,:)=sorttopn(plsa(i,:),10);
end