
module namespace page = 'https://geokretymap.org/modules/api';

import module namespace functx = 'http://www.functx.com';
import module namespace gkm = 'https://geokretymap.org';


(:~
 : This function generates the welcome page.
 : @return HTML page
 :)
declare
  %rest:path("")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start()
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>GeokretyMap - Geokrety api proxy</title>
    </head>
    <body>
      <h2>Geokrety api proxy</h2>

    </body>
  </html>
};


(:~
 : Lookup Gkid from NR
 : @param $nr to lookup
 : @return The gk documents
 :)
declare
  %rest:path("/nr/{$nr}")
  %rest:GET
  %output:media-type('text/plain')
  function page:nr2id(
    $nr as xs:string)

{
  gkm:nr2id($nr)
};


(:~
 : Find Geokrety by gkid
 : @param $gkid to lookup
 : @return The gk documents
 :)
declare
  %rest:path("/gk/{$gkid}")
  %rest:GET
  function page:geokrety_by_gkid(
    $gkid as xs:string)

{
  gkm:geokrety_by_gkid($gkid)
};

(:~
 : Find Geokrety by waypoint
 : @param $wpt to lookup
 : @return The gk documents
 :)
declare
  %rest:path("/wpt/{$wpt}")
  %rest:GET
  function page:geokrety_by_wpt(
    $wpt as xs:string)

{
  gkm:geokrety_by_wpt($wpt)
};

(:~
 : Find Geokrety by gkid or waypoint
 : @param $gkid to lookup
 : @param $wpt to lookup
 : @return The gk documents
 :)
declare
  %rest:path("/gkwpt/{$gkid}/{$wpt}")
  %rest:GET
  function page:geokrety_by_gkid_or_wpt(
    $gkid as xs:string,
    $wpt as xs:string)

{
  gkm:geokrety_by_gkid_or_wpt($gkid, $wpt)
};

(:~
 : Force Geokret to be fully refreshed
 : @param $gkid to lookup
 : @return The gk document
 :)
declare
  %updating
  %rest:path("/gk/{$gkid}/dirty")
  %rest:GET
  function page:geokrety_dirty(
    $gkid as xs:string)

{
  gkm:fetch_geokrety($gkid)
};

(:~
 : Find Geokrety details by gkid
 : @param $gkid to lookup
 : @return The gk document
 :)
declare
  %output:cdata-section-elements("description name owner user waypoint application comment message")
  %rest:path("/gk/{$gkid}/details")
  %rest:GET
  function page:geokrety_details_by_gkid(
    $gkid as xs:string)

{
  gkm:geokrety_details_by_gkid($gkid)
};

(:~
 : Find Geokrety details by waypoint
 : @param $gkid to lookup
 : @return The gk document
 :)
declare
  %output:cdata-section-elements("description name owner user waypoint application comment message")
  %rest:path("/wpt/{$wpt}/details")
  %rest:GET
  function page:geokrety_details_by_wpt(
    $wpt as xs:string)

{
  gkm:geokrety_details_by_wpt($wpt)
};

(:~
 : Find Geokrety details by gkid or waypoint
 : @param $gkid to lookup
 : @param $wpt to lookup
 : @return The gk document
 :)
declare
  %output:cdata-section-elements("description name owner user waypoint application comment message")
  %rest:path("/gkwpt/{$gkid}/{$wpt}/details")
  %rest:GET
  function page:geokrety_details_by_gkid_or_wpt(
    $gkid as xs:string,
    $wpt as xs:string)

{
  gkm:geokrety_details_by_gkid_or_wpt($gkid, $wpt)
};


(:~
 : Force Geokret details to be fully refreshed
 : @param $gkid to lookup
 : @return The gk document
 :)
declare
  %updating
  %output:cdata-section-elements("description name owner user waypoint application comment message")
  %rest:path("/gk/{$gkid}/details/dirty")
  %rest:GET
  function page:geokrety_details_dirty(
    $gkid as xs:string)

{
  gkm:fetch_geokrety($gkid)
};


(:~
 : Get basic pending queue size
 : @return count pending
 :)
declare
  %rest:path("pending")
  %rest:GET
  %rest:single
  %output:media-type('text/plain')
  function page:count_pending_basic()

{
  gkm:count_pending_basic()
};


(:~
 : Get details pending queue size
 : @return count pending
 :)
declare
  %rest:path("pending/details")
  %rest:GET
  %rest:single
  %output:media-type('text/plain')
  function page:count_pending_details()

{
  gkm:count_pending_details()
};


(:~
 : Get error pending queue size
 : @return count error pending
 :)
declare
  %rest:path("pending/errors")
  %rest:GET
  %rest:single
  %output:media-type('text/plain')
  function page:count_pending_details_error()

{
  gkm:count_pending_details_error()
};


(:~
 : fetch from export2 upstream datasource
 : @return The gk document
 :)
declare
  %updating
  %rest:path("fetch")
  %rest:GET
  %rest:single
  %output:media-type('text/plain')
  function page:fetch_from_export2()

{
  gkm:fetch_from_export2()
};


(:~
 : update from export2 pending datasource
 : @return The gk document
 :)
declare
  %updating
  %rest:path("merge")
  %rest:GET
  %output:media-type('text/plain')
  function page:merge_from_pending()

{
  gkm:merge_geokrety()
};


(:~
 : update from export upstream datasource
 : @return The gk document
 :)
declare
  %updating
  %rest:path("fetch/details")
  %rest:GET
  %rest:single
  %output:media-type('text/plain')
  function page:fetch_details_from_pending()

{
  gkm:fetch_geokrety_details_one_by_one()
};


(:~
 : update from export2 pending datasource
 : @return The gk document
 :)
declare
  %updating
  %rest:path("merge/details")
  %rest:GET
  %output:media-type('text/plain')
  function page:merge_from_pending_details()

{
  gkm:merge_geokrety_details()
};


(:~
 : update from export2 upstream datasource at specified time
 : @return The gk document
 :)
declare
  %updating
  %rest:path("fetch/{$modifiedsince}")
  %rest:GET
  %output:media-type('text/plain')
  function page:fetch_from_export2_date(
    $modifiedsince as xs:dateTime)

{
  gkm:fetch_from_export2_date($modifiedsince)
};


(:~
 : update from export2 upstream datasource at specified time
 : @return The gk document
 :)
declare
  %updating
  %rest:path("fetch/master")
  %rest:GET
  %output:media-type('text/plain')
  function page:fetch_geokrety_details_master()

{
  gkm:fetch_geokrety_details_master()
};


(:~
 : Launch backups
 :)
declare
  %updating
  %rest:path("backup")
  %rest:GET
  %output:media-type('text/plain')
  function page:backup()

{
  db:create-backup('geokrety')
};


(:~
 : Launch backups details
 :)
declare
  %updating
  %rest:path("backup/details")
  %rest:GET
  %output:media-type('text/plain')
  function page:backup-details()

{
  db:create-backup('geokrety-details')
};


(:~
 : Launch Optimize
 :)
declare
  %updating
  %rest:path("optimize")
  %rest:GET
  %output:media-type('text/plain')
  function page:optimize()

{
  db:optimize('geokrety', true())
};


(:~
 : Launch Optimize Details
 :)
declare
  %updating
  %rest:path("optimize/details")
  %rest:GET
  %output:media-type('text/plain')
  function page:optimize-details()

{
  db:optimize('geokrety-details', true())
};


(:~
 : Launch Memcopy
 :)
declare
  %updating
  %rest:path("memcopy")
  %rest:GET
  %output:media-type('text/plain')
  function page:memcopy()

{
  let $geokrety := doc("geokrety")/gkxml
  return
    db:create("gkmem", doc("geokrety")/gkxml, "/tmp/gkmem")
};


(:~
 : Launch export
 :)
declare
  %updating
  %rest:path("export")
  %rest:GET
  %output:media-type('text/plain')
  function page:export()

{
  db:export("geokrety", "/srv/BaseXData/export/", map { "method": "xml", "cdata-section-elements": "description name owner user waypoint application comment message"})
};


(:~
 : Launch export details
 :)
declare
  %updating
  %rest:path("export/details")
  %rest:GET
  %output:media-type('text/plain')
  function page:export-details()

{
  db:export("geokrety-details", "/srv/BaseXData/export/", map { "method": "xml", "cdata-section-elements": "description name owner user waypoint application comment message"})
};


(:~
 : Launch export details as Geojson
 :)
declare
  %updating
  %rest:path("export/details/xml")
  %rest:GET
  %output:media-type('text/plain')
  function page:export-details-xml()

{
  gkm:write_geokrety_details(doc('geokrety-details')/gkxml/geokrety/geokret)
};


(:~
 : Launch export details as Geojson
 :)
declare
  %updating
  %rest:path("export/geojson")
  %rest:GET
  %output:media-type('text/plain')
  function page:export-geojson()

{

  file:write('/srv/BaseXData/export/geokrety.json', gkm:as_geojson(doc('geokrety')/gkxml/geokrety/geokret))
};



(:~
 : Find Geokrety details by gkid
 : @param $gkid to lookup
 : @return The gk document
 :)
declare
  %output:cdata-section-elements("description name owner user waypoint application comment message")
  %rest:path("/gk/details/{$modifiedsince}")
  %rest:GET
  function page:geokrety_details_modifiedsince(
    $modifiedsince as xs:dateTime)

{
  gkm:geokrety_details_modifiedsince($modifiedsince)
};


(:~
 : Alias to get geokrety document
 : @param $gkid to lookup
 : @return The gk document
 :)
declare
  %rest:path("/geojson")
  %rest:GET
  %rest:query-param("latTL", "{$latTL}")
  %rest:query-param("lonTL", "{$lonTL}")
  %rest:query-param("lonBR", "{$lonBR}")
  %rest:query-param("latBR", "{$latBR}")

  %rest:query-param("newer", "{$newer}")
  %rest:query-param("older", "{$older}")
  %rest:query-param("ownername", "{$ownername}")
  %rest:query-param("ghosts", "{$ghosts}")
  %rest:query-param("missing", "{$missing}", "0")
  %rest:query-param("details", "{$details}")

  %rest:query-param("daysFrom", "{$daysFrom}", 0)
  %rest:query-param("daysTo", "{$daysTo}", 45)

  %rest:query-param("limit", "{$limit}", 500)
  %output:media-type('application/json')
  function page:as_geojson(
    $latTL as xs:float,
    $lonTL as xs:float,
    $latBR as xs:float,
    $lonBR as xs:float,

    $daysFrom as xs:integer?,
    $daysTo as xs:integer?,

    $limit as xs:integer?,

    $newer as xs:boolean?,
    $older as xs:boolean?,
    $ownername as xs:string?,
    $ghosts as xs:boolean?,
    $missing as xs:string?,
    $details as xs:boolean?
  ) {
  gkm:as_geojson_filter(
    $latTL, $lonTL,
    $latBR, $lonBR,

    $daysFrom, $daysTo,

    $limit,

    $newer, $older, $ownername,
    $ghosts, $missing, $details
  )
};


