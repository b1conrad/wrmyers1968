ruleset com.wrmyers68.nametag {
  meta {
    use module com.wrmyers68.profile alias profile
    shares __testing, nametag
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "nametag", "type": "name_provided", "attrs": [ "name" ] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    imagesURI = "http://wrmyers68.com/images";
    nametag = function(){
      gid = profile:id();
      id = gid.substr(1);
      name = ent:name || profile:preferredName();
      sized_name = name.length() <= 23 => name
        | name.extract(re#([^ ]*) (.*)#)
          .join(<<<span style="font-size:80%"> >>) + "</span>";
      <<<h1>#{sized_name}</h1>
<div class="grad">
<fieldset>
<legend>
<span>W. R. Myers class of 1968 50th reunion -- August 25, 2018</span>
</legend>
<img src="#{imagesURI}/#{id}.png" width="254" height="175">
<img src="#{imagesURI}/qr#{id}.png">
<div class="qrcode"></div>
</fieldset>
<span class="url">http://wrmyers68.com/#{id}</span>
</div>
>>
    }
  }

  rule record_provided_name {
    select when nametag name_provided
    fired {
      ent:name := event:attr("name");
    }
  }
}
