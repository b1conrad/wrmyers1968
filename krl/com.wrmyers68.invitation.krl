ruleset com.wrmyers68.invitation {
  meta {
    use module com.wrmyers68.profile alias profile
    shares __testing, invitation
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "invitation" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    invitation = function(){
      gid = profile:id();
      eci = engine:listChannels().filter(function(v){
        v{"name"}=="login" && v{"type"}=="secret"
      }).head(){"id"};
      name = profile:preferredName();
      <<This message is for #{name}.
      
The link below will immediately place you on your page and ready to comment:

http://wrmyers68.com/#!#{gid}/did:npe:#{eci} 

From here, you can add some information to your own page, with each entry limited
to 280 characters, so make as many entries as you need. I you have something
longer, please send it to me and I'll publish it on wrmyers68.com for you.

You're invited to add some information about your life during the last fifty years.

There is a different link for each person. So, please don't share this 
particular link with anyone else, but encourage others to visit 
http://wrmyers68.com and contact me for their own personal link.

Many thanks and best wishes,
Bruce>>
    }
  }
}
