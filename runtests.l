[RUNTESTS.L - in-CP/M test runner]
[Loads harness, then each spec in sequence; exits to CP/M.]
[Run as: cpm --exec nkl runtests.l - or from CP/M: nkl runtests.l]

[alloc 3: channel 1 for load-spec, channel 2 for spec-internal loads.]
(alloc 3)
(open '(harness l) 1) (revalo 1) (close 1)

[Single progn so revalo doesn't echo '-> nil' between specs.]
(progn
    (load-spec '(tharness l))
    (load-spec '(t-ctrl l))
    (load-spec '(t-eval l))
    (load-spec '(t-arith l))
    (load-spec '(t-list l))
    (load-spec '(t-pred l))
    (load-spec '(t-catch l))
    (load-spec '(t-sym l))
    (load-spec '(t-io l))
    (load-spec '(t-too l))
    (prin1 'DONE) (cr)
    (bdos 0))
