xquery version '1.0-ml';

declare namespace blech="theblechnamespace";
declare namespace abc="xyz";

declare variable $hello as xs:string := "Hello World";
declare variable $fred := "sdfsd";
declare private variable $flib := fn:concat("cat", "dog");

declare private function flipper (
	$flob as element(flibber), $flim as xs:string
) as xs:string
{
	typeswitch ($hello)
	case $c1 as xs:string return 1
	case $c2 as xs:integer return $c2
	default return 12
};

declare variable $blech:foo := $fred;
declare variable $blech:bar := $blech:foo;

declare private function duh() { () };

declare function foob() { 1 };

declare function foob ($param as xs:string, $p1, $p2 as xs:boolean)
{
	let $blah as xs:integer := 1
	for $forvar as xs:int at $index in (1 to 10), $for2 at $index2 in (1 to 10)
	let $foo := ($param, $blah)
	let $dork := 1
	let $blink := some $quant as xs:long in (1, 3, 5) satisfies if ($quant = 3) then () else $quant
	let $yy := 1
	let $xml := <options xmlns='xdmp:eval'>
                    	<database>{xdmp:database("CitationTracker")}</database>
                    </options>

	(: FIXME: Fix let var seeing itself in scope :)
	(: ToDo: if var or func ref is entire variable expr, append semi-colon if in prolog :)

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

($hello, foob("xx", 1, 2), $blah, $bye, $flib, flipper(<flibber/>, 1), abc:flapper())

