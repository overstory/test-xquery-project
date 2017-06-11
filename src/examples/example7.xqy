xquery version "1.0-ml";

declare namespace z="zisisanamespace";
declare namespace m="http://my.space";
declare namespace libexample="urn:libexample";

xdmp:invoke ("/examples/example6.xqy",
        (
            xs:QName ("foobar"), "barfoo2",
            xs:QName ("m:nsvar"), "blabblabbab",
            xs:QName ("z:exter"), xs:date ("2014-03-17"),
            xs:QName ("libexample:foobar"), "lib foobar"
        )
)