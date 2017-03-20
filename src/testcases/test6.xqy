xquery version "1.0-ml";

module namespace entitlement = "entitlement";

import module namespace qcache="http://springer.com/xquery/libraries/cache/query" at "query-cache.xqy";

declare namespace meta = "http://www.springer.com/app/meta";

declare private variable $OPEN-ACCESS-MATERIAL-ID := "anonymous";

(: PUBLIC :)

declare function entitlement-query (
	$materials-json as xs:string?
) as cts:query?
{
	entitlement-query ($materials-json, fn:true())
};

declare function entitlement-query (
	$materials-json as xs:string?,
	$include-open-access as xs:boolean
) as cts:query?
{
    get-entitlement-query ($materials-json, $include-open-access)
};


declare function get-verticals (
	$materials-json as xs:string
) as xs:string*
{
	let $materials-map as map:map* := map-materials($materials-json)
	let $materials := get-materials(map:get($materials-map, "id"))

	for $vertical in $materials/descendant-or-self::cts:element-range-query[fn:ends-with(cts:element/fn:string(), ':Vertical')]
	return fn:distinct-values($vertical/cts:value)
};


declare function has-access (
	$uri as xs:string,
	$materials-json as xs:string?
) as xs:boolean
{
	fn:count(accessible-uris($uri, $materials-json)) eq 1
};


declare function accessible-uris (
	$uris as xs:string*,
	$materials-json as xs:string?
) as xs:string*
{
	cts:uris ((), ("document"), cts:and-query ((cts:document-query ($uris), get-entitlement-query ($materials-json, fn:true()))))
};


declare function can-access-document (
	$doc as document-node(),
	$material-id as xs:string
) as xs:boolean
{
	let $ids as xs:string* := get-document-material-ids-for-doc ($doc, $material-id)
	return ((fn:count ($ids) eq 1) and ($ids eq $material-id))
};


declare function get-document-material-ids-for-doc (
	$doc as document-node(),
	$candidate-ids as xs:string*
) as element(id)*
{
	xdmp:invoke ("/entitlements/get-material-ids-for-user.xqy",
		(xs:QName ("doc"), $doc/Publisher, xs:QName("id-list"), fn:string-join ($candidate-ids, ",")),
		<options xmlns="xdmp:eval">
		  <database>{xdmp:database("CasperEntitlements")}</database>
		</options>
	)
};

declare function get-document-materials-for-user (
	$doc as document-node(),
	$materials-json as xs:string
) as element(Id)*
{
	try {
		let $doc-date as xs:date := $doc//meta:Info/meta:Date
		let $materials-maps as map:map* := map-materials($materials-json)
		let $candidate-ids as xs:string* :=
			for $map in $materials-maps
			let $from := map:get ($map, "from")
			let $from-date := if ($from castable as xs:date) then xs:date ($from) else xs:date ("0001-01-01")
			let $to := map:get ($map, "to")
			let $to-date := if ($to castable as xs:date) then xs:date ($to) else xs:date ("9999-12-31")
			where (($doc-date ge $from-date) and ($doc-date le $to-date))
			return map:get ($map, "id")

		for $id in get-document-material-ids-for-doc ($doc, $candidate-ids)
		return element { "Id" } { $id/node() }
	} catch ($e) {
		()   (: Probably here because doc doesn't have a meta:Date element :)
	}
};


(: PRIVATE :)

declare private function get-entitlement-query (
	$materials-json as xs:string?,
	$include-open-content as xs:boolean
) as cts:query?
{
	let $cached-query as cts:query? := qcache:cached-query (materials-query-key ($materials-json, $include-open-content))
	return
	if (fn:exists ($cached-query))
	then $cached-query
	else qcache:register-and-cache-query (
		materials-query-key ($materials-json, $include-open-content),
		get-materials-query ($materials-json, $include-open-content))
};

declare private function materials-query-key (
	$materials-json as xs:string?,
	$include-open-content as xs:boolean
) as xs:string
{
	fn:string (xdmp:hash64 (fn:concat ($materials-json, $include-open-content)))
};


declare private function get-materials-query (
	$materials-json as xs:string?,
	$include-open-access as xs:boolean
) as cts:query?
{
	let $materials-map as map:map* := map-materials ($materials-json)
	let $material-ids := (
		map:get ($materials-map, "id"),
		if ($include-open-access) then $OPEN-ACCESS-MATERIAL-ID else ()
	)
	let $stored-materials-map as map:map := map:map()
	let $_ := for $m in get-materials ($material-ids) return map:put ($stored-materials-map, $m/id/fn:string(), $m)

	let $material-queries := (
		for $material in $materials-map
		let $id := map:get ($material, "id")
		let $from := map:get ($material, "from")
		let $to := map:get ($material, "to")
		let $material-query := map:get ($stored-materials-map, $id)/query/element()
		where material-exists($id, $material-query)
		return
			cts:and-query ((
				cts:query ($material-query),
				if ($from castable as xs:date) then cts:element-range-query(xs:QName("meta:Date"), ">", xs:date($from)) else (),
				if ($to castable as xs:date) then cts:element-range-query(xs:QName("meta:Date"), "<=", xs:date($to)) else ()
			))
		,
		let $anon-query as element()? := map:get ($stored-materials-map, $OPEN-ACCESS-MATERIAL-ID)/query/element()
		where fn:exists($anon-query)
		return cts:query($anon-query)
	)
	let $final-query := if (fn:count ($material-queries) eq 1) then $material-queries else cts:or-query ($material-queries)

	return $final-query
};


declare private function material-exists (
	$material-id as xs:string,
	$query as element()?
) as xs:boolean
{
	if (fn:exists($query)) then fn:true()
	else (
		xdmp:log(fn:concat("Material id not found: ", $material-id)),
		fn:false()
	)
};


declare private function get-materials (
	$material-ids as xs:string+
) as element(material)*
{
	xdmp:invoke ("/entitlements/get-materials.xqy",
		(xs:QName ("ids"), fn:string-join($material-ids, ",")),
		<options xmlns="xdmp:eval">
		    <database>{xdmp:database("CasperEntitlements")}</database>
		</options>
	)
};


declare private function map-materials (
	$materials-json as xs:string?
) as map:map*
{
	if (fn:exists ($materials-json) and fn:string-length ($materials-json) gt 1)
	then map:get (xdmp:from-json ($materials-json), "materials")
	else ()
};
