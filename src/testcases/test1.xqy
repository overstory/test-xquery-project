xquery version '1.0-ml';

declare namespace trgr="http://marklogic.com/xdmp/triggers";
declare namespace meta="meta-meta";

import module namespace gas="http://www.springer.com/generateartcilestub" at "/CitationTracker/modules/lib/generateartcilestub.xqy";
import module namespace gcs="http://www.springer.com/generatechapterstub" at "/CitationTracker/modules/lib/generatechapterstub.xqy";

declare variable $trgr:uri as xs:string external;
declare variable $trgr:trigger as node() external;


if (fn:contains($trgr:uri,'/content/PMC/'))
  then
     xdmp:log(concat("Following is PMC content: ", $trgr:uri))
  else
   if(fn:doc($trgr:uri)) then
    (
      let $pub := fn:doc($trgr:uri)/Publisher

      let $doi := $pub/meta:Info/meta:DOI/text()

      let $query := concat("/item[@doi = '",$doi,"']/cited-by")

      let $query-result := xdmp:eval($query,(),
                     <options xmlns="xdmp:eval">
                     <database>{xdmp:database("CitationTracker")}</database>
                     </options>)

      let $cited-by :=
         if($query-result/@count != 0)
           then  $query-result
           else <cited-by count="0" datetimeUpdated="{fn:current-dateTime()}"/>


      let $type := $pub/meta:Info/meta:Type/text()

      let $newstub :=
        if($type = "Article")
         then gas:getarticlestub($pub,$cited-by)
         else
          if($type = 'Chapter')
            then gcs:getchapterstub($pub,$cited-by)
          else ()

      let $collection :=
        if($type = 'Article')
         then '/content_type/journal_article'
         else
          if($type = 'Chapter')
            then '/content_type/book_chapter'
          else ()

      let $insertQuery :=
        concat("xquery version '1.0-ml';
        declare variable $stub as element() external;
        xdmp:document-insert(
    		      fn:concat( '/content/', xdmp:url-encode($stub/@doi) ),
    		      $stub,
    		      xdmp:default-permissions(),",
    		      fn:concat("'",$collection,"'"),
    	")" )

      let $result :=
        if ( $newstub/@doi and $newstub/@doi ne '' ) then
         (
           xdmp:eval(
            $insertQuery,
            (xs:QName("stub"), $newstub),
            <options xmlns="xdmp:eval">
        	  <database>{xdmp:database("CitationTracker")}</database>
        	</options>
           ),
           $trgr:uri
         )
        else
          xdmp:log(concat("Failed to create stub for URI: ", $trgr:uri))

      let $result-after-collections-update :=
           if (fn:contains($result, 'xml') ) then
               ( xdmp:document-add-collections($trgr:uri,'item-created'), $trgr:uri)
           else
               xdmp:log(concat("No collection updated for URI: ", $trgr:uri))
      return
        $result-after-collections-update
    )
   else
     xdmp:log(concat("Following Document can not be found: ", $trgr:uri))



