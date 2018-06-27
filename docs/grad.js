$(document).ready(function() {
  var page_about_grad = {
    "id": $("#comment").find("input[name=to]").val()
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
    $("#comment").find("input[name=name]").val(logged_in_grad.name);
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
  $("#logout").bind("click",function(e){
    e.preventDefault();
    sessionStorage.removeItem("grad_id");
    sessionStorage.removeItem("grad_did");
    sessionStorage.removeItem("grad_name");
    location.reload();
  });
});
