function obj = CreateDataObject(input)
if ischar(input)
    if ~isempty(findstr(input,'.dat'))
        % need to find out if we need to create a waveforms object or
        % an ispikes object
        [s,v] = listdlg('PromptString','Which object do you want to create?',...
            'SelectionMode','single','Liststring',{'waveforms','trialwaves','ispikes'},...
            'ListSize',[160 54]);
        if v==1
            switch s
                case 1
                    % need to remove the suffix from the input
                    [path,name] = nptFileParts(input);
                    obj = waveforms(name);
                    InspectGUI(obj);
                case 2
                    % need to remove the suffix from the input
                    [path,name] = nptFileParts(input);
                    obj = trialwaves(name);
                    InspectGUI(obj);
                case 3
                    % need to remove the suffix from the input
                    [path,name] = nptFileParts(input);
                    % prompt user to provide info about presence of gdf and muacluster
                    prompt = {'Is there a GDF file? (1 for Yes, 0 for No)','MUA Cluster Number? (0 for new cluster)'};
                    a = inputdlg(prompt,'Creating ispikes object...',1);
                    if ~isempty(a)
                        obj = ispikes(name,str2num(a{1}),str2num(a{2}));
                        % move up one directory since this will probably start the inspection
                        cd ..
                        InspectGUI(obj);
                    else
                        obj = [];
                    end
                otherwise
                    obj = [];
            end
        else
            obj = [];
        end
        
        
    elseif ~isempty(findstr(input,'waveforms.bin'))
        % need to find out if we need to create a waveforms object or
        % an ispikes object
        [s,v] = listdlg('PromptString','Which object do you want to create?',...
            'SelectionMode','single','Liststring',{'waveforms','trialwaves'},... %,'ispikes'},...
            'ListSize',[160 54]);
        if v==1
            [path,name] = nptFileParts(input);
            group = name(length(name)-12:length(name)-9);
            switch s
                case 1
                    %need to remove the suffix from the input
                    obj = waveforms(name);
                    InspectGUI(obj);
                case 2
                    %need to remove the suffix from the input
                    obj = trialwaves(name);
                    InspectGUI(obj);
                case 3
                    %prompt user to provide info about presence of gdf and muacluster
                    prompt = {'Is there a GDF file? (1 for Yes, 0 for No)'};
                    a = inputdlg(prompt,'Creating ispikes object...',1);
                    if ~isempty(a)
                        obj = ispikes(group,str2num(a{1}));
                        prompt={'Do you want to save the ISpikes object to the Current Directory?'};
                        button=questdlg(prompt,'Save ISpikes object','No');
                        if strcmp(button,'Yes')
                            save([name(1:length(name)-9) '_ispike'],'obj')
                        end
                        % move up one directory since this will probably start the inspection
                        cd ..
                        InspectGUI(obj);
                    else
                        obj = [];
                    end
                otherwise
                    obj = [];
            end
        else
            obj = [];
        end
        
    elseif ~isempty(findstr(input,'_eye.0'))
        % we should probably create a eye object
        % need to remove the suffix from the input
        [path,name] = nptFileParts(input);
        name=name(1:length(name)-4);
        % read the header of the eye file
        [d,numChannels] = nptReadDataFile(input);
        % create vector of channels
        c = 1:numChannels;
        % prompt user for channel number
        [s,v] = listdlg('PromptString','Select a channel:','SelectionMode','multiple',...
            'ListString',num2cell(num2str(c')),'ListSize',[160 (numChannels-1)*18]);
        if v==1			
            question={'Display the Eye Files with Degrees or Pixels '};
            buttonname = questdlg(question,'?Eye Position Units?','Degrees','Pixels','Degrees');
            %get the Stimulus Path
            if strcmp(buttonname,'Degrees')   
                u='degrees';
            else
                u='pixels';
            end
            obj = eyes(name,s,u);
            InspectGUI(obj);
        else
            obj = [];
        end
        %need to fix eyefilt stuff
    elseif ~isempty(findstr(input,'_eyefilt.0'))
        % we should probably create a eye object
        % need to remove the suffix from the input
        [path,name] = nptFileParts(input);
        name=name(1:length(name)-4);
        % read the header of the eye file
        [d,numChannels] = nptReadDataFile(input);
        % create vector of channels
        c = 1:numChannels;
        % prompt user for channel number
        
        [s,v] = listdlg('PromptString','Select a channel:','SelectionMode','multiple',...
            'ListString',num2cell(num2str(c')),'ListSize',[160 (numChannels-1)*18]);
        if v==1			
            u='pixels';
            obj = eyes(name,s,u);
            InspectGUI(obj);
        else
            obj = [];
        end
        
    elseif ~isempty(findstr(input,'_eyemovement.mat'))
        % this is an eyemovements object
        % need to load object from file
        %prompt user if if they want to view the eyemovements 
        %only or with a spike train.
        question={'Do you want a Spike Train shown';'with the Eye Movements?'};
        buttonname = questdlg(question,'?SPIKE TRAIN?',{'Yes','No'});
        %get eyemovements object no matter what.
        [path,name] = nptFileParts(input);
        eval(['obj=load(''' name ''');'])
        em = obj.em;
        if strcmp(buttonname,'Yes')      %then which spike train also
            [filename,path] = uigetfile('*_spike.mat','Select Spike Train File');
            if ~isempty(findstr(filename,'_spike.mat'))
                eyedir = nptPWD;
                cd (path)
                [path,name] = nptFileParts(filename);
                eval(['obj=load(''' name ''');'])
                spike = obj.spike;
                obj = eyespikes(em,spike);  %create eyespikes object
                cd (eyedir)	%back to eyedir b/c we need to read eye files to plot
            else
                errordlg('!ERROR! Must be a spike train file','ERROR')
            end
        else
            obj=em;
        end
        if ~strcmp(buttonname,'Cancel')
            InspectGUI(obj);
        end
        
    elseif  ~isempty(findstr(input,'ispike.mat')) | ~isempty(findstr(input,'spike.mat'))
        % this is an ispikes object
        % need to load object from file
        [path,name] = nptFileParts(input);
        eval(['spike = load(''' name ''');'])
        %assume we are in the spike directory 
        %and need to cd to session directory 
        %to display an ispikes object
        cd ..
        g = fieldnames(spike);
        eval(['s=spike.' char(g) ';'])
        if ~isempty(findstr(s.sessionname,'highpass'))
            cd('highpass')
        end       
        obj=ispikes(s);
        InspectGUI(obj);
        
    elseif ~isempty(findstr(input,'_spikeRF.mat')) 
        % this is an ispikes object
        % need to load object from file
        [path,name] = nptFileParts(input);
        eval(['RF=load(''' name ''');'])
        %assume we are in the spike directory 
        %and need to cd to session directory 
        %to display an ispikes object
        cd ..
        obj=ispikes(RF.RF);
        InspectGUI(obj);
        
        
        
    elseif ~isempty(findstr(input,'revcorr.mat'))
        % this is a revcorr object
        % need to load object from file
        [path,name] = nptFileParts(input);
        eval(['obj=load(''' name ''');']);
        InspectGUI(obj.obj);
        
        
        %list of all file types which are not objects and use a generic GUI.
        
    elseif ~isempty(findstr(input,'_FRcor.mat'))         |...
            ~isempty(findstr(input,'_spikeprob.mat'))      |...
            ~isempty(findstr(input,'_powerspectrum.mat'))  |...
            ~isempty(findstr(input,'_eccentricity.mat'))   |...
            ~isempty(findstr(input,'_eyeeventspike.mat'))  
        
        % this requires a generic GUI
        % need to load structure from file
        [path,name] = nptFileParts(input);
        eval(['obj=load(''' name ''');']);
        InspectGUI(obj)
        
        %list of all file types which are not objects and use Histogram GUI.
        
    elseif ~isempty(findstr(input,'_duration.mat'))       |...
            ~isempty(findstr(input,'_positionrange.mat'))  |...
            ~isempty(findstr(input,'_velocity.mat'))       |...
            ~isempty(findstr(input,'_ISI.mat'))            
        
        % this requires a generic GUI
        % need to load structure from file
        [path,name] = nptFileParts(input);
        eval(['obj=load(''' name ''');']);
        histInspectGUI(obj)
        
        
    elseif ~isempty(findstr(input,'.0'))
        % we should probably create a streamer object
        % need to remove the suffix from the input
        [path,name] = nptFileParts(input);
        % read the header of the streamer file
        numChannels = nptReadStreamerFileHeader(input);
        % create vector of channels
        c = 1:numChannels;
        % prompt user for channel number
        [s,v] = listdlg('PromptString','Select a channel:','SelectionMode','multiple',...
            'ListString',cellstr(num2str(c')),'ListSize',[160 (numChannels)*18]);
        if v==1			
            obj = streamer(name,s);
            InspectGUI(obj);
        else
            obj = [];
        end
        
    elseif ~isempty(findstr(input,'.gdf'))
        % we should probably create an ispikes object		
        % need to remove the suffix from the input
        [path,name] = nptFileParts(input);
        % remove also the last digit in the name since the gdf's have a 
        % '1' after the groupname
        nl = length(name);
        name = name(1:(nl-1));
        % read gdf file to get number of spikes for each cluster
        [gdf,numSpikes,numClusters,spikeCluster] = nptReadGDFFile(input);
        % create strings for dialog
        for i = 1:numClusters
            carray{i} = sprintf('%i (%i spikes)',i,spikeCluster(i));
        end
        carray = {'New Cluster' carray{:}};
        % prompt user to provide info muacluster
        [s,v] = listdlg('PromptString','To which cluster should missing spikes be added?',...
            'SelectionMode','single','ListString',carray,...
            'ListSize',[250 max(numClusters,2)*18]);
        if v==1
            obj = ispikes(name,1,s-1);
            cd ..
            % get session name to see if it is highpass
            if ~isempty(findstr(obj.sessionname,'_highpass'))
                cd highpass
            end
            InspectGUI(obj);
        else
            obj = [];
        end
        
        
    elseif ~isempty(findstr(input,'.cut')) 
        % we should probably create an ispikes object		
        [path,name] = nptFileParts(input);
        %pass in the groupname
        group=name(length(name)-12:length(name)-9);
        obj = ispikes(group,1);
        prompt={'Do you want to save the ISpikes object to the Current Directory?'};
                        button=questdlg(prompt,'Save ISpikes object','No');
                        if strcmp(button,'Yes')
                            save([name(1:length(name)-9) '_ispike'],'obj')
                        end
        cd ..
        % get session name to see if it is highpass
        if ~isempty(findstr(obj.sessionname,'_highpass'))
            cd highpass
        end
        InspectGUI(obj);
        
    elseif ~isempty(findstr(input,'.mat')) 
        try
            %just assume the file contains one object and plot it
            obj = load(input);
            f=fieldnames(obj);
            obj = eval(['obj.' f{1}]);
            figure;plot(obj)
        catch
            error(['error plotting ' input])
        end
        
    else     
        error('Unable to create data object');
        obj = [];
    end	
    
elseif ~isempty(find(strcmp(methods(class(input)),'plot')>0))
    % check to see if it is the right kind of object by first getting 
    % the class of the object, then the methods of the class, and then
    % comparing the strings in methods to see if a method plot is defined
    obj = input;
    InspectGUI(obj);
else
    error('Unable to create data object');
    return
end
