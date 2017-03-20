xquery version "1.0-ml";

module namespace search-compat='http://springer.com/xquery/libraries/search/compat';

import module namespace search-lib = "http://springer.com/xquery/libraries/search/main" at "search-main.xqy";

declare namespace search='http://marklogic.com/appservices/search';


(: Transitional: Backward compatible function to translate response into existing schema expected by Core. :)
declare function search-compat (
	$request as element(search-request),
	$return-new-response as xs:boolean
) as element()
{
	if ($return-new-response)
	then search-lib:search ($request)
	else search ($request)
};


declare function estimate (
	$request as element(search-request)
) as xs:nonNegativeInteger
{
	search-lib:estimate ($request)
};

(: ---------------------------------------------------------- :)

declare private function search (
	$request as element(search-request)
) as element(search-data)
{
	let $result as element(search-response) := search-lib:search ($request)
	let $date-range := $result/primary-results/search-results/date-range

	return
	<search-data>{
		date-range-element ($result),
		main-search-results ($result, $request),
		teaser-element ($result),
		searching-within-result ($result)
	}</search-data>
};

declare private function facet-elements (
	$result as element(search-response)
) as element(search:facet)*
{
	for $facet in $result/facet-results/facet[@name ne "date"]
	return
	<search:facet>{
		$facet/@name,
		for $value in $facet/item
		return
		<search:facet-value>{
			attribute name { $value/@value/fn:string() },
			$value/@count,
			text { $value/@value/fn:string() }
		}</search:facet-value>
	}</search:facet>
	,
    let $date-min := $result/facet-results/facet[@name eq "date"]/@min/fn:string()
    let $date-max := $result/facet-results/facet[@name eq "date"]/@max/fn:string()
    where $date-min
    return (
        <search:facet name="earliestPublishedDate">{
            if ($date-min eq "") then ()
            else <search:facet-value name="{$date-min}" count="1">{$date-min}</search:facet-value>
        }</search:facet>,
        <search:facet name="latestPublishedDate">{
            if ($date-max eq "") then ()
            else <search:facet-value name="{$date-max}" count="1">{$date-max}</search:facet-value>
        }</search:facet>
	)

};

declare private function main-search-results (
	$result as element(search-response),
	$request as element(search-request)
) as element(search:response)
{
	let $primary as element(search-results)? := $result/primary-results/search-results
	return
	<search:response>{
		$primary/@total,
		attribute start { $request/start-index/fn:string() },
		attribute page-length { ($primary/@actual-count/fn:string(), 0)[1] },
		for $result in $primary/search-result
		return
			<search:result>{
				attribute index { $result/@index-in-page/fn:string() },
				$result/@score, $result/@confidence, $result/@fitness,
				convert-node ($result/element())   (: function mapping here :)
			}</search:result>,
		facet-elements ($result),
		<search:query>{$result/query/node()}</search:query>
	}</search:response>
};

declare private function convert-node (
	$node as node()
) as node()*
{
	typeswitch ($node)
	case element(Snippet) return <Snippet>{for $n in $node/node() return convert-node($n)}</Snippet>
	case element(match) return for $n in $node/node() return convert-node($n)
	case element(highlight) return <search:highlight>{for $n in $node/node() return convert-node($n)}</search:highlight>
	default return $node
};

declare private function teaser-element (
	$result as element(search-response)
) as element(teaser)?
{
	let $teaser as element(search-results)? := $result/teaser-results/search-results
	let $primary as element(search-results)? := $result/primary-results/search-results
	where fn:exists($teaser)
	return
		<teaser>
			<search:result index="1">{
				$teaser/search-result/@*,
				convert-node ($teaser/search-result/node())	(: function mapping here :)
			}</search:result>
			<total-results>{xs:nonNegativeInteger($primary/@total) + xs:nonNegativeInteger(($teaser/@total, 0)[1])}</total-results>
		</teaser>
};

declare private function searching-within-result (
	$result as element(search-response)
) as element(searching-within)?
{
	if (fn:exists ($result/searching-within-results))
	then
		<searching-within>
			<search:result>{
				convert-node ($result/searching-within-results/search-result/node())	(: function mapping here :)
			}</search:result>
		</searching-within>
	else ()
};

declare private function date-range-element (
	$result as element(search-response)
) as element(AvailableDocumentDateRange)?
{
	let $date-range := $result/primary-results/search-results/date-range
	where $result/primary-results/search-results/@total ne "0"
    return
        if ($date-range)
        then <AvailableDocumentDateRange start="{$date-range/@min}" end="{$date-range/@max}" dateRangeQueried="true"/>
        else
            let $date-facet := $result/facet-results/facet[@name eq "date"]
            return <AvailableDocumentDateRange start="{$date-facet/@min}" end="{$date-facet/@max}" dateRangeQueried="false"/>
};
