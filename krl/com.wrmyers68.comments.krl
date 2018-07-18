ruleset com.wrmyers68.comments {
  meta {
    use module io.picolabs.subscription alias Subs
    use module com.wrmyers68.profile alias profile
    provides reports
    shares __testing, reports
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "reports" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "comments", "type": "new", "attrs": [ "date", "from", "id", "text", "to" ] }
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
      comment = {
        "date":date.replace(re#"#g," "),
        "from": from, "id": id, "text": text, "to": to
      };
    }
    if from && text && to==profile:id() then noop();
    fired {
      ent:reports := ent:reports.append(comment);
      raise comments event "comment_recorded" attributes comment;
    }
  }
  rule notify_of_latest_comment {
    select when comments comment_recorded
    pre {
      subs = Subs:established("Rx_role","member").head();
      eci = subs{"Tx"};
    }
    if eci then every {
      event:send({"eci":eci,
        "domain":"graduands_collection", "type": "latest_comment",
        "attrs": event:attrs
      })
    }
  }
}
