$(function() {
  let url = new URL(window.location.href);
  var sRefresh = url.searchParams.get('q[auto_refresh_trigger]');
    if (sRefresh > 0 ){
      setTimeout(function(){location.reload(true)}, (sRefresh * 1000) );
    }
})