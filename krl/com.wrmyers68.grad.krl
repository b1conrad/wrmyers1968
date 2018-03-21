ruleset com.wrmyers68.grad {
  meta {
    use module com.wrmyers68.profile alias profile
    shares __testing, grad_page
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 ],
      "events": [ {"domain":"grad","type":"init", "attrs":["id","name"]}
                ]
    }
    suite = function() {
      ""
    }
    imagesURI = "http://wrmyers68.com/images";
    grad_page = function() {
      id = ent:id.substr(1);
      pname = profile:preferredName();
      name = pname != ent:name => pname | ent:name;
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>#{name}</title>
<link rel="icon" type="image/png" href="http://wrmyers68.com/68.png">
<link rel="stylesheet" href="http://wrmyers68.com/grad.css">
<script type="text/javascript" src="http://wrmyers68.com/humanized_time_span.js"></script>
</head>
<body>
<h1>#{name}</h1>
<fieldset>
<legend>
from DAWN '68, p. #{id.substr(0,2)},
<span title="1968">
<script type="text/javascript">document.write(humanized_time_span("1968"))</script>
</span>
</legend>
<img src="#{imagesURI}/#{id}.png">
</fieldset>
#{suite()}</body>
</html>
>>
    }
  }
  rule initialize {
    select when grad init
    fired {
      ent:id := event:attr("id");
      ent:name := event:attr("name");
    }
  }
}
