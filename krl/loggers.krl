ruleset loggers {
  meta {
    use module com.bruceatbyu.graduands_collection alias g
    shares __testing, logger, loggers
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "loggers" }
      , { "name": "logger", "args": [ "id" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    logger = function(id){
      grad = "g"+id;
      entry = g:grads(){grad};
      pico_id = engine:getPicoIDByECI(entry{"Tx"});
      engine:listInstalledRIDs(pico_id) >< "io.picolabs.logging"
    }
    loggers = function(){
      g:grads()
        .values()
        .filter(function(x){
          pico_id = engine:getPicoIDByECI(x{"Tx"});
          engine:listInstalledRIDs(pico_id) >< "io.picolabs.logging"
        })
    }
  }
}
