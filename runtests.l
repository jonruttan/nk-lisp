[RUNTESTS.L - in-CP/M test runner]
[Loads harness, then each spec in sequence; exits to CP/M.]
[Run as: cpm --exec nkl runtests.l - or from CP/M: nkl runtests.l]

[alloc must be at top level; channel 0 is taken by the loader, so use 1.]
(alloc 2)
(open '(harness l) 1) (revalo 1) (close 1)

(loadSpec '(tharness l))
(loadSpec '(t-ctrl l))
(loadSpec '(t-eval l))
(loadSpec '(t-arith l))
(loadSpec '(t-list l))
(loadSpec '(t-pred l))
(loadSpec '(t-catch l))
(loadSpec '(t-sym l))
(loadSpec '(t-io l))

(bdos 0)
t
