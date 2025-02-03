xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

let $file := fn:json-doc("../results.json")

let $athletes := $file?*?games?*?results?*

(: Grouping athltes by their nationality using group by clause. :)
return 
  array {
    for $athlete in $athletes
    group by $nationality := $athlete?nationality
    let $athletesForNationality := 
      for $groupedAthlete in $athletes
      where $groupedAthlete?nationality = $nationality
      return $groupedAthlete
    return map {
      "nationality": $nationality,
      "athletes": array {
        for $athlete in $athletesForNationality
        return map {
          "name": if (empty($athlete?name)) then "team event" else $athlete?name,
          "result": $athlete?result,
          "medal": $athlete?medal
        }
      }
    }
  }