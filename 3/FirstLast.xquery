xquery version "3.1";

import schema default element namespace "" at "FirstLast.xsd";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

(:
This query returns the fastest and slowest runner in the 10000M Men race,
and the difference between their time.
:)

declare function local:timeToSeconds($time as xs:string) as xs:decimal {
  let $parts := tokenize($time, '[:.]')
  let $minutes := xs:decimal($parts[1])
  let $seconds := xs:decimal($parts[2])
  let $milliseconds := xs:decimal($parts[3])
  return ($minutes * 60) + $seconds + ($milliseconds div 1000)
};

declare function local:secondsToTime($seconds as xs:decimal) as xs:string {
  let $minutes := floor($seconds div 60)  
  let $remainingSeconds := $seconds mod 60  
  let $milliseconds := ($remainingSeconds - floor($remainingSeconds)) * 1000  
  
  let $formattedSeconds := format-number(floor($remainingSeconds), '00')  
  let $formattedMilliseconds := format-number(round($milliseconds), '000') 
  
  return string($minutes) || ':' || $formattedSeconds || '.' || $formattedMilliseconds  
};

let $file := fn:json-doc("../results.json")

let $get10000MaleGames := 
    for $i in 1 to array:size($file)
    where $file($i)("gender") = "M" and
    $file($i)("name") = "10000M Men"
    return ($file)($i)("games")
    
let $get10000MaleGamesArr := array{$get10000MaleGames}

let $GoldRuns := 
    for $i in 1 to array:size($get10000MaleGamesArr)
        for $j in 1 to array:size($get10000MaleGamesArr($i))
            let $res := $get10000MaleGamesArr($i)($j)("results")
            let $resGold := 
                for $k in 1 to array:size($res)
                    where $res($k)("medal") = "G"
                    return map {
                        "name": $res($k)("name"),
                        "res": $res($k)("result"),
                        "resInSec": local:timeToSeconds($res($k)("result")),
                        "year": $get10000MaleGamesArr($i)($j)("year"),
                        "location": $get10000MaleGamesArr($i)($j)("location")
                    }
            return $resGold

let $fastest := min($GoldRuns?resInSec)
let $slowest := max($GoldRuns?resInSec)

let $difference := $slowest - $fastest

let $GoldRunsArr := array{$GoldRuns}

let $fastestRunners := 
for $i in 1 to array:size($GoldRunsArr)
where $GoldRunsArr($i)("resInSec") = $fastest
return 
$GoldRunsArr($i)

let $firstFastestRunner := $fastestRunners[1]

let $slowestRunners := for $i in 1 to array:size($GoldRunsArr)
where $GoldRunsArr($i)("resInSec") = $slowest
return 
$GoldRunsArr($i)

let $firstSlowestRunner := $slowestRunners[1]

return
validate {
        document {
            <runs>
                <fastestRunner location="{$firstFastestRunner?location}" year="{$firstFastestRunner?year}">
                    <name>{$firstFastestRunner?name}</name>
                    <res>{$firstFastestRunner?res}</res>
                    <resInSec>{$firstFastestRunner?resInSec}</resInSec>
                </fastestRunner>
                <slowestRunner location="{$firstSlowestRunner?location}" year="{$firstSlowestRunner?year}">
                    <name>{$firstSlowestRunner?name}</name>
                    <res>{$firstSlowestRunner?res}</res>
                    <resInSec>{$firstSlowestRunner?resInSec}</resInSec>
                </slowestRunner>
                <differenceInTime>
                    <differenceInSeconds>{$difference}</differenceInSeconds>
                    <differenceInMin>{local:secondsToTime($difference)}</differenceInMin>
                </differenceInTime>
            </runs>
            }
          }

