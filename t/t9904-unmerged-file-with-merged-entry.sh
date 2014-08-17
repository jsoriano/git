#!/bin/sh

test_description='Operations with unmerged file with merged entry'

. ./test-lib.sh

setup_repository() {
	test_commit A conflict A
	test_commit A conflict2 A2 branchbase
	test_commit B conflict B
	test_commit B conflict2 B2
	git checkout branchbase -b branch1
	test_commit C conflict C
	test_commit C conflict2 C2
	test_commit something otherfile otherfile
}

setup_stage_state() {
	git checkout -f HEAD
	{
		git ls-files -s conflict conflict2
		git merge master > /dev/null
		git ls-files -s conflict conflict2
	} > index
	cat index | git update-index --index-info 
	rm index
}

test_expect_success 'setup - two branches with conflicting file' '
	setup_repository &&
	setup_stage_state &&
	git ls-files -s conflict > output &&
	test_line_count = 4 output &&
	git ls-files -s conflict2 > output &&
	test_line_count = 4 output &&
	rm output
'

test_expect_success 'git commit -a' '
	setup_stage_state &&
	test_must_fail git commit -a
'

test_expect_success 'git add conflict' '
	setup_stage_state &&
	test_must_fail git add conflict
'

test_expect_success 'git rm conflict' '
	setup_stage_state &&
	test_must_fail git rm conflict
'

test_expect_success 'git add otherfile' '
	setup_stage_state &&
	>otherfile &&
	git add otherfile	
'

test_expect_success 'git rm otherfile' '
	setup_stage_state &&
	git rm otherfile
'

test_expect_success 'git add newfile' '
	setup_stage_state &&
	>empty &&
	git add empty	
'

test_expect_success 'git merge branch' '
	setup_stage_state &&
	test_must_fail git merge master
'

test_expect_success 'git reset --hard' '
	setup_stage_state &&
	git reset --hard
'

test_done
