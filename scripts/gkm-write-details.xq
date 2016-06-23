xquery version "1.0";

for $geokret in doc('geokrety-details')/gkxml/geokrety/geokret
  return
    file:write(
      "/srv/BaseXData/export/gkdetails/" || $geokret/@id || ".xml",
      <gkxml version="1.0" date="{ current-dateTime() }">
       <geokrety>
        { $geokret }
       </geokrety>
      </gkxml>,
      map { "method": "xml", "cdata-section-elements": "description name owner user waypoint application comment message"}
    )
