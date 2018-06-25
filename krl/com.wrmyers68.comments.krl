ruleset com.wrmyers68.comments {
  meta {
    provides reports
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "comments", "type": "new", "attrs": [ "date", "from", "text" ] }
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
      from = event:attr("from");
      text = event:attr("text");
    }
    if from && text then noop();
    fired {
      ent:reports := ent:reports.append({
        "date":date, "from": from, "text": text
      });
    }
  }
}
