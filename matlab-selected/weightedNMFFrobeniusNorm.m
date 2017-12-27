function [ A,Y,numIter,tElapsed,finalResidual ] = weightedNMFFrobeniusNorm( X,k,alpha, beta, option )
%weighted non-negative matrix factorization (for dealing with incomplete
%matrices):   X=AY such that A>=0, Y>=0
%   minimize:    ||(X-AY)_\Omega||_F^2 + \alpha||A||_F^2 + \beta||Y||_F^2
%       where F is the frobenius norm and M_\Omega sets the unknown entries
%       to 0
%  
%   X: incomplete (or complete) matrix to factor. incomplete entries are denoted with NaN
%   k: number of topics/latent dimension that matrices will be factored
%       into (X = n \times m matrix, A = n \times k matrix, Y = k \times m
%       matrix)
%   alpha: parameter for ||A||_F^2 term
%   beta: parameter for ||Y||_F^2 term
%   option: struct:
%       option.distance: distance used in the objective function. It could be
%           'ls': the Euclidean distance (defalut),
%           'kl': KL divergence.
%       option.iter: max number of interations. The default is 1000.
%       option.dis: boolen scalar, It could be 
%           false: not display information,
%           true: display (default).
%       option.residual: the threshold of the fitting residual to terminate. 
%            If the ||X-XfitThis||<=option.residual, then halt. The default is 1e-4.
%       option.tof: if ||XfitPrevious-XfitThis||<=option.tof, then halt. The default is 1e-4.
%   A: matrix, the basis matrix.
%   Y: matrix, the coefficient matrix.
%   numIter: scalar, the number of iterations.
%   tElapsed: scalar, the computing time used.
%   finalResidual: scalar, the fitting residual.
%
% much of this code is copied from wnmfrule (Yifeng Li and Alioune Ngom, 2013). the altered update rules are
% from the paper "non-negative matrix factorization for spectral data
% analysis" by Pauca, Piper, and Plemmons (2006).

tStart=tic;
optionDefault.distance='ls';
optionDefault.iter=1000;
optionDefault.dis=true;
optionDefault.residual=1e-4;
optionDefault.tof=1e-4;
if nargin<3
   option=optionDefault;
else
    option=mergeOption(option,optionDefault); %a function from the package with wnmfrule
end

%create the mask matrix W
W=isnan(X);
X(W)=0;
W=~W;

% iter: number of iterations
[r,c]=size(X); % c is # of samples, r is # of features
Y=rand(k,c); %create random y
Y=max(Y,eps); %make sure that y is non-negative
A=X/Y; %get A from Y
A=max(A,eps); %make sure that A is non-negative
XfitPrevious=Inf;
for i=1:option.iter
    A=A.*(((W.*X)*Y'-alpha*A)./((W.*(A*Y))*Y'+eps)); %W is the mask matrix, X is the user-item matrix, Y' means Y transpose
        A=max(A,eps); %make entries in A positive
    Y=Y.*((A'*(W.*X)-beta*Y)./(A'*(W.*(A*Y))+eps));
        Y=max(Y,eps);
    %scale columns of A to add up to 1
    for col = 1:length(A(1,:))
        A(:,col) = A(:,col)/sum(A(:,col));
    end
    if mod(i,10)==0 || i==option.iter
        if option.dis
            disp(['Iterating >>>>>> ', num2str(i),'th']);
        end
        XfitThis=A*Y;
        fitRes=matrixNorm(W.*(XfitPrevious-XfitThis));
        XfitPrevious=XfitThis;
        curRes=norm(W.*(X-XfitThis),'fro');
        if option.tof>=fitRes || option.residual>=curRes || i==option.iter
            s=sprintf('regularized nmf success! \n # of iterations is %0.0d. \n The final residual is %0.4d.',i,curRes);
            disp(s);
            numIter=i;
            finalResidual=curRes;
            break;
        end
    end
end
tElapsed=toc(tStart);
end

