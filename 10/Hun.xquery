xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

(:This query will give back all the Hungarian athletes(grouped by their names), 
and their results grouped into G,S,B arrays. :)

let $file := fn:json-doc("../results.json")

let $athletes := $file?*?games?*?results?*

let $HunAthletes := 
  for $athlete in $athletes
  where $athlete("nationality") = "HUN" and not(empty( $athlete("name")))
  group by $name := $athlete("name") 
  return map {
    "name" : $name,
    "medals" : map {
      "S" : array {
        for $athlete in $athletes
        where $athlete("name") = $name and $athlete("medal") = "S"
        return map{
            "result": $athlete("result"),
            "medal": "Silver"
        }
      },
      "G" : array {
        for $athlete in $athletes
        where $athlete("name") = $name and $athlete("medal") = "G"
        return map{
            "result": $athlete("result"),
            "medal": "Gold"
        }
      },
      "B" : array {
        for $athlete in $athletes
        where  $athlete("name") = $name and $athlete("medal") = "B"
        return map{
            "result": $athlete("result"),
            "medal": "Bronze"
        }
      }
    }
  }

return array{$HunAthletes}
