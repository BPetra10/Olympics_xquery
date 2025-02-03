xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:version "5.0";
declare option output:encoding "UTF-8";
declare option output:indent "yes";

(:Returns a medal table by nationalities. 
 This will give back all the nations gold, silver, and bronze medal count.
 :)
let $file := fn:json-doc("../results.json")

let $athletes := $file?*?games?*?results?*

let $medalsByCountry := 
  for $athlete in $athletes
  group by $nationality := $athlete?nationality
  let $athletesForNationality := 
    for $groupedAthlete in $athletes
    where $groupedAthlete?nationality = $nationality
    return $groupedAthlete
  let $goldCount := count($athletesForNationality[?medal = "G"])
  let $silverCount := count($athletesForNationality[?medal = "S"])
  let $bronzeCount := count($athletesForNationality[?medal = "B"])
  return map {
    "nationality": $nationality,
    "gold": $goldCount,
    "silver": $silverCount,
    "bronze": $bronzeCount
  }

let $sortedMedals := 
  for $entry in $medalsByCountry
  order by $entry("gold") descending, $entry("silver") descending, $entry("bronze") descending
  return $entry

return document {
    <html>
        <head>
            <title>Medal Table by Nationality</title>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
        </head>
        <body>
            <div class="container mt-4">
                <h2 class="text-center mb-4">Medal Table by Nationality</h2>
                <table class="table table-bordered table-hover table-striped text-center">
                    <thead class="table-info">
                        <tr>
                            <th>Nationality</th>
                            <th>Gold Medals</th>
                            <th>Silver Medals</th>
                            <th>Bronze Medals</th>
                        </tr>
                    </thead>
                    <tbody>
                        {
                            for $entry at $index in $sortedMedals
                            return 
                                let $bgColor := 
                                    if ($index = 1) then "background-color: gold;" 
                                    else if ($index = 2) then "background-color: silver;" 
                                    else if ($index = 3) then "background-color: #DB9E67;" 
                                    else ""
                                return 
                                    <tr>
                                        <td style="{$bgColor}">{$entry("nationality")}</td>
                                        <td style="{$bgColor}">{$entry("gold")}</td>
                                        <td style="{$bgColor}">{$entry("silver")}</td>
                                        <td style="{$bgColor}">{$entry("bronze")}</td>
                                    </tr>
                        }
                    </tbody>
                </table>
            </div>
        </body>
    </html>
}
