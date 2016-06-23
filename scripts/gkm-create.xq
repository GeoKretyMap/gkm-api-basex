xquery version "1.0";

declare namespace gkm = 'https://geokretymap.org';

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

gkm:create_geokrety(),
gkm:create_geokrety_details(),
gkm:create_pending_geokrety(),
gkm:create_pending_geokrety_details()
