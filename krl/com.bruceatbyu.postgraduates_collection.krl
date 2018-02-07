ruleset com.bruceatbyu.postgraduates_collection {
  meta {
    shares __testing, import, postgraduates_page, postgrad_page, pageCounts
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 , { "name": "import", "args": [ "url" ] }
                 , { "name": "postgraduates_page" }
                 , { "name": "pageCounts" }
                 ]
    ,
      "events": [ { "domain": "postgraduates_collection", "type": "csv_available", "attrs": [ "url" ] }
                ]
    }
    postgraduate_map = function(line) {
      parts = line.extract(re#^([\w ]+),([\w ]+),(\d+),(\d+)$#);
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
        .map(function(s){postgraduate_map(s)})
    }
    postgrad_option = function(postgrad,key) {
      <<    <option value="#{key}">#{postgrad{"fn"}} #{postgrad{"ln"}}</option>
>>
    }
    postgrad_select = function() {
      <<  <select name="postgrad">
#{ent:postgraduates.map(function(g,k){postgrad_option(g,k)}).values().join("")}  </select>
>>
    }
    postgrad_form = function() {
      <<<form action="postgrad_page.html">
#{postgrad_select()}  <input type="submit" value="postgrad">
</form>
>>
    }
    postgraduates_page = function() {
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>W. R. Myers 1968 Postgraduates</title>
</head>
<body>
#{postgrad_form()}</body>
</html>
>>
    }
    postgrad_page = function(postgrad) {
      map = ent:postgraduates{postgrad};
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
    pageCounts = function() {
      ent:postgraduates.values()
                       .collect(function(v){math_int(v{"id"}/10)})
                       .map(function(v,k){v.length()})
    }
  }
  rule intialization {
    select when wrangler ruleset_added where rids >< meta:rid
    if not ent:postgraduates then noop();
    fired {
      ent:postgraduates := {};
      ent:last_row := 0;
      ent:last_num_on_row := 0;
    }
  }
  rule import_postgraduates_collection {
    select when postgraduates_collection csv_available
    foreach import(event:attr("url")) setting(map)
    pre {
      row = map{"id"};
      num_on_row = row == ent:last_row => ent:last_num_on_row + 1 | 1;
      key = "p" + row + num_on_row;
    }
    fired {
      ent:postgraduates{key} := map;
      ent:last_row := row;
      ent:last_row := 0 on final;
      ent:last_num_on_row := num_on_row;
      ent:last_num_on_row := 0 on final;
    }
  }
}
