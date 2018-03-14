ruleset com.wrmyers68.profile {
  meta {
    shares __testing, preferredName
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 , { "name": "preferredName" }
                 ],
      "events": [ {"domain":"profile","type":"updated_profile", "attrs":["id","name"]}
                ]
    }
    preferredName = function() {
      ent:preferredName
    }
  }
  rule update_profile {
    select when profile updated_profile
    fired {
      ent:id := event:attr("id").defaultsTo(ent:id);
      ent:preferredName := event:attr("name");
    }
  }
}
