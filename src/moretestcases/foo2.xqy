xquery version '1.0-ml';

module namespace foob='http://springer.com/xquery/libraries/search/foo';

declare namespace snurg="http://snurg.com";

(:
       ron@overstory.co.uk

       Contact me if you want to help with this project
:)

(: This is a simple comment (: nested comment :)  :)

(# qname this is a pragma #)

declare variable $hello as xs:string := ('Hello world');
declare private variable $good-bye := <hello>goodbye</hello>;
(: declare variable $toodles := <ta-ta bye="now"/>; :)
declare variable $fare_well := 'toodles';

declare variable $an-int := 42;
declare variable $a-decimal := 142.37;
declare variable $a-double := 1.0e+5;
declare variable $silly-string as xs:string := 'This string hasn''t a clue';
declare variable $blech := 1

declare variable $some-cdata :=
	<foo>
		<![CDATA[
			<some>literal content here</some>
		]]>
	</foo>;


declare variable $pi := <?foo bar?>;
declare variable $xml-with-comment :=
     <foo xx="yy">
        <!-- this is an xml comment -->
	<?target This is a processing instruction ?>
        Some content
        <an-element>blah</an-element>
        <an-empty-element attr="foo"/>
        <element-with-curlies>this is {{so}} cool</element-with-curlies>
     </foo>;

declare variable $snurg:foo := $pi;

declare function local:myfunc ($arg1 as xs:integer, $arg2 as element(foo)*)
    as empty-sequence()
{
    fn:current-dateTime()
};

($hello, $good-bye, $fare_well, local:myfunc())[1]
