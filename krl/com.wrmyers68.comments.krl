ruleset com.wrmyers68.comments {
  meta {
    use module io.picolabs.subscription alias Subs
    use module com.wrmyers68.profile alias profile
    provides reports
    shares __testing, reports, report
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "reports" }
      , { "name": "report", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "comments", "type": "restrict", "attrs": [ "key", "eci" ] }
      ]
    }
    reports = function(){
      ent:reports
    }
    report = function(key){
      ent:reports.filter(function(v,k){v{"date"}==key})
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
  rule delete_comment {
    select when comments restrict
      key re#^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[.]\d{3}Z)$#
      eci re#^([A-Za-z0-9]{21,22})$#
      setting(key,eci)
    pre {
      identity = function(x){x};
      index = ent:reports.reduce(function(a,v,i){
        v{"date"}==key => i | a
      }, -1);
      errs = [
        [index >= 0,        meta:eci == eci],
        ["no such message", "eci mismatch"]
      ].pairwise(function(c,m){c => "" | m}).klog("errs");
      ok = errs.none(identity);
      to_be_deleted = ok => ent:reports[index] | null;
    }
    if ok then noop()
    fired {
      ent:reports := ent:reports.splice(index,1);
      raise comments event "report_deleted"
        attributes ({"index":index,"report":to_be_deleted})
    } else {
      raise comments event "restrict_error"
        attributes event:attrs.put({"msg": errs.filter(identity).join("; ")});
    }
  }
  rule notify_of_deleted_comment {
    select when comments report_deleted index re#^(\d+)$# setting(index)
    pre {
      last = function(){
        len = ent:reports.length();
        len > 0 => ent:reports[len-1] | null
      }
      report = event:attr("report");
      subs = Subs:established("Rx_role","member").head();
      eci = subs{"Tx"};
    }
    every {
      send_directive("report_deleted",{"index":index,"report":report})
      event:send({"eci":eci,
        "domain":"graduands_collection", "type": "deleted_comment",
        "attrs": {"deleted":report,"latest":last()} })
      }
  }
  rule notify_of_deleted_comment_error {
    select when comments restrict_error
    send_directive("report_deletion_error",{"message":event:attr("msg")})
  }
}
