% need nptReadStreamerFile, getDataDirs
cd 073004/site01/session03
% uses @performance/performance.m to create a performance object
% if an object has been created beforehand and saved, it will load the saved object
pf1 = performance('auto');
% uses @performance/plot.m to plot the results
plot(pf1)

cd ../../../080204/site01/session02
% uses @performance/performance.m to compute another performance object
pf2 = performance('auto');
% uses @performance/plot.m to plot the results
figure
plot(pf2)

cd ../../..
% uses @performance/plus.m to combine 2 performance objects
pf = pf1 + pf2;
% use InspectGUI to call @performance/plot.m to pan through the results session by session
InspectGUI(pf)
% or to plot the combined data
InspectGUI(pf,'overallonly')
InspectGUI(pf,'overallonly','sessionmeans')

% now instead of creating the objects session by session, we will use ProcessDays to create all 
% possible performance objects. And instead of loading pre-saved objects, we are going to recompute
% both the performance object, and the eyestarget object, which is used to compute performance
pfpop = ProcessDays(performance,'redolevels',5);
InspectGUI(pfpop)

% the directories that contained valid data for the performance objects can now be extracted to
% create other objects
nd = nptdata(pfpop);
[nd,tipop] = ProcessDirs(nd,'Object','timing','redolevels',5);
InspectGUI(tipop)

You can create a plot with 2 objects using the following:

InspectGUI(pfpop,'addObjs',{tipop},'SP',[2 1])

If you want to place them side-by-side, you can do the following:

InspectGUI(pfpop,'addObjs',{tipop},'SP',[1 2])

cd 080204/site01/session02/eye
et = eyestarget('auto','redolevels',5);
cd ..
cd highpass
st = streamer('disco08020402_highpass',1);
cd ..
cd group0002/cluster01s
is = ispikes('auto');
InspectGUI(et,'addObjs',{st,is},'SP',[3 1],'LinkedZoom')
