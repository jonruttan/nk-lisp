[T-CTRL.L - control flow primitives spec]
[Covers if, when, unless, cond, do, progn, prog1, prog2,]
[while, until, and, or - the recently-restored forms.]

<deftest test-if
	(assert 1 (if t 1 2))
	(assert 2 (if nil 1 2))
	(assert nil (if nil 1))
	(assert 1 (if 'something 1 2))
	[if-false body allows multiple expressions; result is last]
	(assert 3 (if nil 1 2 3))>

<deftest test-when
	(assert 3 (when t 1 2 3))
	(assert nil (when nil 1 2 3))
	(assert 1 (when t 1))>

<deftest test-unless
	(assert 3 (unless nil 1 2 3))
	(assert nil (unless t 1 2 3))
	(assert 1 (unless nil 1))>

<deftest test-cond
	(assert 1 (cond (t 1)))
	(assert 2 (cond (nil 1) (t 2)))
	(assert nil (cond (nil 1) (nil 2)))
	[Note: nkLisp's cond evaluates only the FIRST body element per clause -]
	[extra elements are ignored. This differs from most other Lisps.]
	(assert 1 (cond (t 1 2 3)))>

<deftest test-do
	(assert 7 (do i 0 (lessp i 8) (1+ i) i))
	(assert 4 (do i 0 (lessp i 5) (1+ i) i))>

<deftest test-progn
	(assert 3 (progn 1 2 3))
	(assert 1 (progn 1))>

<deftest test-prog1
	(assert 1 (prog1 1 2 3))>

<deftest test-prog2
	(assert 2 (prog2 1 2 3))>

<deftest test-while
	(assert nil (while nil 1))
	(setq i 3)
	(assert 0 (while (not (zerop i)) (setq i (1- i>

<deftest test-until
	(setq i 0)
	(assert 5 (until (equal i 5) (setq i (1+ i>

<deftest test-and
	(assert t (and t t))
	(assert nil (and t nil))
	(assert nil (and nil t))
	(assert 3 (and 1 2 3))>

<deftest test-or
	(assert t (or t nil))
	(assert nil (or nil nil))
	(assert 1 (or 1 2 3))
	(assert 2 (or nil 2 3))>

<deftest test-reptn
	[reptn evaluates body num times; returns last value]
	(setq n 1)
	(reptn 8 (setq n (2* n)))
	(assert 256 n)
	(assert 'last (reptn 3 'x 'last))>

<deftest test-return
	(de tcr-early (n)
		(setq tcr-flag nil)
		(if (zerop n) (return 'short))
		(setq tcr-flag t)
		'finished)
	(assert 'short (tcr-early 0))
	(assert nil tcr-flag)
	(assert 'finished (tcr-early 1))
	(assert t tcr-flag)>

<deftest test-go
	(de tcg-jump (n)
		(go n)
		1 (return 'one)
		2 (return 'two)
		3 (return 'three))
	(assert 'one (tcg-jump 1))
	(assert 'two (tcg-jump 2))
	(assert 'three (tcg-jump 3))>
