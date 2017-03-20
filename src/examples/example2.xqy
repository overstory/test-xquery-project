xquery version '1.0-ml';

(: Syntax-sensitive pair highlighting
    Brackets, XML tags, CDATA, pragmas, PIs, etc
    (: Nested comments :)
   Auto comment / uncomment
:)

(#abc:pragma abc  #)

let $a := (1, 2, 3)[2]

let $b := <foo> <bar/>{ $a }</foo>

let $c := <foo><![CDATA[
               	  <some>literal content here</some>
               	]]></foo>

let $d := <foo><?foo xyz ?></foo>

return ()