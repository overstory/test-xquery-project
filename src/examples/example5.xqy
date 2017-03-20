xquery version '1.0-ml';

(: Auto-complete
    Variables
      Type information and variable kind
      Only variables in scope are shown
    Functions
      Return type and parameter types
      Top-level list of library function categories
      Library functions (with type info) included
    Special auto-complete list following :=
:)

declare variable $hello as xs:string := "Hello World";
declare private variable $good-bye := fn:concat("cat", "dog");

declare private function local:func1() as xs:string
{
	typeswitch ($hello)
	case $c1 as xs:string return 1
	case $c2 as xs:integer return $c2
	default return 12
};

declare function local:big-func ($param as xs:string) as xs:double
{
	let $blah as xs:integer := 1
	for $forvar as xs:int at $index in (1 to 10), $for2 at $index2 in (1 to 10)
	for $forvar as xs:int at $index in $forvar, $for2 at $index2 in $for2
	let $foo := ($param, $blah)
	(: Only let vars in scope are seen, all global vars, functions (fn: special) :)
	let $bar := 1
	let $q := some $quant as xs:long in (1, 3, 5) satisfies if ($quant = 3) then () else $quant
	(: Library functions by category, with API info, autocomplete XQuery embedded in XML :)
	let $yy := 1

	return
	try {
		for $num in 1 to 10
		return $num
	} catch ($error) {
		let $x := 1
		return
		xdmp:log ($error)
	}
};

(local:func1())