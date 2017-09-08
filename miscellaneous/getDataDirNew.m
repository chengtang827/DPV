function dd = getDataDirNew(newlevelname)
%dd = getDataDirNew(LEVEL) returns the absolute path to LEVEL from the current
%working directory. For example, calling getDataDirNew('day') from
%/data/Wiesel/20170714/session01 returns /data/Wiesel/20170714
  parts = split(pwd, filesep);
  %remove numbers to get the levelname
  levelname = regexprep(parts{end}, "[0-9]*", '');
  if isempty(levelname) %removed all numbers, so must be day
    levelname = 'day';
  end
  level = levelConvert('LevelName',levelname);
  newlevel = levelConvert('Levelname', newlevelname);
  ddc = join(parts(1:end-(newlevel-level)),filesep);
  dd = ddc{1};
end
