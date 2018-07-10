ruleset com.wrmyers68.comments {
  meta {
    use module com.wrmyers68.profile alias profile
    provides reports
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "comments", "type": "new", "attrs": [ "date", "from", "text", "to" ] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    reports = function(){
      ent:reports
    }
  }
  rule initialize {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    if ent:reports.isnull() then noop();
    fired {
      ent:reports := [];
    }
  }
  rule record_new_comment {
    select when comments new
    pre {
      date = event:attr("date") || time:now();
      from = profile:clear_HTML(event:attr("from"),60);
      id = event:attr("id").extract(re#^(g\d{3})$#)[0];
      text = profile:clear_HTML(event:attr("text"),280);
      to = event:attr("to");
    }
    if from && text && to==profile:id() then noop();
    fired {
      ent:reports := ent:reports.append({
        "date":date.replace(re#"#g,""), "from": from, "id": id, "text": text
      });
    }
  }
}
