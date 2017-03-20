xquery version "1.0-ml";

declare namespace bstat = "com.springer.citationtracker.book.stat";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

declare variable $start as xs:integer external;
declare variable $pageLength as xs:integer external;
declare variable $sort as xs:string external;

let $qtext := concat("statscollection:book"," sort:", $sort)

(: Get breakdown of Books facet :)
let $book-response :=
  search:search($qtext,
    <options xmlns="http://marklogic.com/appservices/search">
        <constraint name="statscollection">
            <collection prefix="/stats/"/>
        </constraint>
        <search-option>unfiltered</search-option>
         <operator name="sort">
             <state name="mostcited">
                <sort-order type="xs:int" direction="descending">
                    <element ns="com.springer.citationtracker.book.stat" name="citation_count"/>
                </sort-order>
                 <sort-order type="xs:string" direction="ascending">
                    <element ns="com.springer.citationtracker.book.stat" name="volume_title"/>
                </sort-order>
             </state>
             <state name="name">
                <sort-order type="xs:string" direction="ascending">
                    <element ns="com.springer.citationtracker.book.stat" name="volume_title"/>
                </sort-order>
             </state>
         </operator>
    </options>,
    $start,
    $pageLength
  )

let $book-facet :=
  for $uri in $book-response/search:result/@uri
  let $doc := fn:doc($uri)/bstat:book
  return
    <search:facet-value freq="{$doc/bstat:citation_count}">{
      fn:normalize-space($doc/bstat:volume_title)
    }</search:facet-value>

return
  <search:facet name ="books">{
    $book-response/@*,
    $book-facet
  }</search:facet>

