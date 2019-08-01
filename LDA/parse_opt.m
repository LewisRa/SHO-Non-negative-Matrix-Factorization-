function [varargout] = parse_opt(args, varargin)


ni = length(varargin);

% these are just about the only things that we'll check for
if nargout*2 ~= ni
    error('parse_opt requires a name-value input pair for each output');
end
if mod(ni,2) ~= 0
     error('parse_opt requires name-value input pairs');
end

no = ni/2;
varargout = cell(1,no);
for i = 1:2:ni
    ndx = find(strcmpi(varargin{i}, args));
    if isempty(ndx)
        varargout{(i+1)/2} = varargin{i+1};
    else
        varargout{(i+1)/2} = args{ndx+1};
    end
end