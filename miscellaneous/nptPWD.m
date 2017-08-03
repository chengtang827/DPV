function a = nptPWD()
%a=nptPWD()
%same as matlab's PWD but 
%platform independent

wd = pwd;
wd_length = size(wd,2);

if strcmp(wd(wd_length),':')
	a = wd(1:wd_length-1);
else
	a = wd;
end
 