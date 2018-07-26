ruleset com.wrmyers68.grad {
  meta {
    use module com.wrmyers68.profile alias profile
    use module com.wrmyers68.comments alias comments
    shares __testing, grad_page, hall_of_fame
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 , { "name": "hall_of_fame" }
                 ],
      "events": [ {"domain":"grad","type":"init", "attrs":["id","name"]}
                , {"domain":"grad","type":"new_graduands_wellKnown_Tx","attrs":["Tx"]}
                ]
    }
    hall_of_fame = function(){
      ent:hf.isnull() => ""
                       | <<<p class="hf">#{ent:hf.join(", ")}</p>
>>
    }
    commentHTML = function(comment){
      date = comment{"date"};
      <<<fieldset>
<legend>
reported by #{comment{"from"}},
<span title="#{date}">
<script type="text/javascript">document.write(humanized_time_span("#{date}"))</script>
</span>
</legend>
#{comment{"text"}}
</fieldset>
>>
    }
    suite = function() {
      comments:reports()
        .filter(function(r){r{"date"}})
        .map(function(r){commentHTML(r)})
        .join("")
    }
    extras = function(pname){
      <<<fieldset id="login">
<legend>login to comment</legend>
<form>
<input placeholder="personal identifier DID" name="owner_id" size="30">
<input type="submit" value="identify">
</form>
</fieldset>
<fieldset id="comment" class="hidden">
<legend>comment or report as <span id="reporter"></span>
 (<button class="logout">logout</button>)</legend>
<form>
<input type="hidden" name="did" value="#{meta:eci}">
<input type="hidden" name="to" value="#{ent:id}">
<input type="hidden" name="from">
<input type="hidden" name="id">
<div id="container">
<textarea id="report" placeholder="report" name="text" rows="4" maxlength="280" required></textarea>
<div class="hidden">remaining: <span id="remaining"></span></div>
</div>
<input type="submit" value="submit">
</form>
</fieldset>
<fieldset id="rename" class="hidden">
<legend>change my name (<button class="logout">logout</button>)</legend>
<form>
<input type="hidden" name="id" value="#{ent:id}">
<input placeholder="preferred name" name="name" value="#{pname}" size="30">
<input type="submit" value="change">
</form>
</fieldset>
>>
    }
    imagesURI = "http://wrmyers68.com/images";
    grad_page = function() {
      id = ent:id.substr(1);
      pname = profile:preferredName() || ent:name;
      name = pname != ent:name => pname | ent:name;
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>#{name}</title>
<link rel="icon" type="image/png" href="http://wrmyers68.com/68.png">
<link rel="stylesheet" href="http://wrmyers68.com/grad.css">
<script type="text/javascript" src="http://wrmyers68.com/humanized_time_span.js"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.0/jquery.min.js"></script>
<script type="text/javascript" src="http://wrmyers68.com/grad.js"></script>
</head>
<body>
<div id="hf_container">
<h1>#{name}</h1>
#{hall_of_fame()}</div>
<fieldset>
<legend>
from DAWN '68, p. #{id.substr(0,2)},
<span title="1968">
<script type="text/javascript">document.write(humanized_time_span("1968"))</script>
</span>
</legend>
<img src="#{imagesURI}/#{id}.png">
</fieldset>
#{suite()}#{extras(pname)}</body>
</html>
>>
    }
    login_channel = {"name":"login", "type":"secret"}
  }
  rule set_graduands_wellKnown_Tx {
    select when grad new_graduands_wellKnown_Tx Tx re#^(.+)$# setting(Tx)
    fired {
      app:graduands_wellKnown_Tx := Tx;
    }
  }

  rule initialize_on_install {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre {
      rs_attrs = event:attr("rs_attrs");
      name = rs_attrs{"name"};
      grad = rs_attrs{"grad"};
    }
    if rs_attrs && name && grad then noop();
    fired {
      ent:id := grad;
      ent:name := name;
      raise wrangler event "subscription"
        attributes {
          "wellKnown_Tx":app:graduands_wellKnown_Tx,
          "Rx_role":"member", "Tx_role":"collection",
          "name":grad, "channel_type":"subscription"
        };
      raise wrangler event "channel_creation_requested"
        attributes login_channel;
    }
  }

  rule initialize { // deprecated; was for manual use
    select when grad init
    if ent:id.isnull() && ent:name.isnull() then noop();
    fired {
      ent:id := event:attr("id");
      ent:name := event:attr("name");
    }
  }

  rule process_login {
    select when profile login
    send_directive("login ok",{
      "grad_id": ent:id,
      "grad_did": meta:eci,
      "grad_name": profile:preferredName() || ent:name
    })
  }
  rule record_hall_of_fame {
    select when grad has_hall_of_fame grad re#^(g\d{3})$# setting (grad)
    if grad == ent:id then noop();
    fired {
      ent:hf := event:attr("hf");
    }
  }
}
