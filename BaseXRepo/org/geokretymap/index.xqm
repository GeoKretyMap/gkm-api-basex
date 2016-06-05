(:~
 : This is an example for a module that can be added to the BaseX repository.
 : @author BaseX Team 2005-12, BSD License
 :)
module namespace gkm = 'https://geokretymap.org';

import module namespace functx = 'http://www.functx.com';


(:~
 : Convert type id to string
 : @param $typeid to convert
 : @return the corresponding string
 :)
declare
 function gkm:gktype($typeid) {
  switch (number($typeid))
    case 0
      return "Traditional"
    case 1
      return "A book"
    case 2
      return "A human"
    case 3
      return "A coin"
    case 4
      return "KretyPost"
    default
      return "Unkown"
};


(:~
 : Convert logtype string to id
 : @param $type to convert
 : @return the corresponding id
 :)
declare
 function gkm:logtype($type) {
  switch ($type)
    case "Dropped to"
      return 0
    case "Grabbed from"
      return 1
    case "A comment"
      return 2
    case "Seen in"
      return 3
    case "Archived"
      return 4
    case "Dipped in"
      return 5
    default
      return -1
};


(:~
 : Wrap geokret nodes in the traditionnal gk structure
 : @param $geokret to wrpa
 : @return Wrapped geokret
 :)
declare
 function gkm:wrap_response(
  $geokret as element(geokret)*)
    as element(gkxml)
{
<gkxml version="1.0" date="{ current-dateTime() }">
 <geokrety>
  { $geokret }
 </geokrety>
</gkxml>
};


(:~
 : Parse and Create node for an application
 : @param $node from which to extract info
 : @return an application node
 :)
declare
 function gkm:node_application($node as xs:string?) {
  if (not(empty($node))) then
    <application using="{ substring-after(substring-before($node, ' by '), 'Logged using ')}">{ substring-after($node, ' by ') }</application>
  else ()
};


(:~
 : Parse and Create node for an owner
 : @param $link from which to extract info
 : @return an owner node
 :)
declare
 function gkm:node_owner($link as element(a)?) {
  if ($link) then
    <owner id="{ tokenize($link/@href, '=')[2] }">{ $link/string() }</owner>
  else ()
};


(:~
 : Parse and Create node for an user
 : @param $link from which to extract info
 : @return an user node
 :)
declare
 function gkm:node_user($link as item()*) {
  if ($link) then
    <user id="{ tokenize($link/a/@href, '=')[2] }">{ $link/string() }</user>
  else ()
};


(:~
 : Parse and Create node for an user
 : @param $comment from which to extract info
 : @return an user node
 :)
declare
 function gkm:node_user_from_comment($comment as item()*) {
  if ($comment) then
    <user id="{ tokenize($comment/a[1]/@href, '=')[2] }">{ $comment/a[1]/string() }</user>
  else ()
};


(:~
 : Parse and Create node for a comment
 : @param $comment from which to extract info
 : @return message node
 :)
declare
 function gkm:node_message_from_comment($comment as item()*) {

  let $result := $comment/a[starts-with(@href, 'mypage.php')]/following-sibling::node()
  return <message>{
  head($result)/substring-after(., ': '),
  tail($result)
  }</message>

(:
  if ($comment) then
    copy $c := $comment
    modify (
      delete node $c/img[1],
      delete node $c/a[1],
      delete node $c/@*,
      rename node $c as 'message'
    )
    return $c
  else ()
:)
};



(:~
 : Parse and Create node for missing status
 : @param $node from which to extract info
 : @return an missing node
 :)
declare
 function gkm:node_missing($node) {
  let $lastmove := $node[functx:is-value-in-sequence(logtype/@id, (0, 1, 3, 5))][1]/comments
  return
  <missing>{ if ($lastmove and $lastmove[comment/@type = 'missing']) then 1 else 0 }</missing>
};


(:~
 : Parse and Create node for images
 : @param $node from which to extract info
 : @return images node
 :)
declare
 function gkm:node_images($images) {
  if ($images) then
  <images>
    { for $image in $images
      return <image>{ $image//a[1]/@title[1], functx:substring-after-last-match($image//a[1]/@href/string(), '/') }</image>
    }
  </images>
  else ()
};






(:~
 : Count geokrety basic pending
 : @return The number of pending updates
 :)
declare
function
gkm:count_pending_basic() {
  "Pending " || count(doc("pending-geokrety")/gkxml/geokrety/geokret) || " GeoKrety",
  ""
};


(:~
 : Count geokrety details pending
 : @return The number of pending updates
 :)
declare
function
gkm:count_pending_details() {
  "Pending " || count(doc("pending-geokrety-details")/gkxml/geokrety/geokret) || " GeoKrety details",
  ""
};


(:~
 : Count geokrety fetch errors
 : @return The number of updates errors
 :)
declare
function
gkm:count_pending_details_error() {
  "Pending " || count(doc("pending-geokrety")/gkxml/errors/geokret) || " Fetch error GeoKrety details",
  ""
};


(:~
 : Find Geokret by gkid
 : @param $gkid to lookup
 : @return The geokrety found
 :)
declare
%output:cdata-section-elements("description name owner user waypoint application comment message")
function
gkm:geokrety_by_gkid($gkid as xs:string) {
  gkm:wrap_response(doc("geokrety")/gkxml/geokrety/geokret[@id = $gkid])
};

(:~
 : Find Geokret by waypoint
 : @param $wpt to lookup
 : @return The geokrety found
 :)
declare
%output:cdata-section-elements("description name owner user waypoint application comment message")
function gkm:geokrety_by_wpt($wpt as xs:string) {
  gkm:wrap_response(doc("geokrety")/gkxml/geokrety/geokret[@waypoint = upper-case($wpt)])
};

(:~
 : Find Geokret by gkid or waypoint
 : @param $gkid to lookup
 : @param $wpt to lookup
 : @return The geokrety found
 :)
declare
%output:cdata-section-elements("description name owner user waypoint application comment message")
function gkm:geokrety_by_gkid_or_wpt($gkid as xs:string, $wpt as xs:string) {
  gkm:wrap_response(doc("geokrety")/gkxml/geokrety/geokret[@id = $gkid or @waypoint = upper-case($wpt)])
};

(:~
 : Find or create Geokret details by gkid
 : @param $gkid to lookup
 : @return The geokrety found
 :)
declare
  %output:cdata-section-elements("description name owner user waypoint application comment message")
  function gkm:geokrety_details_by_gkid($gkid as xs:string) {
  let $gkdetails := doc("geokrety-details")/gkxml/geokrety/geokret[@id = $gkid]
  return
    gkm:wrap_response($gkdetails)
};

(:~
 : Find or create Geokret details by gkid
 : @param $wpt to lookup
 : @return The geokrety found
 :)
declare
  %output:cdata-section-elements("description name owner user waypoint application comment message")
  function gkm:geokrety_details_by_wpt($wpt as xs:string) {
  let $gkdetails := doc("geokrety-details")/gkxml/geokrety/geokret[waypoints/waypoint = upper-case($wpt)]
  return
    gkm:wrap_response($gkdetails)
};

(:~
 : Find or create Geokret details by gkid or waypoint
 : @param $gkid to lookup
 : @param $wpt to lookup
 : @return The geokrety found
 :)
declare
  %output:cdata-section-elements("description name owner user waypoint application comment message")
  function gkm:geokrety_details_by_gkid_or_wpt($gkid as xs:string, $wpt as xs:string) {
  let $gkdetails := doc("geokrety-details")/gkxml/geokrety/geokret[@id = $gkid or waypoints/waypoint = upper-case($wpt)]
  return
    gkm:wrap_response($gkdetails)
};


(:
 :
 : Some helper functions
 :
 :
 :
 :
 :
 :
 :
 :)

(:~
 : Format date for geokrety
 : @param $datetime to format
 : @return The formated date
 :)
declare
  function gkm:format_date_for_geokrety(
    $datetime as xs:dateTime)
{
 (: TODO: timezone need to be manually updated on daylight changes :/ :)
  fn:format-dateTime(adjust-dateTime-to-timezone($datetime, xs:dayTimeDuration('PT2H')), "[Y0001][M01][D01][H01][m01][s01]")
};


(:~
 : Format date for geokrety
 : @param $datetime to format
 : @return The formated date
 :)
declare
  function gkm:format_date_only(
    $date as xs:date)
{
  let $year := year-from-date($date)
  let $month := month-from-date($date)
  let $day := day-from-date($date)
return
  functx:date($year, $month, $day)
};


(:~
 : Format date for geokrety
 : @param $datetime to format
 : @return The formated date
 :)
declare
  function gkm:geokrety_date(
    $date as xs:string)
{
  let $chunks := tokenize(functx:substring-before-match(functx:substring-before-match($date, '\s'), 'Z'), '-')
  return
    functx:date($chunks[1], $chunks[2], $chunks[3])
};


(:~
 : Check if duration is a valid delay in minutes
 :)
declare
 function gkm:is_valid_duration(
  $modifiedsince as xs:dateTime,
  $minutes as xs:decimal) {
  let $duration := functx:total-minutes-from-duration(current-dateTime() - $modifiedsince)

  return
  if ($duration > $minutes) then
    true()
  else
    fn:error(xs:QName('error'), "Rate limit at " || $minutes || ". [" || $duration || "]")
};


(:~
 : Check if duration is a valid geokrety delay
 :)
declare
 function gkm:is_valid_export2_duration(
  $currentdatetime as xs:dateTime) {
  let $modifiedsince := gkm:get_last_geokrety_pending($currentdatetime)
  let $duration := functx:total-days-from-duration($currentdatetime - xs:dateTime($modifiedsince))

  return
  if ($duration < 10) then
    gkm:format_date_for_geokrety($modifiedsince)
  else
    fn:error(xs:QName('error'), "updates are limited to the last 10 days. [" || $duration || "]")
};


declare function gkm:age
  ( $date1 as xs:anyAtomicType ,
    $date2 as xs:anyAtomicType )  as xs:integer {

   days-from-duration($date1 - xs:date(string-join((substring($date2, 1, 4), substring($date2, 6, 2), substring($date2, 9, 2)), '-')))
};


declare function gkm:nr2id
  ( $nr as xs:string ) as xs:string {

   let $gklink := html:parse(fetch:binary("https://geokrety.org/m/qr.php?nr=" || $nr))//a/@href[starts-with(., "../konkret.php?id=")]
   return functx:substring-after-match($gklink, "id=")
};


(:~
 : Save last full database upgrade date
 :)
declare
 %updating
 function gkm:save_last_geokrety_pending(
  $datetime as xs:dateTime)
{
  let $update := doc('pending-geokrety')/gkxml/@update
  return
    (
    if ($update) then
      replace value of node $update with $datetime
    else
      insert node (attribute update { $datetime }) as last into doc('pending-geokrety')/gkxml
    )
};


(:~
 : Save last full database upgrade date
 :)
declare
 %updating
 function gkm:save_last_geokrety_details_pending(
  $datetime as xs:dateTime)
{
  let $update := doc('pending-geokrety-details')/gkxml/@update
  return
    (
    if ($update) then
      replace value of node $update with $datetime
    else
      insert node (attribute update { $datetime }) as last into doc('pending-geokrety-details')/gkxml
    )
};


(:~
 : Get modifiedsince value for database
 : @param $database to consult
 : @return The modifiedsince value
 :)
declare
 function gkm:get_last_geokrety_pending(
  $currentdatetime as xs:dateTime)
{
  let $updatelast := doc('pending-geokrety')/gkxml/@update
  return
    if (fn:exists($updatelast) and 
        functx:total-days-from-duration($currentdatetime - xs:dateTime($updatelast)) < 10) then
          xs:dateTime($updatelast)
    else
        $currentdatetime - xs:dayTimeDuration("P9DT10M")
};


(:~
 : Get last pending update date
 : @param $database to consult
 : @return The modifiedsince value
 :)
declare
 function gkm:get_last_geokrety_details_pending()
{
  let $updatelast := doc('pending-geokrety-details')/gkxml/@update
  return
    if (fn:exists($updatelast)) then
      xs:dateTime($updatelast)
    else
      current-dateTime() - xs:dayTimeDuration("P50D")
};


(:~
 : Update username into GK basic
 : @param $geokret to update
 : @param $username to set
 :)
declare
 %updating
 function gkm:update_ownername_in_geokrety(
  $geokret as element(geokret),
  $ownername as xs:string
 ) {
  if (exists($geokret/@ownername)) then
    replace value of node $geokret/@ownername with $ownername
  else
    insert node (attribute ownername { $ownername }) as last into $geokret
};


(:~
 : Update missing into GK basic
 : @param $geokret to update
 : @param $missing to set
 :)
declare
 %updating
 function gkm:update_missing_in_geokrety(
  $geokret as element(geokret),
  $missing as xs:string
 ) {
  if (exists($geokret/@missing)) then
    replace value of node $geokret/@missing with $missing
  else
    insert node (attribute missing { $missing }) as last into $geokret
};

(:~
 : Update date into GK basic
 : @param $geokret to update
 : @param $date to set
 :)
declare
 %updating
 function gkm:update_date_in_geokrety(
  $geokret as element(geokret),
  $date as xs:date?
 ) {
  (:if (not($date)) then
    ()
  else:) if (exists($geokret/@date)) then
    replace value of node $geokret/@date with gkm:format_date_only($date)
  else
    insert node (attribute date { gkm:format_date_only($date) }) as last into $geokret
};


(:~
 : Add, replace pending GK in non detailled database
 : @param $geokrets the documents to update
 :)
declare
 %updating
 function gkm:insert_or_replace_geokrety_pending($geokrets as element(geokret)*) {
  let $date := current-date()
  for $geokret in $geokrets
    let $gkid := $geokret/@id/string()
    return (
      delete node doc("pending-geokrety")/gkxml/geokrety/geokret[@id = $gkid],
      gkm:update_date_in_geokrety($geokret, $date),
      insert node $geokret as last into doc("pending-geokrety")/gkxml/geokrety
    )
};


(:~
 : Add, replace GK in non detailled database
 : @param $geokrets the documents to update
 :)
(:declare
 %updating
 function gkm:insert_or_replace_geokrety($geokrets as element(geokret)*) {
  let $date := current-date()
  for $geokret in $geokrets
    let $gkid := $geokret/@id/string()
    return (
      delete node doc("geokrety")/gkxml/geokrety/geokret[@id = $gkid],
      insert node $geokret as last into doc("geokrety")/gkxml/geokrety
    )
};:)


(:~
 : Push gkid to pending database
 : @param $gkid to save
 :)
declare
 %updating
 function gkm:insert_gkid_to_pending($gkid as xs:string) {
  if (not(doc("pending")/gkxml/gk[. = $gkid])) then
(
    db:output("Insert " || $gkid),
    db:output(""),
    insert node <gk>{ $gkid }</gk> as last into doc("pending")/gkxml
)
  else ()
};


(:~
 : Remove gkid from pending database
 : @param $gkid to remove
 :)
declare
 %updating
 function gkm:remove_gkid_from_pending($gkid as xs:string) {
   delete node doc("pending")/gkxml/gk[. = $gkid]
};


(:~
 : Get last move date or now
 : @param $geokret to extract move date
 :)
declare
 function gkm:last_move_date($geokret as element(geokret)?) {
   let $last_move := $geokret/moves/move[functx:is-value-in-sequence(./logtype/@id, (0, 1, 3, 5))][1]/date/@moved

   return
   if ($last_move) then
     gkm:geokrety_date($last_move)
   else
     gkm:geokrety_date(string(current-date()))
};


(:
 :
 : Update basic informations
 :
 :
 :
 :
 :
 :
 :
 :)


(:~
 : Retrieve geokrety and update database
 :)
declare
 %updating
 function gkm:create_geokrety() {
  db:create('geokrety', "https://api.gkm.kumy.org/basex/export/geokrety.xml", 'geokrety')
};


(:~
 : Retrieve geokrety-details and update database
 :)
declare
 %updating
 function gkm:create_geokrety_details() {
  db:create('geokrety-details', "https://api.gkm.kumy.org/basex/export/geokrety-details.xml", 'geokrety-details')
};


(:~
 : Create an initial pending-database
 :)
declare
 %updating
 function gkm:create_pending_geokrety() {
  db:create('pending-geokrety', <gkxml><geokrety/><errors/></gkxml>, 'pending-geokrety')
};


(:~
 : Create an initial pending-database details
 :)
declare
 %updating
 function gkm:create_pending_geokrety_details() {
  db:create('pending-geokrety-details', <gkxml><geokrety/><errors/></gkxml>, 'pending-geokrety-details')
};


(:~
 : Retrieve geokrety and update pending database
 : @param $gkid to process
 :)
declare
 %updating
 function gkm:fetch_geokrety($gkid as xs:string) {
  let $geokret := fetch:xml("https://geokrety.org/export2.php?gkid=" || $gkid)/gkxml/geokrety/geokret
  return (
    db:output(gkm:wrap_response($geokret)),
    gkm:insert_or_replace_geokrety_pending($geokret)
  )
};


(:~
 : Merge geokrety and update database
 : @param $gkid to process
 :)
declare
 %updating
 function gkm:merge_geokrety() {
   let $gks := subsequence(doc("pending-geokrety")/gkxml/geokrety/geokret[@date], 1, 30)
   return (
     db:output("Merging " || count($gks) || " GeoKrety"),
     db:output(""),
     insert node $gks as last into doc("geokrety")/gkxml/geokrety,
     for $geokret in $gks
       return (
       delete node doc("geokrety")/gkxml/geokrety/geokret[@id = $geokret/@id]
     ),
     delete node $gks
   )
};


(:~
 : Retrieve export since last update then update database
 :)
declare
 %updating
 function gkm:fetch_from_export2() {
   gkm:fetch_from_export2_date(current-dateTime())
};


(:~
 : Retrieve export since last update then update database
 :)
declare
 %updating
 function gkm:fetch_from_export2_date(
  $currentdatetime as xs:dateTime) {
  if (gkm:is_valid_duration(gkm:get_last_geokrety_pending($currentdatetime), 0.1)) then
  let $date := gkm:is_valid_export2_duration($currentdatetime)
  let $gks := fetch:xml("https://geokrety.org/export2.php?modifiedsince=" || $date, map { 'chop': true() })//geokret

    return (
      db:output("Fetch " || count($gks) || " GeoKrety"),
      db:output(""),
      gkm:insert_or_replace_geokrety_pending($gks),
      gkm:save_last_geokrety_pending($currentdatetime)
    )
  else ()
};

(:
 :
 : Update detailed informations
 :
 :
 :
 :
 :
 :
 :
 :)



(:~
 : Retrieve geokrety details and update database
 : @param $gkid to process
 :)
declare
 %updating
 function gkm:fetch_geokrety_details_one_by_one() {
   let $last_update := current-dateTime()
   (:for $geokret in doc("pending-geokrety")/gkxml/geokrety/geokret[not(@date)][1]:)
   let $geokrets := subsequence(doc("pending-geokrety")/gkxml/geokrety/geokret[not(@date)], 1, 30)
   return (
   gkm:save_last_geokrety_details_pending($last_update),
   db:output("Fetch " || count($geokrets) || " GeoKrety details"),
   db:output(""),
   for $geokret in $geokrets
     return
     gkm:fetch_geokrety_details($geokret)
   )
};


(:~
 : Retrieve geokrety details and update database
 : @param $gkid to process
 :)
declare
 %updating
 function gkm:fetch_geokrety_details($geokret as element(geokret)) {
   if (gkm:is_valid_duration(gkm:get_last_geokrety_details_pending(), 0.1)) then
     try {
       let $geokret_details := gkm:geokrety_details($geokret)
       (: TODO: check if geokret is good :)
       let $last_move := gkm:last_move_date($geokret_details)
       let $missing := if ($geokret_details/owner/missing = "1") then "1" else "0"
       let $ownername := $geokret_details/owner/string()
       return (
   db:output("fetched: " || $geokret/@id || " -> " || $geokret_details/@id),
   db:output(""),
         gkm:insert_or_replace_geokrety_details($geokret_details),
         gkm:update_date_in_geokrety($geokret, $last_move),
         gkm:update_missing_in_geokrety($geokret, $missing),
         gkm:update_ownername_in_geokrety($geokret, $ownername)
       )
     } catch * {
   db:output("Mark as failing: " || $geokret/@id),
       gkm:mark_geokrety_as_failing($geokret)
     }
   else (
   db:output("Failed to fetch: " || $geokret/@id),
   db:output("")
   )
};


(:~
 : Move a geokret to error pending
 : @param $geokret to process
 :)
declare
 %updating
 function gkm:mark_geokrety_as_failing($geokret as element(geokret)) {
   if (not(doc('pending-geokrety')/gkxml/errors)) then (
     insert node <errors>{ $geokret }</errors> as last into doc('pending-geokrety')/gkxml,
     delete node $geokret
   ) else (
     insert node $geokret as last into doc('pending-geokrety')/gkxml/errors,
     delete node $geokret
   )
};


(:~
 : Merge geokrety and update database
 : @param $gkid to process
 :)
declare
 %updating
 function gkm:merge_geokrety_details() {
   let $gks := doc("pending-geokrety-details")/gkxml/geokrety/geokret
   return (
     db:output("Merging " || count($gks) || " GeoKrety details"),
     db:output(""),
     for $geokret in $gks
       return (
       gkm:write_geokrety_details($geokret),
       delete node doc("geokrety-details")/gkxml/geokrety/geokret[@id = $geokret/@id],
       insert node $geokret as last into doc("geokrety-details")/gkxml/geokrety,
       delete node $geokret
     )
   )
};


(:~
 : Add, replace GK in detailled database
 : @param $geokret to update
 :)
declare
 %updating
 function gkm:insert_or_replace_geokrety_details($geokrets as element(geokret)*) {
  for $geokret in $geokrets
    return (
      delete node doc("pending-geokrety-details")/gkxml/geokrety/geokret[@id = $geokret/@id],
      insert node $geokret as last into doc("pending-geokrety-details")/gkxml/geokrety
    )
};


(:~
 : Write GK details to a file
 : @param $geokret to write
 :)
declare
 %updating
 function gkm:write_geokrety_details($geokrets as element(geokret)*) {
  for $geokret in $geokrets
    return 
      file:write(
        "/srv/BaseXData/export/gkdetails/" || $geokret/@id || ".xml",
        gkm:wrap_response($geokret),
        map { "method": "xml", "cdata-section-elements": "description name owner user waypoint application comment message"}
      )
};

(:
 :
 : ???
 :
 :
 :
 :
 :
 :
 :
 :)


(:~
 : Merge or insert
 : @param $gkid to process
 :)
(:declare
 %updating
 function gkm:merge_geokrety(
  $geokrets as element(geokret)*)
{
  for $geokret in $geokrets
    let $gk := doc("geokrety-details")/gkxml/geokrety/geokret[@id = $geokret/@id]
    return 
    if (fn:exists($gk)) then (
      db:output("Update geokret: " || $geokret/@id),
      replace value of node $gk/name with $geokret/name,
      replace value of node $gk/description with $geokret/description,
      replace value of node $gk/owner with $geokret/owner,
      replace value of node $gk/datecreated with $geokret/datecreated,
      replace value of node $gk/distancetravelled with $geokret/distancetravelled,
      replace value of node $gk/state with $geokret/state,
      replace value of node $gk/missing with $geokret/missing,
      replace value of node $gk/position with $geokret/position,
      replace value of node $gk/waypoints with $geokret/waypoints,
      replace value of node $gk/type with $geokret/type
    ) else (
      db:output("Insert geokret: " || $geokret/@id),
      insert node $geokret as last into doc("geokrety-details")/gkxml/geokrety
    )
};:)


(:~
 : Merge or insert moves
 : @param $gkid to process
 :)
(:declare
 %updating
 function gkm:merge_geokrety_moves(
  $moves as element(moves)*)
{
  for $move in $moves
    let $gk := doc("geokrety-details")/gkxml/geokrety/geokret[@id = $move/geokret/@id]
    return (
    if (not(exists($gk))) then (
      gkm:update_geokrety_details($move/geokret/@id)
    ) else ( ),

    if (fn:exists($gk/moves/move[id = $move/@id])) then (
      db:output("Update move: " || $move/@id),
      replace value of node $gk/position with $move/position,
      replace value of node $gk/date with $move/date,
      replace node $gk/user with $move/user,
      replace value of node $gk/comment with $move/comment,
      replace value of node $gk/logtype with $move/logtype,
      replace value of node $gk/wpt with $move/waypoints/waypoint
    ) else ()
    )
};:)


(:~
 : Obtain Geokret moves from upstream export
 : @param $html page to parse
 : @return The geokrety moves
 :)
(:declare
 function
 gkm:geokrety_details_moves_export($move as element(moves)) as element(move) {
<move>
  <id>{ $move/@id }</id>
  <position>{ $move/position }</position>
  <wpt alt="">{ $move/waypoints/waypoint }</wpt>
  <date>{ $move/date }</date>
  <user>{ $move/user }</user>
  <comment>{ $move/comment }</comment>
  <logtype>{ $move/logtype }</logtype>
</move>
};:)


(:~
 : Obtain Geokret node from upstream by gkid
 : @param $geokret to obtain
 : @return The geokrety found
 :)
(:declare
 function
 gkm:geokrety($gkid as xs:string) as element(geokret)* {

fetch:xml("https://geokrety.org/export2.php?gkid=" || $gkid)/gkxml/geokrety/geokret
};:)

(:
 :
 : Crawl Geokrety details
 :
 :
 :
 :
 :
 :
 :
 :)



(:~
 : Load all other pages and retrieve moves
 : @param $gkid to parse
 : @param $pages total count of pages to fetch
 : @param $moves from the first page
 : @return All Geokrety moves
 :)
declare
 function gkm:geokrety_details_moves_pages(
 $gkid as xs:string,
 $pages as xs:integer,
 $moves as element()*) {
  let $found := false()
  return
    $moves,
    array:flatten(array:for-each( array:reverse( array { 1 to $pages - 1 }),
      function($i) {
        html:parse(fetch:binary("https://api.geokretymap.org/gk/konkret.php?id=" || $gkid || "&amp;page=" || $i))//div[@id="prawo"]/div//table[@class="kretlogi"]
      }))
};


(:~
 : Obtain Geokret moves
 : @param $html page to parse
 : @return The geokrety moves
 :)
declare function gkm:geokrety_details_moves($gkid as xs:string, $pages as xs:integer, $moves as element()*) as element(move)* {

  let $gpx := fetch:xml("https://geokrety.org/mapki/gpx/GK-" || $gkid || ".gpx", map { 'intparse': true(), 'stripns': true() })
  (:let $moves := gkm:geokrety_details_moves_pages($gkid, $pages, $moves):)

  for $move in $moves
    let $distance := $move/tr[2]/td[1]/span/string()
    let $moveDate := tokenize($move/tr[2]/td[3]/text()[1], " / ")[1]
    let $gpxmove := util:last-from($gpx/gpx/wpt[fn:starts-with(./time, $moveDate) and ./name = $move/tr[2]/td[2]/span/a/string()])
    
    return
    <move>
      <id>{ tokenize($move/tr[2]/td[1]/img/@title/string(), "\s")[1] }</id>
      { if ($gpxmove) then <position latitude="{ $gpxmove/@lat }" longitude="{ $gpxmove/@lon }" /> else () }
      { if ($gpxmove) then <wpt>{ $move/tr[2]/td[2]//img/@alt, functx:substring-after-last-match($gpxmove/url/string(), '=') }</wpt> else () }
      <date moved="{ $moveDate }" />
      { gkm:node_user($move//span[@class="user"]) }
      { gkm:node_application($move//tr[2]/td[3]/img/@title/string()) }
      <comment>{ $move/tr[3]/td/text() }</comment>
      <logtype id="{ gkm:logtype($move/tr[2]/td[1]/img/@alt) }">{ $move/tr[2]/td[1]/img/@alt/string() }</logtype>
      { if (empty($distance)) then () else <distancetravelled unit="km">{ functx:get-matches($distance, "\d+")[1] }</distancetravelled> }
      { gkm:node_images($move/tr[3]//div[@id = "obrazek_box"]) }
      { let $comments := $move/tr[not(exists(@class))]/td[2] return
      if ($comments) then
      <comments>
        { for $comment in $comments
          let $comment_type := if ($comment/img/@alt = '!!') then 'missing' else 'message'
          return
          <comment type="{ $comment_type }">
            { gkm:node_user_from_comment($comment) }
            { gkm:node_message_from_comment($comment) }
          </comment>
        }
      </comments>
      else ()
      }
    </move>
};


(:~
 : Obtain Geokret details node from upstream by gkid
 : @param $geokret to obtain
 : @return The geokrety found
 :)
declare
function gkm:geokrety_details(
 $geokret as element(geokret)
 ) as element(geokret)* {

  let $current_gk_details := doc("geokrety-details")/gkxml/geokrety/geokret[@id = $geokret/@id]
  
  let $page := html:parse(fetch:binary("https://api.geokretymap.org/gk/konkret.php?id=" || $geokret/@id))//div[@id="prawo"]/div
  let $tbinfo := $page/table[1]//tr
  let $tbdetails := $page/table[2]//tr
  let $pages_count := $page/div[2]/strong/a
  let $moves := if ($page/div[2]/strong/a) then gkm:geokrety_details_moves($geokret/@id, convert:integer-from-base($pages_count, 10), $page//table[@class="kretlogi"]) else ()
  
  return
  <geokret id="{ $geokret/@id }">
    <name>{ $geokret/text() }</name>
    <description>{ $tbdetails[2]/td/text() }</description>
    { gkm:node_owner($tbinfo[1]//a) }
    <datecreated></datecreated>
    <distancetravelled unit="km">{ $geokret/@dist/string() }</distancetravelled>
    <places>{ $tbinfo[4]//strong/text() }</places>
    <state>{ $geokret/@state/string() }</state>
    { gkm:node_missing($moves) }
    { if ($geokret/@lat and $geokret/@lon) then <position latitude="{ $geokret/@lat }" longitude="{ $geokret/@lon }"/> else () }
    <waypoints>
      <waypoint id="{ $geokret/@last_pos_id }">{ $geokret/@waypoint/string() }</waypoint>
    </waypoints>
    <type id="{ $geokret/@type }">{ gkm:gktype($geokret/@type) }</type>
    { for $avatar in $tbdetails[4]/td/div/span[@class="obrazek_hi"]
      return <image>{ $avatar/a[1]/@title[1], functx:substring-after-last-match($avatar/a[1]/@href/string(), '/') }</image>
    }
    { gkm:node_images($tbdetails[4]/td/div/span[@class="obrazek"]//img[starts-with(@src, 'obrazki-male/')]/../..) }
    <moves last_id="{ $geokret/@last_log_id }">
      { $moves }
    </moves>
  </geokret>

};



(:~
 : Export Geokrety as geojson
 : @param The filters to appy
 : @return GeoKrety to display
 :)
declare
function gkm:as_geojson_filter(
 $latTL as xs:float,
 $lonTL as xs:float,
 $latBR as xs:float,
 $lonBR as xs:float,

 $daysFrom as xs:integer,
 $daysTo as xs:integer,

 $limit as xs:integer,

 $newer as xs:boolean?,
 $older as xs:boolean?,
 $ownername as xs:string?,
 $ghosts as xs:boolean?,
 $missing as xs:string?,
 $details as xs:boolean?

 ) {

let $dateFrom := xs:string(current-date() - functx:dayTimeDuration($daysFrom, 0, 0, 0))
let $dateTo   := xs:string(current-date() - functx:dayTimeDuration($daysTo  , 0, 0, 0))

let $input   := doc("geokrety")/gkxml/geokrety/geokret[@missing=$missing]

let $filter1 := if ($ownername)
                then $input[@ownername=$ownername]
                else $input

let $filter2 := if ($ghosts)
                then $filter1[not(@state="0" or @state="3")]
                else $filter1[    @state="0" or @state="3" ]

let $filter3 := if ($daysFrom = 0)
                then $filter2
                else $filter2[$dateFrom >= @date]

let $filter4 := if ($daysTo = -1)
                then $filter3
                else $filter3[@date >= $dateTo]

let $result := $filter4[xs:float(@lat) <= $latTL
                    and xs:float(@lon) <= $lonTL
                    and xs:float(@lat) >= $latBR
                    and xs:float(@lon) >= $lonBR]

return
gkm:as_geojson(subsequence($result, 1, $limit))

(:
{
   "type":"FeatureCollection",
   "features":[
      {
         "geometry":{
            "type":"Point",
            "coordinates":[
               6.57052,
               43.73088
            ]
         },
         "type":"Feature",
         "properties":{
            "popupContent":"Trojan",
            "age":"newer"
         }
      },
   ]
}
:)


};



(:~
 : Export Geokrety as geojson
 : @param The geokrety to disaply a geojson
 : @return GeoKrety as geojson
 :)
declare
function gkm:as_geojson(
 $geokrets as element(geokret)*
) {

let $year := year-from-date(current-date())
let $month := month-from-date(current-date())
let $day := day-from-date(current-date())
let $today := functx:date($year, $month, $day)

return
json:serialize(
<json type="object">
  <type>FeatureCollection</type>
  <features type="array">
{for $a in $geokrets[@lat and @lon]
  return
    <_ type="object">
      <geometry type="object">
        <type>Point</type>
        <coordinates type="array">
          <_ type="number">{$a/@lon/number()}</_>
          <_ type="number">{$a/@lat/number()}</_>
        </coordinates>
      </geometry>
      <type>Feature</type>
      <properties type="object">
        <gkid>{ $a/@id/string() }</gkid>
        <age>{ string(if ($a/@date) then gkm:age($today, $a/@date) else '99999') }</age>
        { gkm:jsonProperties($a, $today) }
      </properties>
    </_>
}
  </features>
</json>
)
};



(:~
 : Export Geokrety as geojson
 : @param $geokret to obtain
 : @return The geokrety found
 :)
declare
function gkm:jsonProperties(
 $a as element(geokret),
 $today
 ) {

<popupContent>
{
'<h1' || (if ($a/@missing = '1') then ' class="missing"' else '') || '><a href="https://geokretymap.org/' || $a/@id || '" target="_blank">' || $a/data() || '</a></h1>' ||
string(if ($a/@waypoint) then (if ($a/not(@state="0" or @state="3")) then 'Last seen in' else 'In') || ' <a href="https://geokrety.org/go2geo/index.php?wpt=' || $a/@waypoint || '" target="_blank">' || $a/@waypoint || '</a><br />' else '') ||
string(if ($a/@date) then 'Last move: ' || $a/@date || '<br />' else '') ||
'Travelled: ' || $a/@dist || ' km<br />' || (if ($a/@ownername) then 'Owner: <a href="https://geokrety.org/mypage.php?userid=' || $a/@owner_id || '" target="_blank">' || $a/@ownername || '</a><br />' else '') ||
string(if ($a/@image) then '<img src="https://geokretymap.org/gkimage/' || $a/@image || '" width="100" />' else '')
}
</popupContent>

};
