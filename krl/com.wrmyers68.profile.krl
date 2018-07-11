ruleset com.wrmyers68.profile {
  meta {
    provides id, preferredName, clear_HTML
    shares __testing, preferredName
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 , { "name": "preferredName" }
                 ],
      "events": [ {"domain":"profile","type":"new", "attrs":["id","name"]}
                ]
    }
    id = function(){
      ent:id
    }
    preferredName = function() {
      ent:preferredName
    }
    limit_length = function(s,l){
      s.length() <= l => s
                       | s.substr(0,l-1) + "…"
    }
    clear_HTML = function(input,max_length){
      cleaned = input.replace(re#<#g,"＜").replace(re#>#g,"＞");
      max_length => limit_length(cleaned,max_length)
                  | cleaned
    }
  }
  rule create_new_profile {
    select when profile new id re#^(g\d{3})$# setting(id)
    if ent:id.isnull() then noop();
    fired {
      ent:id := id;
      ent:preferredName := event:attr("name");
    }
  }

  rule update_profile {
    select when profile updated_profile
    pre {
      id = event:attr("id");
    }
    if id == ent:id then noop();
    fired {
      ent:preferredName := clear_HTML(event:attr("name"),60);
    }
  }
}
