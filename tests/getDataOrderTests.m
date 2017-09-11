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
