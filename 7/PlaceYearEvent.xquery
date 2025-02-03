xquery version "3.1";

import schema default element namespace "" at "PlaceYearEvent.xsd";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

(: Returns all the locations, years and events, and gives back all 
   the different places where the Olympics were held. :)

let $file := fn:json-doc("../results.json") 

let $placeYearEvent := 
    for $i in 1 to array:size($file)
    let $games := ($file)($i)("games")
    for $j in 1 to array:size($games)
    return map{
        "location": ($games)($j)("location"),
        "year": ($games)($j)("year"),
        "eventType": ($file)($i)("name")
    }

let $sortedPlaceYearEvent := 
    for $event in $placeYearEvent
    order by 
        $event("location"),  
        xs:int($event("year")), 
        $event("eventType")  
    return $event

let $xmlPlaceYearEv :=
  <events>
    {
      for $event in $sortedPlaceYearEvent
      return 
        <event>
          <location>{ $event("location") }</location>
          <year>{ $event("year") }</year>
          <eventType>{ $event("eventType") }</eventType>
        </event>
    }
  </events>
  
let $locations := 
    for $i in 1 to array:size($file)
    let $games := ($file)($i)("games")
    for $j in 1 to array:size($games)
    return ($games)($j)("location")

let $distinctLocations := distinct-values($locations)

let $xmlDistinctLoc := 
  <locations>
    {
      for $location in $distinctLocations
      return <location>{ $location }</location>
    }
  </locations>

return
validate {
        document {
          <olympic>
             {$xmlPlaceYearEv, $xmlDistinctLoc }
          </olympic>
              }
       }
