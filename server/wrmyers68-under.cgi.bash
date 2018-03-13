#!/bin/bash
echo "Content-type: text/html"
echo
TAG=`echo "$QUERY_STRING" | grep -o "id=[0-9]*" | cut -d = -f 2`
ECI="Djas7BJzcpKVLCGaJ6dtTC"
RID="com.bruceatbyu.undergraduates_collection"
curl localhost:3002/sky/cloud/$ECI/$RID/undergrad_page.html?undergrad=u$TAG
