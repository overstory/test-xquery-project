xquery version "1.0-ml";

declare namespace z="zisisanamespace";
declare namespace m="http://my.space";

import module namespace ex="urn:libexample" at "libexample.xqy";

declare variable $foobar as xs:string := xdmp:get-request-field ("foobar", "MISSING PARAM: foobar");
declare variable $m:nsvar := xdmp:get-request-field ("m:nsvar", "MISSING PARAM: m:nsvar");
declare variable $z:exter as xs:date := xdmp:get-request-field ("z:exter", "MISSING PARAM: z:exter") cast as xs:date;

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

    return fn:lower-case ($s) || " (" || $i || ")"
};

(
    fn:current-dateTime(),(: xdmp:elapsed-time(),:)
    local:foo ("This is A Mixed Case String"),
    local:foo ("This is Another Mixed Case String"),
    local:foo ("This is the value of $foobar: " || $foobar),
    <foo attr1="val1">Some text <i>italicized</i> and such</foo>,
    $an-attribute, $a-comment, $a-pi, $a-text-node, $another-attribute,
    $a-sequence, $an-empty-seq, $a-node-sequence, $a-doc-node, "MarkLogic version: " || xdmp:version()
    , ex:sample-function ("Yet Another Mixed Case String")
)
