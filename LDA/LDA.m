function s=topre(a,u,v,type,latentdimension,n)
% given an input a which is a user id, we output the top n recommendation
% using probabilistic topic modeling
% for him
% input: a:userid
%        u:n*3 list of userid and keyword searched by the user, first column should
%          be the user id, second column is keywordid, third column should
%          be number of searches
%        v: m*2 list of keywordid and testimonyid, first column should be the
%          keywordid
%        type: PLSA if type==1, LDA if type==2
%        latentdimension: number of topics 
%        n:number of recommendation to the user a
%output: s is a list consisting of top n recommendation

% Note: this function requires a large memory so it is better to try a
% small sample first
%Shoah Foundation 2017 RIPS Team 

%% first create a user-keyword matrix, storing it as UK
x=u(:,1);
b=u(:,2);
c=u(:,3);
UK=keymatrix(x,b,c,2);

%% then we create an occurence matrix for keyword-video
TK=tkmatrix(v);

%% perform PLSA or LDA
k=struct('alphaf',1,'alphaz',0.01);
if type==1
    [e,d,m]=PLCA(TK,latentdimension, 100);
    display('recommendation for user using PLSA is testimony id')

else [e,d,m]=PLCA(TK,latentdimension,100,k);
     display('recommendation for user using LDA is testimony id')
end
P=e*diag(m)*d;
R=UK*P;
usera=R(a,:);

%% make recommendation for the user
s=sorttopn(usera,n);

