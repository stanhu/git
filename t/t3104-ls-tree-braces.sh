#!/bin/sh

test_description='ls-tree with a folder with braces'

. ./test-lib.sh

test_expect_success 'setup' '
	mkdir -p "newdir/{{curly}}" &&
	touch "newdir/{{curly}}/one" &&
	git add "newdir/{{curly}}/one" &&
	git commit -m test
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

test_done
