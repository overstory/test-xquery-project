xquery version "1.0-ml";


declare namespace meta="http://www.springer.com/app/meta";
declare namespace search = "http://marklogic.com/appservices/search";
import module namespace content='content' at '/modules/content.xqy';
import module namespace config='config' at '/modules/config.xqy';

declare variable $term as xs:string := xdmp:get-request-field("query", "");
declare variable $page-length as xs:integer := xdmp:get-request-field("itemsPerPage", "20") cast as xs:integer;
declare variable $start-index as xs:integer := xdmp:get-request-field("start", "1") cast as xs:integer;
declare variable $show-all as xs:boolean := xdmp:get-request-field("showAll", "false") cast as xs:boolean;
declare variable $facet as xs:string := xdmp:get-request-field("facet", "no-facet-specified") cast as xs:string;

declare variable $facet-options as xs:string* := ( "frequency-order", "fragment-frequency", "collation=http://marklogic.com/collation/codepoint", "score-simple", "concurrent", "unchecked" );

let $start := $start-index
let $end := ($start-index + $page-length) - 1

let $search-options := config:search-options($show-all, fn:false(), (), ())

let $query :=
    cts:and-query((
        cts:query(config:parse-query($term, $search-options)),
        cts:query($search-options/search:additional-query/node())
    ))

let $facetElement := $search-options//search:constraint[@name=$facet]//search:element
let $facetQName := fn:QName($facetElement/@ns, $facetElement/@name)

let $total-docs := xdmp:estimate(cts:search(fn:collection("/collections/searchable"), $query))
let $items := cts:element-values ($facetQName, (), $facet-options, $query)
let $total-facets := fn:count ($items)
let $total-pages := ceiling ($total-facets div $page-length)

return
    <facet totalPages="{$total-pages}" totalDocuments="{$total-docs}" totalFacetValues="{$total-facets}">
    {
        for $item in $items[$start to $end]
        return <item count="{cts:frequency($item)}">{$item}</item>
    }
    </facet>

,xdmp:log(fn:concat("TIME ", xdmp:elapsed-time(), " facets.xqy ", $term, " ", $facet))