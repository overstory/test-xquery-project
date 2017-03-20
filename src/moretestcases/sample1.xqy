xquery version '1.0-ml';

declare variable $search-options as xs:string* := ("unfiltered");


declare function search-me (
	$terms as xs:string,
	$options as xs:string*
) as xs:string
{
	cts:search (fn:doc(), cts:word-query ($terms), $options)
};

declare function search-me (
	$terms as xs:string
) as xs:string
{
	cts:search (fn:doc(), cts:word-query ($terms), $search-options)
};

xdmp:log ($search-options),
search-me ("foo")
