ruleset com.bruceatbyu.graduands_collection {
  meta {
    shares __testing, import, graduands_page, grad_page, pageCounts
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 , { "name": "import", "args": [ "url" ] }
                 , { "name": "graduands_page" }
                 , { "name": "pageCounts" }
                 ]
    ,
      "events": [ { "domain": "graduands_collection", "type": "csv_available", "attrs": [ "url" ] }
                ]
    }
    hall_of_fame = function(hf) {
      hf.replace(re#^"#,"").replace(re#"$#,"").split(re#, #)
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
</head>
<body>
#{grad_form()}</body>
</html>
>>
    }
    grad_page = function(grad) {
      map = ent:graduands{grad};
      name = <<#{map{"fn"}} #{map{"ln"}}>>;
      raw = "https://raw.githubusercontent.com/b1conrad/wrmyers1968/master/images";
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>#{name}</title>
</head>
<body>
<h1>#{name}</h1>
<img src="#{raw}/#{map{"id"}}.png">
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
}
