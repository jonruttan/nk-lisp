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
