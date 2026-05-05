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

[Reset all per-spec state to its initial value.]
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

[assert2/asserteq2: workhorses called by the assert/asserteq fexprs.
Inside an xfail test (in-xfail = t), the . / F output and pass-count
update are suppressed; only the failures list is recorded so the
xfail snapshot mechanism can detect that something failed.]
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

[Compare the eval'd value of the second argument with the first.]
<de assert $a
	(assert2 (eval (car $a)) (eval (cadr $a)) (cadr $a>

[Like assert but uses eq (pointer identity) instead of equal.]
<de asserteq $a
	(asserteq2 (eval (car $a)) (eval (cadr $a)) (cadr $a>

[Pass if the form raises an interpreter error (caught via 'err).]
<de assert-err $a
	(if (eq 'err (catch 'err (eval (car $a))))
		(unless in-xfail (inc pass-count) (putc pass-byte))
		(progn
			(unless in-xfail (putc fail-byte))
			(setq failures (cons
				(list current-test 'expected-error 'no-error (car $a))
				failures>

[Define a test.  Body shape (() form...) matches nklisp's de cell.]
<de deftest $a
	(putd (car $a) (cons '() (cdr $a)))
	(setq tests (cons (car $a) tests))
	(car $a>

[Define an expected-fail test - passes only if the body fails or errors.]
<de deftest! $a
	(putd (car $a) (cons '() (cdr $a)))
	(setq xfail-tests (cons (car $a) xfail-tests))
	(car $a>

[Register a test by name only; body is dropped, displayed as _ in output.]
<de pending $a
	(setq pending-tests (cons (car $a) pending-tests))
	(car $a>

[Register setup/teardown forms run around each test in this spec.]
<de before-each $a
	(setq before-each-body $a)>

<de after-each $a
	(setq after-each-body $a)>

[Print one failure record (current-test exp act form) on its own line.]
<de print-failure (failure)
	(prin1 'FAIL) (sp) (prin1 (car failure)) (sp)
	(prin1 'expected) (sp) (prin1 (cadr failure)) (sp)
	(prin1 'got) (sp) (prin1 (caddr failure)) (sp)
	(prin1 'in) (sp) (prin1 (car (cdddr failure))) (cr)>

[Eval forms wrapped in (catch 'err); on error, print F (suppressed
inside an xfail body) and record the crash with a stage-tagged
'<stage>-crashed in the 'got slot.  Used for setup, teardown, and
the test body via a one-form wrapper list.]
<de run-stage (forms tag)
	(if (eq 'err (catch 'err (mapc forms 'eval)))
		(progn
			(unless in-xfail (putc fail-byte))
			(setq failures
				(cons (list current-test 'no-error tag nil) failures>

[Run a regular test: setup, body, teardown.  Each stage isolated.]
<de run-test (test-name)
	(setq current-test test-name)
	(run-stage before-each-body 'before-each-crashed)
	(run-stage (list (list test-name)) 'body-crashed)
	(run-stage after-each-body 'after-each-crashed)>

[Run an expected-fail test: pass if body crashes OR records a fail.
Tracks whether the body errored explicitly (xfail-body-errored) and
checks failures-grew separately, instead of conflating them.]
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
			[body errored or recorded a failure: counts as xfail PASS]
			(setq failures xfail-snapshot)
			(inc pass-count) (putc pass-byte))
		(progn
			[body returned cleanly with no failures: unexpected pass]
			(setq failures (cons
				(list test-name 'expected-fail 'passed-instead nil)
				failures))
			(putc fail-byte>

[Run all registered tests for the current spec, then print summary.]
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

[Reset state, load a spec file on channel 1, then run its tests.]
<de load-spec (name)
	(reset-tests)
	(open name 1)
	(revalo 1)
	(close 1)
	(run-tests (car name))>

t)
