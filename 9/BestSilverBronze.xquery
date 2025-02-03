xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

(:
This query will give back the best silver and bronze medalists, who never won gold.
If the athelte is a silver medalist the best one will be with the highest silver count, 
but if there is a tie, the bronze medals will count too.
The best bronze medalist will be the one, who has the most bronze medals 
(who does not have gold and silver medal either.) 
:)

let $file := fn:json-doc("../results.json")

let $athletes := $file?*?games?*?results?*


let $distinctAthletes := 
  for $athlete in $athletes
  return $athlete?name

let $uniqueAthletes := distinct-values($distinctAthletes)


let $aggregatedResults := 
  for $athleteName in $uniqueAthletes
  let $silverCount := count($athletes[?name = $athleteName and ?medal = "S"])
  let $bronzeCount := count($athletes[?name = $athleteName and ?medal = "B"])
  let $goldCount := count($athletes[?name = $athleteName and ?medal = "G"])
  where $goldCount = 0 
  return map {
    "athlete": $athleteName,
    "silverCount": $silverCount,
    "bronzeCount": $bronzeCount,
    "goldCount": $goldCount
  }


let $bestSilver := 
  for $result in $aggregatedResults
  where $result?silverCount > 0 
  order by $result?silverCount descending, $result?bronzeCount descending
  return $result

let $bestSilverMedalist := head($bestSilver)


let $bestBronze := 
  for $result in $aggregatedResults
  where $result?bronzeCount > 0 
    and $result?silverCount = 0 
  order by $result?bronzeCount descending
  return $result

let $bestBronzeMedalist := head($bestBronze)

return array{
  $bestSilverMedalist,
  $bestBronzeMedalist
}
