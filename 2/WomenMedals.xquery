xquery version "3.1";

import schema default element namespace "" at "WomenMedals.xsd";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

(:
    This query will count how many times women won a medal,     
    regardless of whether it is gold, silver, or bronze.
    And it will transform the names to look like this: Almaz Ayana
    So every name starts with the capital letter, and the rest of the name is lowercase.
:)

declare function local:capitalLetter($input as xs:string) as xs:string {
    string-join(
        for $word in tokenize($input, '\s+')
        return concat(
            upper-case(substring($word, 1, 1)), 
            lower-case(substring($word, 2))
        ), 
        " "
    )
};

let $file := fn:json-doc("../results.json")

let $getAllWomenNames := 
    fn:distinct-values(
    for $i in 1 to array:size($file)
    where $file($i)("gender") = "W"
        for $j in 1 to array:size(($file)($i)("games"))
        let $name :=($file)($i)("games")($j)("results")?*?name
    return $name)

let $getWomenCount := 
for $name in $getAllWomenNames
    let $count := fn:count(
        for $i in 1 to array:size($file)
        where $file($i)("gender") = "W"
        for $game in $file($i)("games")
        for $result in $game?*?("results")
        where $result?*?("name") = $name
        return $result
    )
    return 
        <medalCounter>
            <name>{local:capitalLetter($name)}</name>
            <count>{$count}</count>
        </medalCounter>


return 
    validate {
        document {
            <womenMedals>
            {$getWomenCount}
            </womenMedals>
            }
       }

