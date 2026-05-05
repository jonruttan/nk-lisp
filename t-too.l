[T-TOO.L - tests for too.l.  See nkl-test.md.]

(open '(too l) 2) (revalo 2) (close 2)

<deftest test-depth
	(assert 1 (depth nil))
	(assert 0 (depth 'a))
	(assert 1 (depth '(a)))
	(assert 1 (depth '(a b c)))
	(assert 2 (depth '((a b) c)))
	(assert 3 (depth '((a (b c)) d)))>

<deftest test-sort
	(assert '(1 2 3) (sort (list 3 1 2)))
	(assert '(1 2 3 4 5) (sort (list 5 3 1 4 2)))
	(assert '(1) (sort (list 1)))>

<deftest test-who
	[who is a fexpr - takes the target UNQUOTED]
	(de tt-uses-car (x) (car x))
	(assert t (if (memq 'tt-uses-car (who car)) t nil))>

<deftest test-trace-untrace
	(de tt-trace-target (x) (car x))
	(setq orig (getd 'tt-trace-target))
	(trace tt-trace-target)
	(assert nil (equal orig (getd 'tt-trace-target)))
	(assert '$trace (caadr (getd 'tt-trace-target)))
	(assert '(x) (car (getd 'tt-trace-target)))
	(untrace tt-trace-target)
	(assert orig (getd 'tt-trace-target))>

<deftest test-break-unbreak
	(de tt-break-target (x) (car x))
	(setq orig-b (getd 'tt-break-target))
	(break tt-break-target)
	(assert nil (equal orig-b (getd 'tt-break-target)))
	(assert 'stop (caadr (getd 'tt-break-target)))
	(assert '(x) (car (getd 'tt-break-target)))
	(unbreak tt-break-target)
	(assert orig-b (getd 'tt-break-target))>

t
