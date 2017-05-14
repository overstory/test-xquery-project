xquery version '1.0-ml';

(: Error highlights
    Duplicate variables and functions
      Warn about dupe function name with different arity
    Unknown function
    Wrong number of arguments
    Annotate library function calls with API information
:)

module namespace foo="xyzzy";

declare variable $foo := bogus-function();
declare variable $foo := fn:concat();

declare function dupe-func() { 1 };
declare function dupe-func() { 2 };

declare function my-func ($arg1) { 1 };
declare function my-func ($arg1, $arg2) { 2 };

declare private function unused-private() {
	cts:search (fn:doc(), cts:and-query (())),
	dbg:invoke (),
	xdmp:user-roles (),
	xdmp:to-json(),
	xdmp:database-backup-status(),
	xdmp:zip-create()
};

declare function unused-public() {
	cts:search (fn:doc(), cts:and-query (()))
};

declare function call-my-func2()
{
	my-func (1, 2)
};

