ruleset com.wrmyers68.profile {
  meta {
    provides preferredName
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
    preferredName = function() {
      ent:preferredName
    }
  }
  rule create_new_profile {
    select when profile new id re#^(g\d{3})$# setting(id)
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
    fired {
      ent:preferredName := event:attr("name");
    }
  }

  rule process_login {
    select when profile login
    send_directive("login ok",{
      "grad_id": ent:id,
      "grad_did": meta:eci,
      "grad_name": ent:preferredName
    })
  }
}
