xquery version "1.0-ml";

(:~
: User: ron
: Date: 5/8/17
: Time: 12:03 AM
: To change this template use File | Settings | File Templates.
:)

module namespace libexample = "urn:libexample";

(:declare variable $foobar as xs:string external;:)

declare variable $exlibvar := fn:current-date();

declare function sample-function ($str as xs:string)
{
    fn:concat ("Upper Case: ", fn:upper-case ($str))
};