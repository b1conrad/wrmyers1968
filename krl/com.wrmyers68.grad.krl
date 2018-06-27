ruleset com.wrmyers68.grad {
  meta {
    use module com.wrmyers68.profile alias profile
    use module com.wrmyers68.comments alias comments
    shares __testing, grad_page
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" }
                 ],
      "events": [ {"domain":"grad","type":"init", "attrs":["id","name"]}
                ]
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
<legend>to be reported by <span id="reporter"></span>, now</legend>
<form>
<input type="hidden" name="to" value="#{ent:id}">
<input type="hidden" name="name">
<textarea placeholder="comment" name="text" cols="30" rows="5"></textarea><br>
<button class="logout">logout</button>
<input type="submit" value="submit">
</form>
</fieldset>
<fieldset id="rename" class="hidden">
<legend>change my name</legend>
<form>
<input type="hidden" name="id">
<input placeholder="preferred name" name="name" value="#{pname}" size="30"><br>
<button class="logout">logout</button>
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
#{extras(pname)}</html>
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
