#!/bin/sh

test_description='ls-tree with folders with brackets'

. ./test-lib.sh

test_expect_success 'setup' '
	mkdir -p "newdir/{{curly}}" &&
	mkdir -p "newdir/^{tree}" &&
	touch "newdir/{{curly}}/one" &&
	touch "newdir/^{tree}/two" &&
	git add "newdir/{{curly}}/one" &&
	git add "newdir/^{tree}/two" &&
	git commit -m "Test message: search me"
'

test_expect_success 'ls-tree with curly brace folder' '
	cat >expect <<-EOF &&
	100644 blob $EMPTY_BLOB	one
	EOF
	git ls-tree -r "HEAD:newdir/{{curly}}" >actual &&
	test_cmp expect actual
'

test_expect_success 'ls-tree with type restriction and curly brace folder' '
	cat >expect <<-EOF &&
	100644 blob $EMPTY_BLOB	one
	EOF
	git ls-tree "HEAD^{tree}:newdir/{{curly}}" >actual &&
	test_cmp expect actual
'

test_expect_success 'ls-tree with type restriction and folder named ^{tree}' '
	cat >expect <<-EOF &&
	100644 blob $EMPTY_BLOB	two
	EOF
	git ls-tree "HEAD^{tree}:newdir/^{tree}" >actual &&
	test_cmp expect actual
'

test_expect_success 'ls-tree with unknown type restriction' '
	(git ls-tree HEAD^{foobar} >actual || true) &&
	test_must_be_empty actual
'

test_output () {
	sed -e "s/ $OID_REGEX	/ X	/" <actual >check
	test_cmp expect check
}

test_expect_success 'ls-tree with regex' '
	cat >expect <<-EOF &&
	040000 tree X	newdir
	EOF
	git ls-tree "HEAD^{/message}" >actual &&
	test_output
'

test_expect_success 'ls-tree with regex with a colon' '
	cat >expect <<-EOF &&
	040000 tree X	newdir
	EOF
	git ls-tree "HEAD^{/message: search}" >actual &&
	test_output
'

test_expect_success 'ls-tree with regex and curly brace folder' '
	cat >expect <<-EOF &&
	100644 blob $EMPTY_BLOB	one
	EOF
	git ls-tree "HEAD^{/message: search}:newdir/{{curly}}" >actual &&
	test_cmp expect actual
'

test_done
