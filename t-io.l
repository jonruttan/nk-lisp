[T-IO.L - file I/O round-trips.  See nkl-test.md.]
[after-each era's the test file so a mid-test failure doesn't leak.]

<after-each (era '(tio dat))>

<deftest test-create-write-read-bytes
	(create '(tio dat) 1)
	(putc 65 1)
	(putc 66 1)
	(putc 67 1)
	(close 1)
	(open '(tio dat) 1)
	(assert 65 (getc 1))
	(assert 66 (getc 1))
	(assert 67 (getc 1))
	(close 1)>

<deftest test-prin1-read-roundtrip
	(create '(tio dat) 1)
	(prin1 'hello 1) (sp 1)
	(prin1 '(a b c) 1) (sp 1)
	(prin1 42 1)
	(close 1)
	(open '(tio dat) 1)
	(assert 'hello (read 1))
	(assert '(a b c) (read 1))
	(assert 42 (read 1))
	(close 1)>

<deftest test-eofp-fresh
	[CP/M tracks file size in 128-byte records, not bytes; eofp
	can only fire when getc crosses into an unwritten record.]
	(create '(tio dat) 1)
	(do i 0 (lessp i 128) (1+ i) (putc 65 1))
	(close 1)
	(open '(tio dat) 1)
	(assert nil (eofp 1))
	(do i 0 (lessp i 128) (1+ i) (getc 1))
	(assert nil (eofp 1))
	(getc 1)		[crosses into unwritten record 1, trips eofp]
	(assert t (eofp 1))
	(close 1)>

<deftest test-seek-where
	(create '(tio dat) 1)
	(putc 65 1) (putc 66 1) (putc 67 1) (putc 68 1)
	(close 1)
	(open '(tio dat) 1)
	(getc 1) (getc 1)
	(assert 2 (where 1))
	(seek 0 1)
	(assert 0 (where 1))
	(assert 65 (getc 1))
	(close 1)>

<deftest test-create-truncates
	(create '(tio dat) 1)
	(putc 65 1) (putc 66 1) (putc 67 1)
	(close 1)
	(create '(tio dat) 1)
	(putc 90 1)
	(close 1)
	(open '(tio dat) 1)
	(assert 90 (getc 1))
	(close 1)>

<deftest test-open-nonexistent
	(assert-err (open '(no-such file) 1))>

<deftest test-getc-bad-channel
	(assert-err (getc 9))>

<deftest test-print-vs-prin1
	[print is prin1 + CRLF (13 10)]
	(create '(tio dat) 1)
	(print 'X 1)
	(close 1)
	(open '(tio dat) 1)
	(assert 88 (getc 1))		[X]
	(assert 13 (getc 1))		[CR]
	(assert 10 (getc 1))		[LF]
	(close 1)>

<deftest test-cr-writes-crlf
	(create '(tio dat) 1)
	(cr 1)
	(close 1)
	(open '(tio dat) 1)
	(assert 13 (getc 1))
	(assert 10 (getc 1))
	(close 1)>

[(read 1) past EOF returns nil but leaves the global NXTCHR
lookahead set to EOFCHR, which leaks across (close 1) and
terminates the next spec's (revalo) prematurely.  Held pending
until the interpreter resets parser state on close.]
<pending test-read-eof>

[(in 'file) sets LDFLG and opens the default file FCB, but the
load itself only fires at the *next* top-level REVALO entry -
not synchronously.  Inside a deftest body we're nested inside
load-spec's (revalo 1), so the flag never takes effect during
the test.  (key) reads from the console and has no scripted-
input redirect.  Both need interpreter changes to be testable.]
<pending test-in-redirect>
<pending test-key>

