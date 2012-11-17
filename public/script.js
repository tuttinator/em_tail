function onMessage(evt) {
  // console.log(evt.data);
  con = document.getElementById("console");
  con.innerHTML += evt.data;
  con.innerHTML += '<br />';
}
websocket = new WebSocket("ws://localhost:8081");
websocket.onmessage = function(evt) { onMessage(evt); };
