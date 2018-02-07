ruleset com.bruceatbyu.undergraduates_collection {
  meta {
    shares __testing, import, undergraduates_page, undergrad_page, rowCounts
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 , { "name": "import", "args": [ "url" ] }
                 , { "name": "undergraduates_page" }
                 , { "name": "rowCounts" }
                 ]
    ,
      "events": [ { "domain": "undergraduates_collection", "type": "csv_available", "attrs": [ "url" ] }
                ]
    }
    undergraduate_map = function(line) {
      parts = line.extract(re#^([\w ]+),([\w ']+),(\d+),(\d+)$#);
      { "fn": parts[0],
        "ln": parts[1],
        "id": parts[2].as("Number")*10 + parts[3].as("Number")
      }.filter(function(v,k){v})
    }
    import = function(url) {
      newline = (13.chr() + "?" + 10.chr()).as("RegExp");
      http:get(url){"content"}.split(newline)
        .tail()
        .filter(function(s){s})
        .map(function(s){undergraduate_map(s)})
    }
    undergrad_option = function(undergrad,key) {
      <<    <option value="#{key}">#{undergrad{"fn"}} #{undergrad{"ln"}}</option>
>>
    }
    undergrad_select = function() {
      <<  <select name="undergrad">
#{ent:undergraduates.map(function(g,k){undergrad_option(g,k)}).values().join("")}  </select>
>>
    }
    undergrad_form = function() {
      <<<form action="undergrad_page.html">
#{undergrad_select()}  <input type="submit" value="undergrad">
</form>
>>
    }
    undergraduates_page = function() {
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>W. R. Myers 1968 Undergraduates</title>
</head>
<body>
#{undergrad_form()}</body>
</html>
>>
    }
    undergrad_page = function(undergrad) {
      map = ent:undergraduates{undergrad};
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
    math_int = function(num) {
      val = num.as("String");
      dec = val.match(re#[.]#);
      dec => val.extract(re#(\d*)[.]\d*#)[0].as("Number") | num;
    };
    rowCounts = function() {
      ent:undergraduates.values()
                        .collect(function(v){v{"id"}})
                        .map(function(v,k){v.length()})
    }
  }
  rule intialization {
    select when wrangler ruleset_added where rids >< meta:rid
    if not ent:undergraduates then noop();
    fired {
      ent:undergraduates := {};
      ent:last_row := 0;
      ent:last_num_on_row := 0;
    }
  }
  rule import_undergraduates_collection {
    select when undergraduates_collection csv_available
    foreach import(event:attr("url")) setting(map)
    pre {
      row = map{"id"};
      num_on_row = row == ent:last_row => ent:last_num_on_row + 1 | 1;
      key = "u" + row + num_on_row;
    }
    fired {
      ent:undergraduates{key} := map;
      ent:last_row := row;
      ent:last_row := 0 on final;
      ent:last_num_on_row := num_on_row;
      ent:last_num_on_row := 0 on final;
    }
  }
}
