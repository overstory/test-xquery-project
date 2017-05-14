xquery version '1.0-ml';

(: Jump to declaration / find usages
   Variables - prolog, let and parameters
   Functions
   Rename variables - only those in scope
   Rename functions - localname and/or prefix
 :)

declare variable $foo := 123.45;
declare variable $bar := 1.0e+5;
declare variable $foobar := 42;

declare function local:sqr ($number as xs:decimal) as xs:decimal
{
	$number * $number
};

let $baz := $foo + $bar

return $baz + local:sqr ($foo) + $foobar

