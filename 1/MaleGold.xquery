xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

(:
This query will give back all the male gold medalists, if the result is not null.
And if the athlete name is empty, that means that it was a team event (like relay).
:)

let $file := fn:json-doc("../results.json")

let $getAllMaleGames := 
    for $i in 1 to array:size($file)
    where $file($i)("gender") = "M"
    return ($file)($i)("games")

let $getAllMaleGamesArr := array{$getAllMaleGames}

let $competitionName := 
    for $i in 1 to array:size($file)
    where $file($i)("gender") = "M"
    return ($file)($i)("name")

let $competitionNameArr := array{$competitionName}

let $GamesAndName := 
    for $i in 1 to array:size($getAllMaleGamesArr)
        let $competition := $competitionNameArr($i)
        for $j in 1 to array:size($getAllMaleGamesArr($i))
            let $res := $getAllMaleGamesArr($i)($j)("results")
            let $resGold := 
                for $k in 1 to array:size($res)
                    where $res($k)("medal") = "G"
                    and not(empty($res($k)("result")))
                    return map {
                        "name": 
                            if (empty($res($k)("name"))) 
                            then "Team event"  
                            else $res($k)("name"),
                         "res": $res($k)("result"),
                        "game_name": $competition
                    }
            return $resGold

return array{$GamesAndName}


