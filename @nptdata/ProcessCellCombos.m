function [robj,data] = ProcessCellCombos(obj,varargin)
%NPTDATA/ProcessCellCombos	Process data from combinations of clusters.
%   ROBJ = ProcessSession(OBJ) checks the local directory (assumed to be
%   the session directory) for group directories and loops over them to
%   find cluster directories. Combinations of these cluster directories
%   are created in which other objects may be saved. The 'AnalysisLevel'
%   property of OBJ is used to determine which combinations are created.
%
%   ProcessSession(OBJ,VARARGIN) takes the following optional 
%   arguments:
%      'IntraGroup'     Flag that specifies only intra-group combinations
%                       should be created.
%      'InterGroup'     Flag that specifies only inter-group combinations
%                       should be created.
%      'AnalysisLevel'  Over-rides the AnalysisLevel property of OBJ.
%                       Accepted values are:
%                          'Pairs'           Pairs of clusters.
%                          'AllIntragroup'   Groups of intra-group clusters.
%                          'AllPairs'        Groups of intra-group pairs.

Args = struct('IntraGroup','','InterGroup','','AnalysisLevel','', ...
    'GroupDirName','group*','nptComboCmd','','DataInit',[], ...
    'DataPlusCmd','');
Args.flags = {'IntraGroup','InterGroup'};
[Args,varargin2] = getOptArgs(varargin,Args);

% constants
nameComboDir = getDataDirs('ComboPrefix');
nameAllDir = 'all';

% if IntraGroup or InterGroup was specified, set the other to 0
if(Args.IntraGroup==1)
    Args.InterGroup = 0;
elseif(Args.InterGroup==1)
    Args.IntraGroup = 0;
else
    % neither IntraGroup or InterGroup was specified so run both by seting 
    % both IntraGroup and InterGroup to 1
    Args.IntraGroup = 1;
    Args.InterGroup = 1;
end

% if AnalysisLevel not specified, check the object
if(isempty(Args.AnalysisLevel))
	% check the object's AnalysisLevel
	Args.AnalysisLevel = get(obj,'AnalysisLevel');
end

robj = obj;
data = Args.DataInit;

% check analysis level
if(strcmpi(Args.AnalysisLevel,'All'))
	% 
	% analyze any number of cells so long as it is greater than 1
	%
	% get list of cluster directories
	% !!! this will cause infinite loop if AnalysisLevel is not single !!!
	nd = ProcessSession(nptdata,varargin2{:});
	clusterlist = get(nd,'SessionDirs');
	if(~isempty(clusterlist))
		% call nptMkDir to create combinations directory if it is not already present
		nptMkDir(nameComboDir);
		% change to combinations directory
		cd(nameComboDir);
		% call nptMkDir to create 'all' directory it if is not already present
		nptMkDir(nameAllDir);
		% change to 'all' directory
		cd(nameAllDir);
        % check if we should skip this directory
        if (~checkMarkers(obj,0,'combo'))
            if(isempty(Args.nptComboCmd))
                % instantiate object
            	p = feval(class(obj),'auto','ClusterDirs',clusterlist);
            	robj = plus(robj,p,varargin2{:});
            else
                % execute nptComboCmd
                eval(Args.nptComboCmd);
            end
        end
		% return to parent directory of nameComboDir
		cd ..
	end % if(~isempty(clusterlist))
else % if(strcmpi(Args.AnalysisLevel,'All'))
	% get list of groups
	glist = nptDir(Args.GroupDirName);
	% get number of groups
	gnum = size(glist,1);
	% initialize clusternum variable so we can tell if no clusters were
	% found, for instance when using the Cells optional input argument
	clusternum = [];
    fprintf('Gathering cluster directories...\n');
	for i = 1:gnum
		% get cluster directories for each group
        fprintf('\t\t\tProcessing Group %s\n',glist(i).name);
		cd(glist(i).name);
		% use ProcessGroup so we can specify CellDirName to select single units
		% or multi-units and also skip directories with skip.txt
		nd = ProcessGroup(nptdata,varargin2{:});
		clusterlist{i} = get(nd,'SessionDirs');
		clusternum(i) = get(nd,'Number');
		cd ..
	end
	% only continue if the clusterlist is not empty
	if(~isempty(clusternum))
		% call nptMkDir to create directory if it is not already present
		nptMkDir(nameComboDir);
		% change to combinations directory
		cd(nameComboDir);
		% save the current directory so that the allpairs option can grab
		% the correct absolute path
		allpairsComboDir = pwd;
		
		if(strcmpi(Args.AnalysisLevel,'Pairs') || strcmpi(Args.AnalysisLevel,'AllPairs'))
			%
			% Analysis of Cell Pairs
			%
			% check if IntraGroup was specified or if neither was specified, which
			% means that we are going to use all intra- and inter-group combinations
			if(Args.IntraGroup || isempty(Args.IntraGroup))
				% loop through intra-group combinations
				for group1 = 1:gnum
					% initialize allpairslist variable
					% do this inside the loop over groups so that we only
					% group together pairs from the same group
					allpairslist = {};
					% get name of group
					group1name = glist(group1).name;
					% get length of group1name
					group1namelength = length(group1name);
					% get abbreviated number
					group1number = str2num(group1name((group1namelength-3):group1namelength));
					% get number of clusters in this group
					nclusters = clusternum(group1);
					for cluster1 = 1:nclusters
						% get name of first cluster
						c1 = clusterlist{group1}{cluster1};
						% get length of c1
						c1length = length(c1);
						% get abbreviated number
						c1number = str2num(c1((c1length-2):(c1length-1)));
						% get portion of comboDirName
						c1comboName = ['g' num2str(group1number) 'c' num2str(c1number) c1(c1length)];
						for cluster2 = (cluster1+1):nclusters
							% get name of second cluster
							c2 = clusterlist{group1}{cluster2};
							% get length of c2
							c2length = length(c2);
							% get abbreviated number
							c2number = str2num(c2((c2length-2):(c2length-1)));
							% get directory name for this pair
							comboDirName = [c1comboName 'g' num2str(group1number) 'c' num2str(c2number) c2(c2length)];
							fprintf('\t\t\tProcessing cell pair %s\n',comboDirName);
							% call nptMkDir to create directory if it is not already
							% present
							nptMkDir(comboDirName);
							cd(comboDirName);
                            % check if we should skip this directory
                            if (~checkMarkers(obj,0,'combo'))
                            	if(strcmpi(Args.AnalysisLevel,'AllPairs'))
                            		% add this combo directory to the list
                            		% do this after checkMarkers so that we 
                            		% honor skip.txt if it is present
                            		% inside a pair directory
                            		allpairslist = {allpairslist{:} [allpairsComboDir filesep comboDirName]};
                            	else
									if(isempty(Args.nptComboCmd))
										% instantiate object inside the combo directory
										p = feval(class(obj),'auto','ClusterDirs',{clusterlist{group1}{cluster1}, ...
											clusterlist{group1}{cluster2}},varargin2{:});
										robj = plus(robj,p,varargin2{:});
										if(~isempty(Args.DataPlusCmd))
											eval(Args.DataPlusCmd);
										end
									else
										% execute nptComboCmd
										eval(Args.nptComboCmd);
									end
								end
                            end
							cd ..
						end % for cluster2 = (cluster1+1):nclusters
					end % end for cluster1 = 1:nclusters
					if(strcmpi(Args.AnalysisLevel,'AllPairs'))
						% don't create directory yet since it is not clear
						% what form it should take. We won't really need
						% the directory anyway for now since we are just
						% using this option for display purposes
						% create directory representing the group of pairs
						% allpairsDirName = 
						% nptMkDir(allpairsDirName);
						% cd(allpairsDirName);
						% check if we should skip this directory
						% if (~checkMarkers(obj,0,'combo'))
							if(isempty(Args.nptComboCmd))
								% instantiate object inside the loop over 
								% group so pairs are separated according
								% to their groups
								p = feval(class(obj),'auto','ClusterDirs',allpairslist,varargin2{:});
								robj = plus(robj,p,varargin2{:});
								if(~isempty(Args.DataPlusCmd))
									eval(Args.DataPlusCmd);
								end
							else
								% execute nptComboCmd
								eval(Args.nptComboCmd);
							end
						% end
						% cd ..
					end
				end % for group1 = 1:gnum
			end % if(Args.IntraGroup | isempty(Args.IntraGroup))
			
			if(Args.InterGroup | isempty(Args.InterGroup))
				% loop through inter-group combinations
				for group1 = 1:gnum
					% get name of group1
					group1name = glist(group1).name;
					% get length of groupname
					group1namelength = length(group1name);
					% get abbreviated number
					group1number = str2num(group1name((group1namelength-3):group1namelength));
					% get number of clusters in this group
					n1clusters = clusternum(group1);
					for cluster1 = 1:n1clusters
						% get name of first cluster
						c1 = clusterlist{group1}{cluster1};
						% get length of c1
						c1length = length(c1);
						% get abbreviated number
						c1number = str2num(c1((c1length-2):(c1length-1)));
						% get portion of comboDirName
						c1comboName = ['g' num2str(group1number) 'c' num2str(c1number) c1(c1length)];
						for group2 = (group1+1):gnum
							% get name of group
							group2name = glist(group2).name;
							% get length of groupname
							group2namelength = length(group2name);
							% get abbreviated number
							group2number = str2num(group2name((group2namelength-3):group2namelength));
							% get number of clusters in this group
							n2clusters = clusternum(group2);
							for cluster2 = 1:n2clusters	
								% get name of second cluster
								c2 = clusterlist{group2}{cluster2};
								% get length of c2
								c2length = length(c2);
								% get abbreviated number
								c2number = str2num(c2((c2length-2):(c2length-1)));
								% get directory name for this pair
								comboDirName = [c1comboName 'g' num2str(group2number) 'c' num2str(c2number) c2(c2length)];
								fprintf('\t\t\tProcessing cell pair %s\n',comboDirName);
								% call nptMkDir to create directory if it is not already
								% present
								nptMkDir(comboDirName);
								cd(comboDirName);
                                % check if we should skip this directory
                                if (~checkMarkers(obj,0,'combo'))
                                    if(isempty(Args.nptComboCmd))
										% instantiate object inside the combo directory
										p = feval(class(obj),'auto','ClusterDirs',{clusterlist{group1}{cluster1}, ...
											clusterlist{group2}{cluster2}},varargin2{:});
										robj = plus(robj,p,varargin2{:});
										if(~isempty(Args.DataPlusCmd))
											eval(Args.DataPlusCmd);
										end
                                    else
                                        % execute nptComboCmd
                                        eval(Args.nptComboCmd);
                                    end
                                end
								cd ..
							end % for cluster2 = 1:n2clusters
						end % for group2 = (group1+1):gnum
					end % for cluster1 = 1:n1clusters
				end % for group1 = 1:gnum
			end % if(Args.InterGroup | isempty(Args.InterGroup))
		elseif(strcmpi(Args.AnalysisLevel,'AllIntragroup')) % if(strcmpi(Args.AnalysisLevel,'Pairs'))
			%
			% Analysis of all intragroup clusters
			%
			% loop through intra-group combinations
			for group1 = 1:gnum
				% get number of clusters in this group
				nclusters = clusternum(group1);
				% only continue if there is more than 1 cluster
				if(nclusters>1)
					% get name of group
					group1name = glist(group1).name;
					% get length of group1name
					group1namelength = length(group1name);
					% get abbreviated number
					group1number = str2num(group1name((group1namelength-3):group1namelength));
					% get directory name for this group
					comboDirName = [nameAllDir 'g' num2str(group1number)];
					% call nptMkDir to create directory if it is not already
					% present
					nptMkDir(comboDirName);
					cd(comboDirName);
                    % check if we should skip this directory
                    if (~checkMarkers(obj,0,'combo'))
                        if(isempty(Args.nptComboCmd))
							% instantiate object inside the combo directory
							p = feval(class(obj),'auto','ClusterDirs',{clusterlist{group1}{:}},varargin2{:});
							robj = plus(robj,p,varargin2{:});
							if(~isempty(Args.DataPlusCmd))
								eval(Args.DataPlusCmd);
							end
                        else
                            % execute nptComboCmd
                            eval(Args.nptComboCmd);
                        end
                    end
					cd ..
				end
			end
		end % if(strcmpi(Args.AnalysisLevel,'Pairs'))
	
		% return to parent directory of nameComboDir
		cd ..
    end % if(~isempty(clusternum)) 
end % if(strcmpi(Args.AnalysisLevel,'All'))
