function colors = nptDefaultColors(index);
%colors = nptDefaultColors(index)
%returns a list of index number of colors that are always the same.

if max(index)>100
    index=1:100;
end


defaultColors(1,:)= [160/239,240/240,120/120]; %royal blue
defaultColors(2,:)= [0/239,240/240,120/120];   %red
defaultColors(3,:)= [80/239,240/240,60/120];   %green
defaultColors(4,:)= [196/239,238/240,105/120];  %purple
defaultColors(5,:)= [220/239,240/240,120/120]; %pink
defaultColors(6,:)= [20/239,240/240,120/120];  %orange
defaultColors(7,:)= [75/239,220/240,100/120];   %green
defaultColors(8,:)= [140/239,240/240,120/120]; %bright blue
defaultColors(9,:)= [180/239,240/240,120/120]; %purple
defaultColors(10,:)= [9/239,215/240,99/120];    %red brown

rand('state',0)
defaultColors(11:100,1)=rand(90,1);
defaultColors(11:100,2)=240/240;
defaultColors(11:100,3)=100/120;



colors = hsv2rgb(defaultColors(index,:));