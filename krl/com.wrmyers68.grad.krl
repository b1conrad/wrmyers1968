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
    posts = function() {
      pname = profile:preferredName();
      pname => <<<h1>#{pname}</h1>
>> | ""
    }
    imagesURI = "http://wrmyers68.com/images";
    grad_page = function() {
      id = ent:id.substr(1);
      name = ent:name;
      <<<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>#{name}</title>
<link rel="icon" type="image/png" href="http://wrmyers68.com/68.png">
</head>
<body>
<h1>#{name}</h1>
<img src="#{imagesURI}/#{id"}.png">
#{posts()}</body>
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
