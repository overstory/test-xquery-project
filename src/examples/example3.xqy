xquery version '1.0-ml';

(: Warning highlights
    Unused variables and functions
      Sensitive to visibility
    Unknown XQuery verson string
:)

module namespace foo="xyzzy";

declare variable $unused-public := 1;
declare private variable $unused-private := 1;
declare private variable $used-private := 1;

declare function unused-public() { $used-private };

declare private function unused-private() { ($used-private) };

