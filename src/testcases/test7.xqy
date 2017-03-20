xquery version "1.0-ml";

(:~
 : Fetch an item from the CitationTracker database, and annotate with
 : computed metadata for the item view in the webapp.
 :)

declare variable $doi as xs:string external;

(:
  Find the Percentile Rank for a citation count
  Uses the formula ( c(l) + 0.5 f(i) / N ) * 100%
  See: http://en.wikipedia.org/wiki/Percentile_rank
:)
declare function local:computePercentileRank($score as xs:unsignedLong) as xs:unsignedLong {

    (
      xdmp:estimate( /item[cited-by[@count < $score]] )
      +
      0.5 * xdmp:estimate( /item[cited-by[@count = $score]] )

    ) * 100 idiv xdmp:estimate( /item )

};

declare function local:annotateCitations($nodes as node()*) as node()* {
    for $node in $nodes
    return
      typeswitch($node)
        case text() return $node
        default
          return local:asis($node)
};


declare function local:asis($node as node()) as node() {
    element
      {fn:name($node)}
      {
        $node/attribute::*,
        local:passthru($node)
      }
};

declare function local:passthru($nodes as node()*) as node()* {
    for $node in $nodes/node()
    return
      local:annotateCitations($node)
};

(:~
 : Main Query Block
 :
 :)

(: return the item document, annotated with computed statistics :)
let $item := /item[@doi = $doi]

return
  if ($item) then (
              element item
                {
                  $item/attribute::*,
                  attribute percentile_rank { local:computePercentileRank($item/cited-by/@count) },
                  local:annotateCitations($item/node())
                }
     )
  else
    (element item{})




