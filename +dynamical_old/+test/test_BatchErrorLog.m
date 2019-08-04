function tests = test_BatchErrorLog()
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
directory = fileparts(mfilename('fullpath'));
directory = fullfile(directory, 'test');
testCase.TestData.directory = directory;

file = '/path/to/file';
testCase.TestData.file = file;

errorId = 'error:id';
errorMessage = 'error message';
error = MException(errorId, errorMessage);
testCase.TestData.errorId = errorId;
testCase.TestData.errorMessage = errorMessage;
testCase.TestData.error = error;
end

function setup(testCase)
mkdir(testCase.TestData.directory);
end

function teardown(testCase)
rmdir(testCase.TestData.directory, 's');
end

function testLoggedErrorsDetectable(testCase)
import dynamical.BatchErrorLog;

batchErrorLog = BatchErrorLog();
batchErrorLog.log(testCase.TestData.file, testCase.TestData.error);

testCase.verifyTrue(batchErrorLog.loggedErrors());
end

function testNoLoggedErrorsDetectable(testCase)
import dynamical.BatchErrorLog;

batchErrorLog = BatchErrorLog();

testCase.verifyFalse(batchErrorLog.loggedErrors());
end

function testFileWithErrorInSummary(testCase)
import dynamical.BatchErrorLog;

batchErrorLog = BatchErrorLog();
batchErrorLog.log(testCase.TestData.file, testCase.TestData.error);

summary = batchErrorLog.summarize();

testCase.verifyTrue(contains(summary, testCase.TestData.file));
end

function testSaveCreatesLog(testCase)
import dynamical.BatchErrorLog;

batchErrorLog = BatchErrorLog();
batchErrorLog.log(testCase.TestData.file, testCase.TestData.error);
filePath = batchErrorLog.save(testCase.TestData.directory);
clc
testCase.verifyTrue(exist(filePath, 'file') == 2);
end

function testLogContainsFileWithError(testCase)
import dynamical.BatchErrorLog;

batchErrorLog = BatchErrorLog();
batchErrorLog.log(testCase.TestData.file, testCase.TestData.error);
filePath = batchErrorLog.save(testCase.TestData.directory);

log = fileread(filePath);

testCase.verifyTrue(contains(log, testCase.TestData.file));
end

function testLogContainsError(testCase)
import dynamical.BatchErrorLog;

batchErrorLog = BatchErrorLog();
batchErrorLog.log(testCase.TestData.file, testCase.TestData.error);
filePath = batchErrorLog.save(testCase.TestData.directory);

log = fileread(filePath);

testCase.verifyTrue(contains(log, testCase.TestData.errorMessage));
end
