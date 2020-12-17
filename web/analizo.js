
when_doc_ready(
    function() { 
        //const submit = document.getElementById("analizo_submit");
        const form = document.getElementById("analizo_form");
        const url = form.getAttribute("action");
        //form.removeAttribute("action");

        form.addEventListener("submit", function(event) {
            event.preventDefault();

            const teksto = document.getElementById("analizo_teksto").value;
            HTTPRequest('POST', url, {
                    teksto: teksto
                },
                function(data) {
                    // Success!
                    const rezulto = document.getElementById("analizo_rezulto");
                    rezulto.textContent = "";

                    var parser = new DOMParser();
                    var doc = parser.parseFromString("<div>"+data+"</div>","text/html");
        
                    rezulto.append(...doc.body.children);
                });
        })
    }
);

// por prepari paĝon post kiam ĝi estas ŝargita
function when_doc_ready(onready_fn) {
    if (document.readyState != 'loading'){
      onready_fn();
    } else {
      document.addEventListener('DOMContentLoaded',  onready_fn);
    }
}

// ajax http request
function HTTPRequestFull(method, url, headers, params, onSuccess, 
    onStart, onFinish, onError) {  // onStart, onFinish, onError vi povas ellasi!

    var request = new XMLHttpRequest();
    var data = new FormData();

      // alpendigu aktualigilon por eventuale certigi freŝajn paĝojn
    function url_v() {
      var akt = window.localStorage.getItem("aktualigilo");
      akt = (akt && parseInt(akt)) || 0;

      if (akt) {
        const _url = url.split("#");

        if (_url[0].indexOf('?')>-1) {
          _url[0] += "&v="+akt;
        } else {
          _url[0] += "?v="+akt;
        }

        url = _url.join('#');
      }
    }

    // parametroj
    // PLIBONIGU: momente tio funkcias nur por POST, 
    // sed ĉe GET ni devus alpendigi tion al la URL!
    for (let [key, value] of Object.entries(params)) {
        data.append(key,value);
    }

    // alpendigu version por certigi freŝan paĝon
    if (method.toUpperCase() == "GET") {
      url_v();
    }

    if (onStart) onStart();
    request.open(method, url , true);

    // kapo-linioj
    if (headers) {
      for (let [key,value] of Object.entries(headers)) {
        request.setRequestHeader(key,value);
      }      
    }
    
    request.onload = function() {
      if (this.status >= 200 && this.status < 400) {
          onSuccess.call(this,this.response);
      } else {
          // post konektiĝo okazis eraro
          console.error('Eraro dum ŝargo de ' + url);  
          if (onError) onError(request);
      }
      if (onFinish) onFinish();
    };
    
    request.onerror = function() {
      // konekteraro
      console.error('Eraro dum konektiĝo por ' + url);
      if (onError) onError(request);
      if (onFinish) onFinish();
    };
    
    //request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
    request.send(data);  
}

function HTTPRequest(method, url, params, onSuccess, 
  onStart, onFinish, onError) {  // onStart, onFinish, onError vi povas ellasi!
    HTTPRequestFull(method, url, null, params, onSuccess, 
    onStart, onFinish, onError);
}


