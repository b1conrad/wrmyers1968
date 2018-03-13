#!/bin/bash
echo "Content-type: text/html"
echo
TAG=`echo "$QUERY_STRING" | grep -o "id=[0-9]*" | cut -d = -f 2`
ECI="9NkPCeqntNeafG5mtwmkFY"
RID="com.bruceatbyu.postgraduates_collection"
curl localhost:3002/sky/cloud/$ECI/$RID/postgrad_page.html?postgrad=p$TAG
