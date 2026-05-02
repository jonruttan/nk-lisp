[T-IO.L - file I/O round-trips]
[Covers create, open, close, getc, putc, read, prin1, seek, where, eofp, era.]
[Each test creates a file, exercises some operation, then erases it.]
[Uses channel 1 (free during test execution; loadSpec opens/closes it]
[only during spec load).]

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
    (close 1)
    (era '(tio dat))>

<deftest test-prin1-read-roundtrip
    [round-trip Lisp expressions through the file system]
    (create '(tio dat) 1)
    (prin1 'hello 1)
    (sp 1)
    (prin1 '(a b c) 1)
    (sp 1)
    (prin1 42 1)
    (close 1)
    (open '(tio dat) 1)
    (assert 'hello (read 1))
    (assert '(a b c) (read 1))
    (assert 42 (read 1))
    (close 1)
    (era '(tio dat))>

<deftest test-eofp-fresh
    [a fresh file isn't at EOF until something has read past the end]
    (create '(tio dat) 1)
    (putc 88 1)
    (close 1)
    (open '(tio dat) 1)
    (assert nil (eofp 1))
    (assert 88 (getc 1))
    (close 1)
    (era '(tio dat))>

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
    (close 1)
    (era '(tio dat))>

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
    (close 1)
    (era '(tio dat))>

t
