function list = findFile(root,varargin)
% findFile finds recursively all files in root. 
% 
% <a href="matlab: docsearchFS('findFile')">Link to the help function</a>
%
%
% Required input arguments:
%
%   root:       Root directory. String. Case sensitive string that can indicate
%               relative or absolute path. Use '.' for current directory.
%               Data Types - string
%           
%
% Optional input arguments:
%
%   InclDir:    Include directory pattern(s). String or cell arrays of
%               strings. User can use wildcards. Do not use regular expression,
%               for examples 'abc' and 'ab*de*'. File separator (i.e. '\' in 
%               Windows or '/' in Unix) is not allowed. Case-sensitive.
%               This filter is skipped if InclDir='', InclDir={},
%               InclDir='*' or if one of the element of the cell array
%               InclDir is '*'. Default: InclDir={''}.
%               Example - 'InclDir','dirname'
%               Data Types - (cell array of) string
%   ExclDir:    Exclude directory pattern(s). String or cell arrays of
%               strings. User can use wildcards. Do not
%               use regular expression. Examples: 'abc' and 'ab*de*'. Use ''
%               or {} to skip this stage. File separator (i.e. '\' in 
%               Windows or '/' in Unix) is not allowed. Case-sensitive. Default: ExclDir={''}.
%               Example - 'ExclDir','dirname'
%               Data Types - (cell array of) string
%   InclFiles:  Include file pattern(s). String or cell arrays of
%               strings. User can use wildcards. Do not use regular expression.
%               Use '*' to include all files. Note that '*' and '*.*' give 
%               the same behaviour and return all files. File separator 
%               (i.e. '\' in Windows or '/' in Unix) is not allowed.
%               Case-sensitive. Default: InclFile={'*'}.
%               Example - 'InclFiles','filename'
%               Data Types - (cell array of) string
%   ExclFiles:  Exclude file pattern(s). String or cell arrays of
%               strings. User can use wildcards. Do not use regular expression.
%               Use '' or {} to skip this check. File separator (i.e. '\' 
%               in Windows or '/' in Unix) is not allowed.
%               Case-sensitive. Default: ExclFiles={''}.
%               Example - 'ExclFiles','filename'
%               Data Types - (cell array of) string
%
% Output:
%
%   list:       All files. Cell array of strings. List of all 
%               files matched under root directory, sorted in alphabetical
%               and ascending order. Always return absolute path. 
%
%
% See also: findDir
%
% References:
%
% Copyright 2008-2015.
% Written by FSDA team
%
%
%<a href="matlab: docsearchFS('findFile')">Link to the help page for this function</a>
% Last modified 06-Feb-2015
%
% Examples:
%
%{
    %% findFile with all default options.
    FullPath=which('findFile');
    root=FullPath(1:end-length('findFile.m')-1);
    list = findFile(root)
%}   
%
%{
    % findFile with otpional arguments.
    FullPath=which('findFile');
    root=FullPath(1:end-length('findFile.m')-1);
    list = findFile(root,'InclDir','graphics')
%}   


% Assign input arguments.
options=struct('InclDir',{''},'ExclDir',{''},'InclFiles',{'*'},'ExclFiles',{''});

UserOptions=varargin(1:2:length(varargin));
if ~isempty(UserOptions)
    % Check if number of supplied options is valid
    if length(varargin) ~= 2*length(UserOptions)
        error('FSDA:FSR:WrongInputOpt','Number of supplied options is invalid. Probably values for some parameters are missing.');
    end
    % Check if user options are valid options
    chkoptions(options,UserOptions)
end

% Write in structure 'options' the options chosen by the user
if nargin > 2
    for i=1:2:length(varargin);
        options.(varargin{i})=varargin{i+1};
    end
end

InclDir=options.InclDir;
ExclDir=options.ExclDir;
InclFiles=options.InclFiles;
ExclFiles=options.ExclFiles;

% Check root.
if ~ischar(root)
    error('root is not a string.');
end

% Force InclFiles and ExclFiles to be a cell array of string.
if isempty(InclFiles)
    InclFiles = {};
else
    if ~iscell(InclFiles)
        InclFiles = {InclFiles};
    end
end
if isempty(ExclFiles)
    ExclFiles = {};
else
    if ~iscell(ExclFiles)
        ExclFiles = {ExclFiles};
    end
end

% Make sure that InclFiles and ExclFiles do not contain file separator.
c = strfind(InclFiles, filesep);
c = [c{:}];
if ~isempty(c)
    error('One of the InclFiles file patterns contains file separator.');
end
c = strfind(ExclFiles, filesep);
c = [c{:}];
if ~isempty(c)
    error('One of the ExclFiles patterns contains file separator.');
end


% Get all suddirectories under rootdir. Contain absolute paths.
alldirs = findDir(root,'InclDir',InclDir,'ExclDir',ExclDir);


% Find all files that match.
list = {};
for m = 1:length(alldirs)
    for n = 1:length(InclFiles)
        filelist = dir(fullfile(alldirs{m}, InclFiles{n}));
        filelist = filelist(~[filelist.isdir]);
        for k = 1:length(filelist)
            list{end+1} = fullfile(alldirs{m}, filelist(k).name);
        end
    end
end
            
% Remove files from match according to excludefile.
if ~isempty(ExclFiles)
    midx = [];
    for n = 1:length(list)
        [~, name, ext] = fileparts(list{n});
        filename = [name, ext];
        c = regexp(filename, regexptranslate('wildcard', ExclFiles), 'match');
        c = [c{:}];
        if any(strcmp(filename, c))
            midx = [midx, n];
        end
    end
    list(midx) = [];
end

% Sort files.
list = sort(list);