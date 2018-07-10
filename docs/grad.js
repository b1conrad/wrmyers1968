$(document).ready(function() {
  var formToJSON = function(form){
    var json = {};
    $.each($(form).serializeArray(), function(key, elm){
      json[elm.name] = elm.value;
    });
    return json;
  };
  var page_about_grad = {
    "id": $("#comment").find("input[name=to]").val(),
    "eci": $("#comment").find("input[name=did]").val(),
    "name": $("#rename").find("input[name=name]").val()
  };
  var logged_in_grad = {
    "id": sessionStorage.getItem("grad_id"),
    "eci": sessionStorage.getItem("grad_did"),
    "name": sessionStorage.getItem("grad_name")
  };
  if(logged_in_grad.id && logged_in_grad.name){
    $("#reporter").text(logged_in_grad.name);
    $("#login").addClass("hidden");
    $("#comment").removeClass("hidden");
    $("#comment").find("input[name=from]").val(logged_in_grad.name);
    $("#comment").find("input[name=id]").val(logged_in_grad.id);
    if(logged_in_grad.id===page_about_grad.id){
      $("#rename").removeClass("hidden");
    }
  }
  var performLogin = function(options,grad_needs_time){
    sessionStorage.setItem("grad_id",options.grad_id);
    sessionStorage.setItem("grad_did",options.grad_did);
    sessionStorage.setItem("grad_name",options.grad_name);
    if(!grad_needs_time){
      location.reload();
    }
  };
  $("#login form").bind("submit",function(e){
    e.preventDefault();
    var did = $(this).find("input").val();
    var action = "http://wrmyers68.com:3002/sky/event/"+did+"/none/profile/login";
    $.getJSON(action,function(data){
      if(data && data.directives && data.directives[0]){
        var d=data.directives[0];
        performLogin(d.options);
      }else{
        alert(JSON.stringify(data));
      }
    });
  });
  $(".logout").bind("click",function(e){
    e.preventDefault();
    sessionStorage.removeItem("grad_id");
    sessionStorage.removeItem("grad_did");
    sessionStorage.removeItem("grad_name");
    location.reload();
  });
  $("#rename form").bind("submit",function(e){
    e.preventDefault();
    var did = logged_in_grad.eci;
    var action = "http://wrmyers68.com:3002/sky/event/"+did+"/none/profile/updated_profile";
    $.getJSON(action,formToJSON(this),function(data){
      if(data && data.directives){
        location.reload();
      }else{
        alert(JSON.stringify(data));
      }
    });
  });
  $("#comment form").bind("submit",function(e){
    e.preventDefault();
    var did = page_about_grad.eci;
    var action = "http://wrmyers68.com:3002/sky/event/"+did+"/none/comments/new";
    $.getJSON(action,formToJSON(this),function(data){
      if(data && data.directives){
        location.reload();
      }else{
        alert(JSON.stringify(data));
      }
    });
  });
});
