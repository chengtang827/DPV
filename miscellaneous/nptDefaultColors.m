function colors = nptDefaultColors(index);
%colors = nptDefaultColors(index)
%returns a list of index number of colors that are always the same.

if max(index)>100
    index=1:100;
end

% these are the default colors starting in R2014b
defaultColors(1,:)= [0.5661    1.0000    0.7410]; %royal blue
defaultColors(2,:)= [0.0503    0.8847    0.8500];   %red
defaultColors(3,:)= [0.1180    0.8654    0.9290];   %green
defaultColors(4,:)= [0.8056    0.6691    0.5560];  %purple
defaultColors(5,:)= [0.2380    0.7211    0.6740]; %pink
defaultColors(6,:)= [0.5496    0.6774    0.9330];  %orange
defaultColors(7,:)= [0.9683    0.8772    0.6350];   %green

rand('state',0)

defaultColors(8:100,1)=rand(90,1);
defaultColors(8:100,2)=240/240;
defaultColors(8:100,3)=100/120;

% defaultColors(1,:)= [160/239,240/240,120/120]; %royal blue
% defaultColors(2,:)= [0/239,240/240,120/120];   %red
% defaultColors(3,:)= [80/239,240/240,60/120];   %green
% defaultColors(4,:)= [196/239,238/240,105/120];  %purple
% defaultColors(5,:)= [220/239,240/240,120/120]; %pink
% defaultColors(6,:)= [20/239,240/240,120/120];  %orange
% defaultColors(7,:)= [75/239,220/240,100/120];   %green
% defaultColors(8,:)= [140/239,240/240,120/120]; %bright blue
% defaultColors(9,:)= [180/239,240/240,120/120]; %purple
% defaultColors(10,:)= [9/239,215/240,99/120];    %red brown

% rand('state',0)

% defaultColors(11:100,1)=rand(90,1);
% defaultColors(11:100,2)=240/240;
% defaultColors(11:100,3)=100/120;

colors = hsv2rgb(defaultColors(index,:));