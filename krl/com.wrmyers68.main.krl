ruleset com.wrmyers68.main {
  meta {
    use module com.bruceatbyu.graduands_collection alias grads
    use module io.picolabs.wrangler alias wrangler
    shares __testing, info
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "info", "args": [ "grad" ] }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    Tx = function(grad){
      eci = wrangler:children("Graduands Collection").head(){"eci"};
      r = wrangler:skyQuery(eci,"com.bruceatbyu.graduands_collection","Tx",{"grad":grad});
      r{"error"} => null | r
    }
    info = function(grad){
      g =grads:grads(){grad};
      name = g => [g{"fn"},g{"ln"}].join(" ") | null;
      {"Tx":Tx(grad), "name":name, "grad":grad}
    }
    grad_rids = [
      "io.picolabs.logging",
      "com.wrmyers68.profile","com.wrmyers68.comments","com.wrmyers68.grad",
      "io.picolabs.subscription"
    ]
  }
  rule create_new_owner_pico {
    select when main need_owner_pico
    pre {
      grad = event:attr("gid");
      child_specs = info(grad);
    }
    if child_specs && child_specs{"Tx"}.isnull() then every {
      event:send({"eci":wrangler:parent_eci(),
        "domain": "owner", "type": "creation",
        "attrs": child_specs.put({"rids":grad_rids})
      });
    }
  }
}
