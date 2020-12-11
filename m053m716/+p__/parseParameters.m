function pars = parseParameters(defFile,varargin)
%PARSEPARAMETERS  Parse input default parameters of `defFile`
%
%  pars = p__.parseParameters(defFile);
%  --> Uses file in `+p__/+defs/<defFile>.m` to get parameters struct
%
%  pars = p__.parseParameters(defFile,pars);
%  --> Assigns pars directly
%  --> Does not get rid of "extra" fields of `pars`
%
%  pars = p__.parseParameters(defFile,varargin{:});
%  --> Uses file in `+p__/+defs/<defFile>.m` to get parameters struct
%     --> Modifies parameter struct using `'NAME',value,...` syntax
%     --> Does a case-insensitive match, ignoring fields that are not in
%         the parameters struct from `defFile`
%
%  pars = p__.parseParameters(defFile,pars,varargin{:});
%  --> Assigns pars directly
%  --> Does not get rid of "extra" fields of `pars`

pars = p__.defs.(defFile)();
switch numel(varargin)
   case 0 % Do nothing
      return;
   case 1 % (Case-insensitive) match fields of struct; keep "extra" fields
      if ~isstruct(varargin{1})
         error(['P__:' mfilename ':BadSyntax'],...
            ['\n\t->\t<strong>[P__.PARSEPARAMETERS]:</strong> ' ...
            'If only 2 arguments given, second must be parameters ' ...
            '<strong>struct</strong>\n']);
      end
      args = p__.struct2args(varargin{1});
      pars = p__.getOpt(pars,5,args{:});
   otherwise % Otherwise, do a case-insensitive match, ignoring mismatches
      if isstruct(varargin{1})
         args = p__.struct2args(varargin{1});
         pars = p__.getOpt(pars,5,args{:});
         varargin(1) = [];
      end
      pars = p__.getOpt(pars,3,varargin{:});
end

end