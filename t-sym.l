[T-SYM.L - symbol functions and property lists]
[Covers gensym, unpack, pack, ascii, char, intern, oblist,]
[plus the property-list ops put, get, putpl, getpl.]

[Notes on testing patterns used here:]
[ * char/pack/unpack produce UNINTERNED symbols, which are not eq/equal]
[   to literal symbols of the same name. To compare against a literal,]
[   wrap the result in (intern ...).]
[ * Symbol equality is pointer identity (per EQUAL? in prim.mac); two]
[   symbols with the same print-name but different addresses are NOT]
[   equal. Use (ascii ...) to verify char content, or (intern ...) to]
[   canonicalise.]

<deftest test-gensym
	[each gensym call returns a fresh, distinct symbol]
	(setq g1 (gensym))
	(setq g2 (gensym))
	(assert t (symbolp g1))
	(assert t (symbolp g2))
	(assert nil (eq g1 g2))>

<deftest test-gensym-format
	[gensym returns a 6-char symbol whose first char is G]
	(setq g (gensym))
	(assert 6 (length (unpack g)))
	(assert 71 (ascii (car (unpack g))))>

<deftest test-unpack-length
	[unpack returns a list of single-char symbols, one per char]
	(assert 4 (length (unpack 'abcd)))
	(assert 1 (length (unpack 'x)))
	(assert 5 (length (unpack 'hello)))>

<deftest test-unpack-ascii
	[first char of unpack matches the ASCII value]
	(assert 97 (ascii (car (unpack 'abcd))))
	(assert 98 (ascii (car (cdr (unpack 'abcd))))) [second char = b]>

<deftest test-pack-roundtrip
	[pack-then-intern produces a symbol equal to the literal]
	(assert 'abc (intern (pack '(a b c))))
	(assert 'foo (intern (pack '(f o o))))>

<deftest test-ascii
	(assert 65 (ascii 'A))
	(assert 97 (ascii 'a))
	[for multi-char symbols, returns the FIRST char's ASCII value]
	(assert 97 (ascii 'abcd))>

<deftest test-char-roundtrip
	[char then ascii returns the same byte]
	(assert 65 (ascii (char 65)))
	(assert 97 (ascii (char 97)))
	(assert 90 (ascii (char 90)))
	[interning a char output gives the literal symbol]
	(assert 'A (intern (char 65)))>

<deftest test-intern
	[interning twice returns the same (eq) symbol]
	(setq i1 (intern (pack '(t s i n t e r n))))
	(setq i2 (intern (pack '(t s i n t e r n))))
	(assert t (eq i1 i2))>

<deftest test-oblist
	[oblist returns a non-empty list of all interned symbols]
	(assert t (pairp (oblist)))
	[a known primitive must be present]
	(assert t (if (memq 'car (oblist)) t nil))>

<deftest test-put-get
	(put 'tspsym 'color 'red)
	(assert 'red (get 'tspsym 'color))
	[updating a property]
	(put 'tspsym 'color 'blue)
	(assert 'blue (get 'tspsym 'color))
	[different properties on same symbol]
	(put 'tspsym 'size 'large)
	(assert 'blue (get 'tspsym 'color))
	(assert 'large (get 'tspsym 'size))>

<deftest test-get-missing
	[get on a property that was never set returns nil]
	(assert nil (get 'tspsym2 'never-set))>

<deftest test-getpl-putpl
	[setting a fresh property list, then reading it back]
	(putpl 'tspsym3 '(a 1 b 2))
	(assert '(a 1 b 2) (getpl 'tspsym3))>

<deftest test-remob
	[remob removes a fresh symbol from the oblist]
	(setq tsr (intern (pack '(r e m t e s t))))
	(assert tsr (car (memq tsr (oblist))))
	(remob tsr)
	(assert nil (memq tsr (oblist)))>

<deftest test-remob-protected
	[protected symbols silently no-op; they stay in the oblist]
	(remob 't) (assert t (boundp 't))
	(remob 'quote) (assert t (eq 'a (quote a)))>
