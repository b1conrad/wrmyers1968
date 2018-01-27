ruleset com.bruceatbyu.graduands_collection {
  meta {
    shares __testing, import, graduands
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 , { "name": "import", "args": [ "url" ] }
                 , { "name": "graduands" }
                 ]
    ,
      "events": [ { "domain": "graduands_collection", "type": "csv_available", "attrs": [ "url" ] }
                ]
    }
    hall_of_fame = function(hf) {
      hf.replace(re#^"#,"").replace(re#"$#,"").split(re#, #)
    }
    graduand_map = function(line) {
      parts = line.extract(re#^([\w ]+),(\w+),(\d+),(.*)$#);
      { "fn": parts[0],
        "ln": parts[1],
        "pg": parts[2].as("Number"),
        "hf": parts[3] => hall_of_fame(parts[3]) | null
      }.filter(function(v,k){v})
    }
    import = function(url) {
      newline = (13.chr() + "?" + 10.chr()).as("RegExp");
      http:get(url){"content"}.split(newline)
        .tail()
        .filter(function(s){s})
        .map(function(s){graduand_map(s)})
    }
    graduands = function() {
      ent:graduands
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
      key = <<#{map{"fn"}} #{map{"ln"}}>>;
    }
    fired {
      ent:graduands{key} := map;
    }
  }
}
