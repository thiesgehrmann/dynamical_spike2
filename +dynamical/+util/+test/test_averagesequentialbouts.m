function tests = test_averagesequentialbouts()

tests = functiontests(localfunctions);

end

function testSequentialBoutsAveraged(testCase)
import dynamical.util.averagesequentialbouts;

time = [1 2 3];
data = [1 2 3];
boutLength = 1;

actual = averagesequentialbouts(time, data, boutLength);
expected = expectedSeq(1, 3, 2);

testCase.verifyEqual(actual, expected);
end

function testJumpsGreaterThanBoutLengthExcludeFromAverage(testCase)
import dynamical.util.averagesequentialbouts;

time = [1 2 4];
data = [1 2 3];
boutLength = 1;

actual = averagesequentialbouts(time, data, boutLength);
expected = [
    expectedSeq(1, 2, 1.5);
    expectedSeq(4, 4, 3)];

testCase.verifyEqual(actual, expected);
end

function testJumpsLessThanBoutLengthExcludedFromAverage(testCase)
import dynamical.util.averagesequentialbouts;

time = [1 2 2.5];
data = [1 2 3];
boutLength = 1;

actual = averagesequentialbouts(time, data, boutLength);
expected = [
    expectedSeq(1, 2, 1.5);
    expectedSeq(2.5, 2.5, 3)];

testCase.verifyEqual(actual, expected);
end

function testOneDataPointReturnsOneSeq(testCase)
import dynamical.util.averagesequentialbouts;

actual = averagesequentialbouts(1, 1, 1);
expected = expectedSeq(1, 1, 1);

testCase.verifyEqual(actual, expected);
end

function testErrorOnDifferentNumElements(testCase)
import dynamical.util.averagesequentialbouts;

time = [1 2];
data = 1;

testCase.verifyError(@() averagesequentialbouts(time, data,  1), '');
end

function expected = expectedSeq(seqStart, seqEnd, seqAverage)
expected = struct(...
    'seqStart', seqStart,...
    'seqStop', seqEnd,...
    'seqAverage', seqAverage);
end
