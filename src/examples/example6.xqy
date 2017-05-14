xquery version "1.0-ml";

(: Custom XQuery color settings page
:)

declare namespace z="zisisanamespace";
declare namespace m="http://my.space";

import module namespace ex="urn:libexample" at "libexample.xqy";

declare variable $foobar as xs:string external;
declare variable $m:nsvar external;
declare variable $z:exter as xs:date external;

declare variable $blah := "This is a string";
declare variable $integer := 42;
declare variable $z:dec := 1000.42;
declare variable $z:now := fn:current-dateTime();
declare variable $node := <z:foo>bar</z:foo>;
declare variable $a-comment := <!-- This is an XML comment -->;
declare variable $a-pi := <?foo processing-instruction ?>;
declare variable $a-doc-node := document { <doc-root>Doc content<foo>blah</foo></doc-root> };
declare variable $an-attribute := attribute myattr { "attr-value" };
declare variable $another-attribute := <foo z:myattr="myattr-val"/>/@z:myattr;
declare variable $a-text-node := <foo>Some text</foo>/text();
declare variable $a-sequence := (1, 2, 3, 5, 8, 13, 21);
declare variable $a-node-sequence := (<foo>bleb</foo>, <blig/>, <florb>Bleem<flurg>schnib</flurg></florb>);
declare variable $a-boolean := fn:true();
declare variable $an-empty-seq := ();


declare function local:foo ($s as xs:string)
{
    let $now := fn:current-dateTime()
    let $then := current-dateTime()
    for $i in (1,2,3)
    let $now-date := xs:date ("2017-01-02")
    let $flag := fn:false()
    let $empty := ()
    let $local-node := <some-node>blah</some-node>
    let $some-text := text { "foobar" }

    return (fn:concat ($i, ": ", fn:lower-case ($s), " - ", $now))
};

(
    fn:current-dateTime(),(: xdmp:elapsed-time(),:)
    local:foo ("This is A Mixed Case String"),
    local:foo ("This is Another Mixed Case String")
    , ex:sample-function ("Yet Another Mixed Case String")
)
