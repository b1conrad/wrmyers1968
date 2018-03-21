#!/bin/bash
echo "Content-type: text/html"
echo
TAG=`echo "$QUERY_STRING" | grep -o "id=[0-9]*" | cut -d = -f 2`
ECI="3zr2xyNrWDwZf534UG1UHW"
RID="com.bruceatbyu.graduands_collection"
G_RID="com.wrmyers68.grad"
G_ECI=`curl localhost:3002/sky/cloud/$ECI/$RID/Tx.txt?grad=g$TAG`
if [ -n "$G_ECI" ]
then
  curl localhost:3002/sky/cloud/$G_ECI/$G_RID/grad_page.html?grad=g$TAG
else
  curl localhost:3002/sky/cloud/$ECI/$RID/grad_page.html?grad=g$TAG
fi
