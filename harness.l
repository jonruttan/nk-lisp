[HARNESS.L - nkLisp test harness]
[Defines: deftest, assert, asserteq, runTests, resetTests, loadSpec]
[Loaded first by runtests.l; then specs are loaded one at a time]

[Spec file template (CP/M 8.3 name, e.g. t-foo.l):
    <deftest test-foo
        (assert 42 (myFunc 6 7))
        (assert (quote a) (car (quote (a b))))>
    t
]

[Runner template (runtests.l or custom):
    (alloc 2)                                  -- top-level alloc only
    (open (quote (harness l)) 1) (revalo 1) (close 1)
    (loadSpec (quote (t-foo l)))
    (bdos 0)
    t
]

[Conventions:
  Every loadable file MUST end with a literal t so revalo exits
  alloc must be at top level - shifts memory, breaks nested eval
  Channel 0 is taken by the CLI loader - use 1 or higher with alloc 3+
  Super-paren close > closes back to the most recent < - inside
    a deftest, prefer plain ) for inner exprs and use > only at the
    very end of the deftest, or it will close too far back
]

[Output:
  Pass = . per assertion; F per failure. Summary line is greppable:
    OK <n> tests <m> assertions
  or
    FAIL <n> tests <k> failures
  preceded by per-failure detail lines starting with FAIL
]

(setq tests '())
(setq fails '())
(setq passCt 0)
(setq curTest nil)

<de resetTests ()
    (setq tests '())
    (setq fails '())
    (setq passCt 0)
    (setq curTest nil)>

<de assert2 (exp act form)
    (if (equal exp act)
        (progn (inc passCt) (putc 46))
        (progn (putc 70)
            (setq fails (cons (list curTest exp act form) fails>

<de asserteq2 (exp act form)
    (if (eq exp act)
        (progn (inc passCt) (putc 46))
        (progn (putc 70)
            (setq fails (cons (list curTest exp act form) fails>

<de assert $a
    (assert2 (eval (car $a)) (eval (cadr $a)) (cadr $a>

<de asserteq $a
    (asserteq2 (eval (car $a)) (eval (cadr $a)) (cadr $a>

<de deftest $a
    (putd (car $a) (cons '() (cdr $a)))
    (setq tests (cons (car $a) tests>

<de printFail (f)
    (prin1 'FAIL) (sp) (prin1 (car f)) (sp)
    (prin1 'expected) (sp) (prin1 (cadr f)) (sp)
    (prin1 'got) (sp) (prin1 (caddr f)) (sp)
    (prin1 'in) (sp) (prin1 (nth 3 f)) (cr)>

<de runTests ()
    (cr)
    (mapc (reverse tests) '((tn)
        (setq curTest tn)
        (eval (list tn))))
    (cr)
    (if fails
        (progn
            (mapc (reverse fails) 'printFail)
            (prin1 'FAIL) (sp)
            (prin1 (length tests)) (sp) (prin1 'tests) (sp)
            (prin1 (length fails)) (sp) (prin1 'failures) (cr))
        (progn
            (prin1 'OK) (sp)
            (prin1 (length tests)) (sp) (prin1 'tests) (sp)
            (prin1 passCt) (sp) (prin1 'assertions) (cr>

<de loadSpec (name)
    (resetTests)
    (open name 1)
    (revalo 1)
    (close 1)
    (runTests)>

t
