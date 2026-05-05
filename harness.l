[HARNESS.L - nkLisp test harness.  See nkl-test.md.]
[Wrapped in (progn ...) so revalo only echoes one '-> t' on load.]

(progn

(setq tests '())
(setq xfail-tests '())
(setq pending-tests '())
(setq failures '())
(setq pass-count 0)
(setq current-test nil)
(setq in-xfail nil)
(setq xfail-snapshot nil)
(setq xfail-body-errored nil)
(setq before-each-body nil)
(setq after-each-body nil)

(setq pass-byte 46)     [.]
(setq fail-byte 70)     [F]
(setq pending-byte 95)  [_]

<de reset-tests ()
	(setq tests '())
	(setq xfail-tests '())
	(setq pending-tests '())
	(setq failures '())
	(setq pass-count 0)
	(setq current-test nil)
	(setq in-xfail nil)
	(setq xfail-snapshot nil)
	(setq xfail-body-errored nil)
	(setq before-each-body nil)
	(setq after-each-body nil)>

[Inside an xfail body, suppress . / F / pass-count; only record the
failure so the snapshot mechanism can detect it.]
<de assert2 (exp act form)
	(if (equal exp act)
		(unless in-xfail (inc pass-count) (putc pass-byte))
		(progn
			(unless in-xfail (putc fail-byte))
			(setq failures (cons (list current-test exp act form) failures>

<de asserteq2 (exp act form)
	(if (eq exp act)
		(unless in-xfail (inc pass-count) (putc pass-byte))
		(progn
			(unless in-xfail (putc fail-byte))
			(setq failures (cons (list current-test exp act form) failures>

<de assert $a
	(assert2 (eval (car $a)) (eval (cadr $a)) (cadr $a>

[asserteq uses eq (pointer identity), not equal.]
<de asserteq $a
	(asserteq2 (eval (car $a)) (eval (cadr $a)) (cadr $a>

<de assert-err $a
	(if (eq 'err (catch 'err (eval (car $a))))
		(unless in-xfail (inc pass-count) (putc pass-byte))
		(progn
			(unless in-xfail (putc fail-byte))
			(setq failures (cons
				(list current-test 'expected-error 'no-error (car $a))
				failures>

[Body shape (() form...) matches nklisp's de cell so (eval (list name))
runs the body.]
<de deftest $a
	(putd (car $a) (cons '() (cdr $a)))
	(setq tests (cons (car $a) tests))
	(car $a>

<de deftest! $a
	(putd (car $a) (cons '() (cdr $a)))
	(setq xfail-tests (cons (car $a) xfail-tests))
	(car $a>

<de pending $a
	(setq pending-tests (cons (car $a) pending-tests))
	(car $a>

<de before-each $a
	(setq before-each-body $a)>

<de after-each $a
	(setq after-each-body $a)>

<de print-failure (failure)
	(prin1 'FAIL) (sp) (prin1 (car failure)) (sp)
	(prin1 'expected) (sp) (prin1 (cadr failure)) (sp)
	(prin1 'got) (sp) (prin1 (caddr failure)) (sp)
	(prin1 'in) (sp) (prin1 (car (cdddr failure))) (cr)>

[Eval forms in (catch 'err) so a crash records a stage-tagged failure
instead of aborting the spec.]
<de run-stage (forms tag)
	(if (eq 'err (catch 'err (mapc forms 'eval)))
		(progn
			(unless in-xfail (putc fail-byte))
			(setq failures
				(cons (list current-test 'no-error tag nil) failures>

<de run-test (test-name)
	(setq current-test test-name)
	(run-stage before-each-body 'before-each-crashed)
	(run-stage (list (list test-name)) 'body-crashed)
	(run-stage after-each-body 'after-each-crashed)>

[xfail PASS = body errored OR recorded a failure.  Track the two
conditions separately instead of conflating them.]
<de run-xfail-test (test-name)
	(setq current-test test-name)
	(setq xfail-snapshot failures)
	(setq in-xfail t)
	(run-stage before-each-body 'before-each-crashed)
	(setq xfail-body-errored
		(eq 'err (catch 'err (eval (list test-name)))))
	(run-stage after-each-body 'after-each-crashed)
	(setq in-xfail nil)
	(if (or xfail-body-errored (not (eq failures xfail-snapshot)))
		(progn
			(setq failures xfail-snapshot)
			(inc pass-count) (putc pass-byte))
		(progn
			(setq failures (cons
				(list test-name 'expected-fail 'passed-instead nil)
				failures))
			(putc fail-byte>

<de run-tests (spec-name)
	(cr)
	(mapc (reverse tests) 'run-test)
	(mapc (reverse xfail-tests) 'run-xfail-test)
	(mapc (reverse pending-tests) '((p) (putc pending-byte)))
	(cr)
	(if failures
		(progn
			(mapc (reverse failures) 'print-failure)
			(prin1 'FAIL) (sp) (prin1 spec-name) (sp)
			(prin1 (length tests)) (sp) (prin1 'tests) (sp)
			(if pending-tests
				(progn
					(prin1 (length pending-tests)) (sp)
					(prin1 'pending) (sp)))
			(prin1 (length failures)) (sp) (prin1 'failures) (cr))
		(progn
			(prin1 'OK) (sp) (prin1 spec-name) (sp)
			(prin1 (+ (length tests) (length xfail-tests)))
			(sp) (prin1 'tests) (sp)
			(if pending-tests
				(progn
					(prin1 (length pending-tests)) (sp)
					(prin1 'pending) (sp)))
			(prin1 pass-count) (sp) (prin1 'assertions) (cr>

<de load-spec (name)
	(reset-tests)
	(open name 1)
	(revalo 1)
	(close 1)
	(run-tests (car name))>

t)
