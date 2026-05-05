[T-LIST.L - list manipulation primitives spec]
[Covers car, cdr, cons, list, append, nconc, reverse, length, nth, nthcdr,]
[member, memq, assoc, delete, mapc, mapcar, mapcan, push, pop, rplaca, rplacd.]

<deftest test-car
	(assert 1 (car '(1 2 3)))
	(assert 'a (car '(a)))
	(assert nil (car nil))>

<deftest test-cdr
	(assert '(2 3) (cdr '(1 2 3)))
	(assert nil (cdr '(1)))
	(assert nil (cdr nil))>

<deftest test-cons
	(assert '(1 . 2) (cons 1 2))
	(assert '(1 2 3) (cons 1 '(2 3)))
	(assert '(1) (cons 1 nil))>

<deftest test-list
	(assert '(1 2 3) (list 1 2 3))
	(assert '() (list))
	(assert '(a) (list 'a))>

<deftest test-append
	(assert '(1 2 3 4) (append '(1 2) '(3 4)))
	(assert '(1 2 3) (append '(1 2 3) nil))
	(assert '(1 2 3) (append nil '(1 2 3)))>

<deftest test-reverse
	(assert '(3 2 1) (reverse '(1 2 3)))
	(assert nil (reverse nil))
	(assert '(a) (reverse '(a)))>

<deftest test-length
	(assert 0 (length nil))
	(assert 3 (length '(1 2 3)))
	(assert 1 (length '(a)))>

<deftest test-nth
	(assert 1 (nth 0 '(1 2 3)))
	(assert 3 (nth 2 '(1 2 3)))
	(assert nil (nth 5 '(1 2 3)))>

<deftest test-nthcdr
	(assert '(1 2 3) (nthcdr 0 '(1 2 3)))
	(assert '(3) (nthcdr 2 '(1 2 3)))
	(assert nil (nthcdr 5 '(1 2 3)))>

<deftest test-member
	(assert '(2 3) (member 2 '(1 2 3)))
	(assert nil (member 99 '(1 2 3)))>

<deftest test-memq
	(assert '(b c) (memq 'b '(a b c)))
	(assert nil (memq 'z '(a b c)))>

<deftest test-assoc
	(assert '(b . 2) (assoc 'b '((a . 1) (b . 2) (c . 3))))
	(assert nil (assoc 'z '((a . 1) (b . 2))))>

<deftest test-delete
	(assert '(1 3) (delete 2 '(1 2 3)))
	(assert '(1 2) (delete 99 '(1 2)))>

<deftest test-mapc
	[mapc returns nil; verify by checking side effect]
	(setq sum 0)
	(mapc '(1 2 3 4) '((x) (setq sum (+ sum x))))
	(assert 10 sum)>

<deftest test-mapcar
	(assert '(2 3 4 5) (mapcar '(1 2 3 4) '1+))
	(assert nil (mapcar nil '1+))
	(assert '(2) (mapcar '(1) '1+))>

<deftest test-mapcan
	[mapcan applies fn returning lists, nconcs them together]
	(assert '(1 1 2 2 3 3)
		(mapcan '(1 2 3) '((x) (list x x))))>

<deftest test-nconc
	[nconc destructively concatenates lists]
	(assert '(1 2 3 4) (nconc '(1 2) '(3 4)))
	(assert '(1 2 3) (nconc nil '(1 2 3)))
	(assert '(1 2 3) (nconc '(1 2 3) nil))>

<deftest test-nconc-mutates
	[first arg is mutated in place; second arg unchanged]
	(setq x (list 1 2))
	(setq y (list 3 4))
	(nconc x y)
	(assert '(1 2 3 4) x)
	(assert '(3 4) y)>

<deftest test-push-pop
	(setq stk nil)
	(push 1 stk)
	(push 2 stk)
	(push 3 stk)
	(assert '(3 2 1) stk)
	(assert 3 (pop stk))
	(assert '(2 1) stk)>

<deftest test-rplaca
	(setq p '(1 2))
	(rplaca p 'a)
	(assert '(a 2) p)
	[rplaca returns the mutated cell]
	(setq p '(1 2))
	(assert '(a 2) (rplaca p 'a))>

<deftest test-rplacd
	(setq p '(1 2))
	(rplacd p '(b c))
	(assert '(1 b c) p)
	[rplacd returns the mutated cell]
	(setq p '(1 2))
	(assert '(1 b c) (rplacd p '(b c)))>

<deftest test-rplaca-shared
	[mutating one alias is visible through the other]
	(setq a (list 1 2))
	(setq b a)
	(rplaca a 'x)
	(assert '(x 2) b)>

<deftest test-rplacd-shared
	(setq a (list 1 2))
	(setq b a)
	(rplacd a '(y))
	(assert '(1 y) b)>

