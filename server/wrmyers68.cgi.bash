#!/bin/bash
echo "Content-type: text/html"
echo
TAG=`echo "$QUERY_STRING" | grep -o "id=[0-9]*" | cut -d = -f 2`
ECI="3zr2xyNrWDwZf534UG1UHW"
RID="com.bruceatbyu.graduands_collection"
curl localhost:3002/sky/cloud/$ECI/$RID/grad_page.html?grad=g$TAG
