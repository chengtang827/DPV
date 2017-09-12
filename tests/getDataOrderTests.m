function tests = getDataOrderTests
  tests = functiontests(localfunctions);
end

function testFirst(testcase)
  cwd = pwd;
  tt = tempdir;
  input = 'Data/Wiesel/20170714/session01/array01/channel001/cell01';
  expected_output = [tt 'Data/Wiesel/20170714'];
  cd(tt);
  mkdir(input);
  cd(input);
  dd = getDataOrder('day');
  cd(cwd);
  verifyEqual(testcase, dd, expected_output);
end

function testSecond(testcase)
  input = '/Data/Wiesel/20170714';
  output = getDataOrder('day','DirString', input);
  verifyEqual(testcase, input, output);
end

function testShortName(testcase)
  input = '/NewWorkingMemory/Wiesel/20170714/session03/array01/channel006/cell01';
  output = getDataOrder('ShortName','DirString',input);
  expected_output = 'Wiesel20170714s3a1c6u1';
  verifyEqual(testcase, output, expected_output);
end
