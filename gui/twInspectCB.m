function InspectCB(action)

switch(action)
case 'Load'
	[filename,path] = uigetfile('*.*','Select data file');
	if(filename~=0)
		cd(path);
		obj = CreateDataObject(filename);
   end

case 'TPrevious'
	s = get(gcbf,'UserData');
	[n,s.tev] = Decrement(s.tev);
    edithandle = findobj('Tag','TEditText');
    set(edithandle,'String',n);
    s.wev = event(1,get(s.obj,'TrialWaves',n));
    edithandle = findobj('Tag','WEditText');
    set(edithandle,'String',1);
    w = ToWaveNumber(s.obj,n,1);
    s.obj = plot(s.obj,w);
	if s.holdaxis
		ax = axis;
		[s.lm,lmin,lmax] = update(s.lm,ax(3),ax(4));
		axis([ax(1) ax(2) lmin lmax]);
	end		
	set(gcbf,'UserData',s);

case 'TNext'
	s = get(gcbf,'UserData');
	[n,s.tev] = Increment(s.tev);
    edithandle = findobj('Tag','TEditText');
    set(edithandle,'String',n);
    s.wev = event(1,get(s.obj,'TrialWaves',n));
    edithandle = findobj('Tag','WEditText');
    set(edithandle,'String',1);
    w = ToWaveNumber(s.obj,n,1);
	s.obj = plot(s.obj,w);
	if s.holdaxis
		ax = axis;
		[s.lm,lmin,lmax] = update(s.lm,ax(3),ax(4));
		axis([ax(1) ax(2) lmin lmax]);
	end		
	set(gcbf,'UserData',s);

case 'TNumber'
	n = eval(get(gcbo,'String'));
	s = get(gcbf,'UserData');
	s.tev = SetEventNumber(s.tev,n);
    edithandle = findobj('Tag','TEditText');
    set(edithandle,'String',n);
    s.wev = event(1,get(s.obj,'TrialWaves',n));
    edithandle = findobj('Tag','WEditText');
    set(edithandle,'String',1);
    w = ToWaveNumber(s.obj,n,1);
	s.obj = plot(s.obj,w);
	if s.holdaxis
		ax = axis;
		[s.lm,lmin,lmax] = update(s.lm,ax(3),ax(4));
		axis([ax(1) ax(2) lmin lmax]);
	end		
	set(gcbf,'UserData',s);

case 'WPrevious'
	s = get(gcbf,'UserData');
    [n,s.wev] = Decrement(s.wev);
    edithandle = findobj('Tag','WEditText');
    set(edithandle,'String',n);
    t = GetEventNumber(s.tev);
    w = ToWaveNumber(s.obj,t,n);
	s.obj = plot(s.obj,w);
	if s.holdaxis
		ax = axis;
		[s.lm,lmin,lmax] = update(s.lm,ax(3),ax(4));
		axis([ax(1) ax(2) lmin lmax]);
	end		
	set(gcbf,'UserData',s);

case 'WNext'
	s = get(gcbf,'UserData');
	[n,s.wev] = Increment(s.wev);
    edithandle = findobj('Tag','WEditText');
    set(edithandle,'String',n);
    t = GetEventNumber(s.tev);
    w = ToWaveNumber(s.obj,t,n);
	s.obj = plot(s.obj,w);
	if s.holdaxis
		ax = axis;
		[s.lm,lmin,lmax] = update(s.lm,ax(3),ax(4));
		axis([ax(1) ax(2) lmin lmax]);
	end		
	set(gcbf,'UserData',s);

case 'WNumber'
	n = eval(get(gcbo,'String'));
	s = get(gcbf,'UserData');
	s.wev = SetEventNumber(s.wev,n);
    t = GetEventNumber(s.tev);
    w = ToWaveNumber(s.obj,t,n);
	s.obj = plot(s.obj,w);
	if s.holdaxis
		ax = axis;
		[s.lm,lmin,lmax] = update(s.lm,ax(3),ax(4));
		axis([ax(1) ax(2) lmin lmax]);
	end		
	set(gcbf,'UserData',s);

case 'Quit'
	close(gcbf)
end
	