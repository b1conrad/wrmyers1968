ruleset com.bruceatbyu.graduands_collection {
  meta {
    use module io.picolabs.wrangler alias wrangler
    provides grads
    shares __testing, import, graduands_page, grad_page, pageCounts
    , Tx, all_comments
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 , { "name": "import", "args": [ "url" ] }
                 , { "name": "graduands_page" }
                 , { "name": "pageCounts" }
                 , { "name": "Tx", "args": [ "grad" ] }
                 , { "name": "all_comments", "args": [ "grad" ] }
                 ]
    ,
      "events": [ { "domain": "graduands_collection", "type": "csv_available", "attrs": [ "url" ] }
                ]
    }
    grads = function(){
      ent:graduands
    }
    hall_of_fame = function(hf) {
      hf.replace(re#"#g,"").split(re#, #)
    }
    graduand_map = function(line) {
      parts = line.extract(re#^([\w ]+),(\w+),(\d+),(\d+),(.*)$#);
      { "fn": parts[0],
        "ln": parts[1],
        "id": parts[2].as("Number")*10 + parts[3].as("Number"),
        "hf": parts[4] => hall_of_fame(parts[4]) | null
      }.filter(function(v,k){v})
    }
    import = function(url) {
      newline = (13.chr() + "?" + 10.chr()).as("RegExp");
      http:get(url){"content"}.split(newline)
        .tail()
        .filter(function(s){s})
        .map(function(s){graduand_map(s)})
    }
    grad_option = function(grad) {
      <<    <option value="g#{grad{"id"}}">#{grad{"fn"}} #{grad{"ln"}}</option>
>>
    }
    grad_select = function() {
      <<  <select name="grad">
#{ent:graduands.values().map(function(g){grad_option(g)}).join("")}  </select>
>>
    }
    grad_form = function() {
      <<<form action="grad_page.html">
#{grad_select()}  <input type="submit" value="grad">
</form>
>>
    }
    graduands_page = function() {
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>W. R. Myers 1968 Graduands</title>
<link rel="icon" type="image/png" href="http://wrmyers68.com/68.png">
</head>
<body>
#{grad_form()}</body>
</html>
>>
    }
    Tx = function(grad) {
      map = (ent:graduands{grad}).klog("map");
      map{"Tx"}.klog("Tx")
    }
    imagesURI = "http://wrmyers68.com/images";
    grad_page = function(grad) {
      map = ent:graduands{grad};
      name = <<#{map{"fn"}} #{map{"ln"}}>>;
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>#{name}</title>
<link rel="icon" type="image/png" href="http://wrmyers68.com/68.png">
</head>
<body>
<h1>#{name}</h1>
<img src="#{imagesURI}/#{map{"id"}}.png">
</body>
</html>
>>
    }
    pageCounts = function() {
      math_int = function(num) {
        val = num.as("String");
        dec = val.match(re#[.]#);
        dec => val.extract(re#(\d*)[.]\d*#)[0].as("Number") | num;
      };
      ent:graduands.values()
                   .collect(function(v){math_int(v{"id"}/10)})
                   .map(function(v,k){v.length()})
    }
    all_comments = function(grad){
      ent:graduands.map(function(v,k){v{"Tx"}})
                   .filter(function(v,k){v})
                   .map(function(v,k){
                     defaults = function(m){
                       m.put({"to": m{"to"} || k, "id": m{"id"} || "g266"})
                     };
                     r =wrangler:skyQuery(v,"com.wrmyers68.comments","reports");
                     r{"error"} => []
                                 | r.map(defaults)
                                    .filter(function(m){not grad || m{"id"}==grad})
                   })
                   .values()
                   .reduce(function(a,v){a.append(v)},[])
    }
  }
  rule intialization {
    select when wrangler ruleset_added where rids >< meta:rid
    if not ent:graduands then noop();
    fired {
      ent:graduands := {};
    }
  }
  rule import_graduands_collection {
    select when graduands_collection csv_available
    foreach import(event:attr("url")) setting(map)
    pre {
      key = "g" + (map{"id"}.as("String"));
    }
    fired {
      ent:graduands{key} := map;
    }
  }
  rule auto_accept {
    select when wrangler inbound_pending_subscription_added
    pre {
      key = event:attr("name");
      Tx = event:attr("Tx");
    }
    if ent:graduands >< key then noop();
    fired {
      raise wrangler event "pending_subscription_approval"
        attributes event:attrs;
      ent:graduands{[key,"Tx"]} := Tx;
    }
  }
  rule record_latest_report {
    select when graduands_collection latest_comment
      id re#(g\d{3})# to re#(g\d{3})# setting(id,to)
    pre {
      time = event:attr("date");
    }
    fired {
      ent:graduands{[id,"rf"]} := time;
      ent:graduands{[to,"rt"]} := time;
    }
  }
}
