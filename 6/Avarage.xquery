xquery version "3.1";

import schema default element namespace "" at "Avarage.xsd";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

(:
This query will check if the woman jumped better or worse than the average
in the "Long Jump Women" competition.
:)
declare function local:average($data) {
  let $results := for $entry in $data return $entry?*?results?*?result
  let $sum := sum($results)
  let $count := count($results)
  let $avg := $sum div $count
  return round($avg,2)
};

declare function local:compareToAverage($data) {
 let $avg := local:average($data)
 
 let $better := 
    for $entry in $data
    let $results := $entry?*?results
    for $result in $results
    let $values := $result?*?result  
    let $names := $result?*?name  
    for $i in 1 to count($values) 
    let $value := $values[$i]  
    let $name := $names[$i]  
    where $value > $avg
    let $diff := round(($value - $avg), 2)
    return map {
      "name": $name,
      "difference": $diff
    }

  let $worse := 
    for $entry in $data
    let $results := $entry?*?results
    for $result in $results
    let $values := $result?*?result 
    let $names := $result?*?name  
    for $i in 1 to count($values)  
    let $value := $values[$i]  
    let $name := $names[$i]  
    where $value < $avg
    let $diff := round(($avg - $value), 2)
    return map {
      "name": $name,
      "difference": $diff
    }
    
  let $sortedBetter := 
    for $entry in $better
    order by $entry?difference descending
    return $entry

  let $sortedWorse := 
    for $entry in $worse
    order by $entry?difference descending
    return $entry
    
  let $xmlBetter := 
    <better>
      {
        for $entry in $sortedBetter
        return 
          <athlete>
            <name>{$entry?name}</name>
            <difference>{$entry?difference}</difference>
          </athlete>
      }
    </better>

  let $xmlWorse := 
    <worse>
      {
        for $entry in $sortedWorse
        return 
          <athlete>
            <name>{$entry?name}</name>
            <difference>{$entry?difference}</difference>
          </athlete>
      }
    </worse>

  return 
  validate {
        document {
             <results>{$xmlBetter}{$xmlWorse}</results>
              }
       }
  
};

let $file := fn:json-doc("../results.json")

let $games := 
    for $i in 1 to array:size($file)
    where $file($i)("gender") = "W" and
    $file($i)("name") = "Long Jump Women"
    return ($file)($i)("games")
    
return local:compareToAverage($games)