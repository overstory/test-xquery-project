xquery version "1.0-ml";

module namespace snippet='http://springer.com/xquery/libraries/search/snippet';

declare private variable $para-cts-search-options as xs:string* := ("filtered", "score-simple", "checked");

declare private variable $nodes-to-filter as xs:string* := 'IndexTerm';

declare private variable $MAX-SNIPPET-CHARS as xs:positiveInteger := 212;
declare private variable $PER-MATCH-TOKENS as xs:positiveInteger := 30;

(: ---------------------------------------------------------- :)
(: Still ToDo:
	Need to "phrase-through" inline markup (foo <b>bar</b> blah <highlight>blech</highlight> snurg)
	Account for spaces and punctuation better when snipping
	Limit overall length of context surrounding highlight rather than just token count
	Distribute $PER-MATCH-TOKENS asymetrically on either side of highlight, if needed
	Step through <highlight>s, looking at text/content on either side rather than doing sequential pinhole scan
:)
(: ---------------------------------------------------------- :)

declare function snippet (
	$result as node(),
	$snippet-query as cts:query
) as element(Snippet)
{
	let $uri as xs:string := xdmp:node-uri ($result)
	let $para as element(Para)? := select-best-para ($uri, $snippet-query)
	let $highlighted-para as element(Para)? := highlight-para ($para, $snippet-query)
	let $match as element(match)? := extract-match ($highlighted-para)

	return
	<Snippet>{ $match }</Snippet>
};

(: ---------------------------------------------------------- :)

declare private function extract-match (
	$para as element(Para)
) as element(match)*
{
	<match>{
		truncate-match (extract-snippets ($para/node()), 0)
	}</match>
};

declare function foo()
{
	typeswitch ($nodes [1])
	case $highlight as element(highlight) return $highlight
	case $el as element() return $el
	case $txt as text() return
		if ((fn:string-length ($txt) + $so-far) > $MAX-SNIPPET-CHARS)
		then "foo"
		else $txt
	default return $nodes [1]  (: "shouldn't happen" :)

};

declare private function truncate-match (
	$nodes as node()*,
	$so-far as xs:nonNegativeInteger
) as node()*
{
	if (fn:empty ($nodes) or ($so-far >= $MAX-SNIPPET-CHARS))
	then ()
	else
		let $this-node as node() :=
			typeswitch ($nodes [1])
			case $highlight as element(highlight) return $highlight
			case $element as element() return
				element { fn:name ($element) }
				{
					$element/namespace::*,
					$element/@*,
					truncate-match ($element/node(), $so-far)
				}
			case $text as text() return
				if ((fn:string-length ($text) + $so-far) > $MAX-SNIPPET-CHARS)
				then text { fn:concat (fn:substring ($text, 1, ($MAX-SNIPPET-CHARS - $so-far)), "...") }
				else $text
			default return $nodes [1]  (: "shouldn't happen" :)
		return ($this-node, truncate-match (fn:subsequence ($nodes, 2), $so-far + fn:string-length (fn:string ($this-node))))
};

declare private function extract-snippets (
	$nodes as node()*
) as node()*
{
	let $nodes as node()* := $nodes
	for $node at $pos in $nodes
	return
	typeswitch ($node)
	case text() return format-text ($node, ($nodes[$pos - 1]) instance of element(highlight), ($nodes[$pos + 1]) instance of element(highlight))
	case $element as element(highlight) return $element
	case $element as element() return
	(
		element { fn:name ($element) }
		{
			$element/namespace::*,
			$element/@*,
			extract-snippets ($element/node())
		}
	)
	default return $node
};

declare private function format-text (
	$text-node as text(),
	$highlight-before as xs:boolean,
	$highlight-after as xs:boolean
) as item()*
{
	if (fn:not ($highlight-before) and fn:not ($highlight-after))
	then
	 	if (fn:string-length ($text-node) > $MAX-SNIPPET-CHARS)
	 	then text { fn:concat (fn:substring ($text-node, 1, ($MAX-SNIPPET-CHARS - 3)), "...") }
	 	else $text-node
	else truncate-text ($text-node, $highlight-before, $highlight-after)
};

declare private function truncate-text (
	$text-node as text(),
	$highlight-before as xs:boolean,
	$highlight-after as xs:boolean
) as text()
{
	let $both as xs:boolean := $highlight-before and $highlight-after
	let $tokens as cts:token* := cts:tokenize($text-node)
	let $max-tokens as xs:nonNegativeInteger := $PER-MATCH-TOKENS idiv 2
	let $count as xs:nonNegativeInteger := fn:count($tokens)
	let $first as xs:nonNegativeInteger := fn:max ((($max-tokens - $count), 1))
	let $truncated-tokens :=
		if ($count <= $max-tokens)
		then $tokens
		else
		if ($both)
		then
			if ($count > $PER-MATCH-TOKENS)
			then (
				$tokens[1 to $max-tokens],
				if ($tokens[$max-tokens] instance of cts:space) then () else cts:space(" "),
				cts:punctuation("..."),
				if ($tokens[$count - $max-tokens] instance of cts:space) then () else cts:space(" "),
				$tokens[($count - $max-tokens) to $count]
			) else $tokens
		else
		if ($highlight-before)
		then (
			trim-bounding-space ($tokens[1 to $max-tokens], fn:false(), $count > $max-tokens),
			if ($count > $max-tokens) then cts:punctuation("...") else ()
		) else (
			if (($count > $max-tokens) and fn:not (fn:matches ($tokens[$first], "^[A-Z]"))) then cts:punctuation("...") else (),
			trim-bounding-space ($tokens[$first to $count], $count > $max-tokens, fn:false())
		)

	return text { fn:string-join ($truncated-tokens, "") }
};

declare private function trim-bounding-space (
	$tokens as cts:token*,
	$left as xs:boolean,
	$right as xs:boolean
) as cts:token*
{
	let $count := fn:count ($tokens)
	let $tokens := if ($right and ($tokens[$count] instance of cts:space)) then $tokens[1 to ($count - 1)] else $tokens
	let $tokens :=  if ($left and ($tokens[1] instance of cts:space)) then $tokens[2 to $count] else $tokens

	return $tokens
};

(: Careful: This function depends on function mapping.  It will not be invoked if $para = () :)
declare private function highlight-para (
	$para as element(Para),
	$snippet-query as cts:query?
) as element(Para)
{
	let $highlighted-para as element(Para)* :=
		if (fn:exists ($snippet-query))
		then cts:highlight ($para, $snippet-query, <highlight>{$cts:text}</highlight>)
		else $para
	let $highlighted-para :=
		if ($highlighted-para/highlight)
		then $highlighted-para
		else
			if ($highlighted-para//Para[highlight])
			then ($highlighted-para//Para[highlight])[1]
			else $highlighted-para

	return if (fn:exists ($highlighted-para)) then $highlighted-para else $para
};

declare private function select-best-para (
	$uri as xs:string,
	$snippet-query as cts:query
) as element(Para)?
{
	let $para as element(Para)? := cts:search (fn:doc($uri)//Abstract//Para, $snippet-query, $para-cts-search-options)[1]
	let $para as element(Para)? := if (fn:exists ($para)) then $para else cts:search (fn:doc($uri)//Body//Para, $snippet-query, $para-cts-search-options)[1]
	let $para as element(Para)? := if (fn:exists ($para)) then $para else (fn:doc($uri)//Abstract//Para)[1]

	return if (has-filterable-nodes ($para)) then filter-nodes ($para) else $para
};

declare private function filter-nodes ($node as node()?) as node()?
{
	if (fn:name ($node) = $nodes-to-filter)
	then ()
	else
	element { fn:name ($node) } {
		$node/namespace::*,
		$node/@*,
		for $n in $node/node()
		return
		if ($n instance of text())
		then fn:replace ($n, "\s+", " ")  (: don't use fn:normalize-space, that will trim leading/trailing space which is problematic for inline markup :)
		else filter-nodes ($n)
	}
};

declare private function has-filterable-nodes ($node as node()?) as xs:boolean
{
	if (fn:name ($node) = $nodes-to-filter)
	then fn:true()
	else fn:boolean ($node/element()/has-filterable-nodes(.))
};
