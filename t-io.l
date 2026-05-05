[T-IO.L - file I/O round-trips.  See nkl-test.md.]
[after-each era's the test file so a mid-test failure doesn't leak.]

<after-each (era '(tio dat))>

<deftest test-create-write-read-bytes
	[round-trip: create file, write three bytes, close, reopen, read back]
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
	(getc 1)            [crosses into record 1 - unwritten]
	(assert t (eofp 1))
	(close 1)>

<deftest test-seek-where
	[where reports the file pointer; seek positions it]
	(create '(tio dat) 1)
	(putc 65 1) (putc 66 1) (putc 67 1) (putc 68 1)
	(close 1)
	(open '(tio dat) 1)
	(getc 1)               [advance past A]
	(getc 1)               [advance past B]
	(assert 2 (where 1))
	(seek 0 1)             [back to start]
	(assert 0 (where 1))
	(assert 65 (getc 1))   [reads A again]
	(close 1)>

<deftest test-create-truncates
	[create overwrites any existing file with the same name]
	(create '(tio dat) 1)
	(putc 65 1) (putc 66 1) (putc 67 1)
	(close 1)
	[recreate - should wipe out the existing content]
	(create '(tio dat) 1)
	(putc 90 1)
	(close 1)
	(open '(tio dat) 1)
	(assert 90 (getc 1))   [first byte is the new content]
	(close 1)>

<deftest test-open-nonexistent
	[opening a file that doesn't exist raises an error]
	(assert-err (open '(no-such file) 1))>

<deftest test-getc-bad-channel
	[reading from a channel that isn't open raises an error]
	(assert-err (getc 9))>
