xquery version "1.0";

import module namespace gkm = 'https://geokretymap.org';

gkm:write_geokrety_details(doc('geokrety-details')/gkxml/geokrety/geokret)
