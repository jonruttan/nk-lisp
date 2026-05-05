[THARNESS.L - meta-tests for the test harness itself]
[Verifies assert and asserteq behavior on simple cases.]
[All assertions in this file should PASS - if any fail, the harness is broken.]

<deftest tharness-equal-numbers
    (assert 1 1)
    (assert 0 0)
    (assert 42 42)>

<deftest tharness-equal-symbols
    (assert 'foo 'foo)
    (assert 't 't)
    (assert nil nil)>

<deftest tharness-equal-lists
    (assert '(1 2 3) (list 1 2 3))
    (assert '(a (b c)) (list 'a (list 'b 'c)))
    (assert '() '())>

<deftest tharness-equal-evaluates-actual
    [the second arg is eval'd; here (+ 1 1) yields 2]
    (assert 2 (+ 1 1))
    (assert 'a (car '(a b)))>

<deftest tharness-asserteq-symbols
    (asserteq 'foo 'foo)
    (asserteq nil nil)>

[assert-err: catches an interpreter error.  (car 'x) raises a type
error; assert-err passes when the body errors.  Confirms the
catch-'err machinery in nklisp.mac and the assert-err wrapper are
both wired up.]
<deftest tharness-assert-err
    (assert-err (car 'x))>

[deftest!: expected-fail.  Body must contain a failing assertion
or the xfail-test itself fails.  Exercises the harness's own
failure-detection path; if the recorded-failures machinery breaks,
this test starts passing unexpectedly and the suite goes red.]
<deftest! tharness-expected-fail
    (assert 1 2)>

t
