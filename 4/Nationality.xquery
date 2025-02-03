xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

(: Grouping athletes by their nationality. :)

let $file := fn:json-doc("../results.json")

let $athletes := $file?*?games?*?results?*

let $groupedByNationality := 
  for $nationality in distinct-values(for $athlete in $athletes return $athlete?nationality)
  let $athletesForNationality := 
    for $athlete in $athletes
    where $athlete?nationality = $nationality
    return map {
      "name": if (empty($athlete?name)) then "team event" else $athlete?name,
      "nationality": $athlete?nationality,
      "medal": $athlete?medal
    }
  return map {
    "nationality": $nationality,
    "athletes": array{$athletesForNationality}
  }

return array{$groupedByNationality}
