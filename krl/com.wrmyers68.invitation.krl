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
      <<Hi #{name.split(re# #)[0]},
      
You're invited to add some information about your life during the last fifty years.

The link below will immediately place you on your page, where you can change 
your display name and add comments:

http://wrmyers68.com/#!#{gid}/did:npe:#{eci} 

From here, you can add some information to your own page, with each entry limited
to 280 characters, so make as many entries as you need. If you have something
longer, please send it to me and I'll publish it on wrmyers68.com for you.

There is a different link for each person. So, please don't share the 
link above with anyone else, but encourage others to visit your page at
http://wrmyers68.com/#/#{gid} and contact me for their own personal link.

Many thanks and best wishes,
Bruce>>
    }
  }
}
