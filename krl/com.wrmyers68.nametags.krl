ruleset com.wrmyers68.nametags {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module com.bruceatbyu.graduands_collection alias grads
    shares __testing, nametags
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    style = function(){
      <<<style type="text/css">
  div.wrap {page-break-inside:avoid;margin:0;padding:0;}
  div.grad {position:relative;width:3.75in;}
  fieldset {width:3.5in;border:1px solid #8a4651;border-radius:10px;}
  legend {text-align:right;}
  legend span {color:#8a4651;font-size:80%;}
  div.grad .url {font-size:80%;position:absolute;right:0;}
</style>
>>
    }
    one_nametag = function(g){
      eci = g{"Tx"};
      r = wrangler:skyQuery(eci,"com.wrmyers68.nametag","nametag");
      h = r{"error"} => null | r;
      <<<div class="wrap">
#{h}</div>
>>
    }
    hasRID = function(eci,rid){
      pid = engine:getPicoIDByECI(eci);
      pid && engine:listInstalledRIDs(pid) >< rid
    }
    nametags = function(ln){
      todo = grads:grads()
        .filter(function(v){v{"ln"} like "^"+ln})
        .filter(function(v){hasRID(v{"Tx"},"com.wrmyers68.nametag")});
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>#{ln}</title>
<link rel="icon" type="image/png" href="http://wrmyers68.com/68.png">
#{style()}</head>
<body>
#{todo.map(function(v){one_nametag(v)}).values().join("")}</body>
</html>
>>
    }
  }
}
