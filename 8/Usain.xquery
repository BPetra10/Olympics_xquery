xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

(:
Returns all of Usain Bolt's olympic results, 
what year he ran in the olympics, where was the olympics, and what run events he participated.
:)

let $file := fn:json-doc("../results.json")

(:1:)
let $athletes := $file?*?games?*?results?*

let $BoltRun:= for $athlete in $athletes
where $athlete("name") = "Usain BOLT"
return map {
        "result":$athlete("result"),
        "medal": $athlete("medal")
        }

let $BoltRunRes := 
map{
    "results":array{$BoltRun}
}

(:2:)
let $BoltCompetition := 
    for $i in 1 to array:size($file)
    where $file($i)?games?*?results?*?name = "Usain BOLT"
    return ($file)($i)("name")

let $BoltCompTypes := 
    map{
    "run types": array{$BoltCompetition}
    }

(:3:)
let $getBoltGames := 
    for $i in 1 to array:size($file)
    where $file($i)("gender") = "M" and $file($i)?games?*?results?*?name = "Usain BOLT"
    return ($file)($i)("games")

let $BoltGamesArr := array{$getBoltGames}

let $PlacesAndYear := 
    for $i in 1 to array:size($BoltGamesArr)
        for $j in 1 to array:size($BoltGamesArr($i))
            let $res := $BoltGamesArr($i)($j)("results")
            let $Bolt := 
                for $k in 1 to array:size($res)
                    where $res($k)("name") = "Usain BOLT"
                    return map {
                         "year": $BoltGamesArr($i)($j)("year"),
                         "location": $BoltGamesArr($i)($j)("location")
                    }
            return $Bolt


let $years := for $value in fn:distinct-values($PlacesAndYear?year)
return  $value

let $BoltYears :=    
    map{
    "years": array{$years}
    }

let $places := for $value in fn:distinct-values($PlacesAndYear?location)
return  $value

let $BoltPlaces :=    
    map{
    "locations": array{$places}
    }

return array{$BoltRunRes, $BoltCompTypes, $BoltYears, $BoltPlaces}