
when_doc_ready(
    function() { 
        //const submit = document.getElementById("analizo_submit");
        const form = document.getElementById("analizo_form");
        const shrg_btn = document.getElementById("url_shargi");
        const forg_btn = document.getElementById("analizo_forigu");
        const kash_box = document.getElementById("analizo_kashu");
        const form_url = form.getAttribute("action");
        //form.removeAttribute("action");

        // Sendi la tekston por analizo
        form.addEventListener("submit", function(event) {
            event.preventDefault();

            const teksto = document.getElementById("analizo_teksto").value;
            const rezulto = document.getElementById("analizo_rezulto");
            rezulto.innerHTML = "<ol></ol>";

            // Ni sendas la tekston alieno post alineo por pli rapide vidi unuajn
            // rezultojn...
            teksto.split(/[\.?! \t]+\n/).map(
              function (alineo,nro) {
                HTTPRequest('POST', form_url, {
                  numero: (nro+1),
                  teksto: alineo
                },
                function(data) {
                    // Success!
                    const parser = new DOMParser();
                    const doc = parser.parseFromString("<li><p>"+data+"</p></li>","text/html");
                    const ol = rezulto.querySelector("ol");
                    // elprenu la numeron el la rezulto kaj metu kiel li@value
                    const li = doc.body.querySelector("li");
                    if (li) {
                      const span = li.querySelector("span.nro");
                      if (span) {
                        li.setAttribute("value",span.textContent);
                        span.remove(); 

                        const nro = parseInt(span.textContent);
                        // trovu la ĝustan lokon por enŝovi

                        for (let l_ of ol.querySelectorAll("li")) {
                          const v = parseInt(l_.getAttribute("value"));
                          if (v && v > nro) {
                            ol.insertBefore(li,l_);
                            return;
                          }
                        }
                      } 
                    }
                    // en ĉiuj aliaj kazoj: unua aŭ lasta elemento, neniu n-ro
                    // simple alepndigu ĉion en la fino
                    rezulto.querySelector("ol").append(...doc.body.children);
                });
              }
            );
        });

        // Ŝargi tekston de URL el la reto
        shrg_btn.addEventListener("click", function(event) {
          event.preventDefault();

          const url = document.getElementById("analizo_url").value;
          if (url) {
            HTTPRequest('POST', "/http_proxy", {
              url: url
            },
            function(data) {
                // Success!
                var parser = new DOMParser();
                var doc = parser.parseFromString(data,"text/html");
                const teksto = document.getElementById("analizo_teksto");
                const normalized = doc.body.innerText // textContent enhavus ankaŭ skriptojn k.s.
                  .replace(/[\t ]+\n/g,"\n") // forigu spacojn antaŭ linirompoj
                  .replace(/\n\n+/g,"\n\n") // maksimume du sinsekvaj linirompoj
                  .replace(/([\.?!]\n)([^\n])/g,"\1\n\2"); // aldonu linirompon ĉe alineo
                teksto.value = normalized;
            });
          }
        });

        // Viŝu ĉion: URL-on, tekston, analizan rezulton
        forg_btn.addEventListener("click", function(event) {
          event.preventDefault();
            document.getElementById("analizo_url").value='';
            document.getElementById("analizo_teksto").value='';
            document.getElementById("analizo_rezulto").textContent='';
        });

        // Kaŝi la oficialajn vortojn por elstarigi la kontrolendajn 
        // t.e. neoficialaj, dubindaj, eraraj, neanalizeblaj
        kash_box.addEventListener("click", function(event) {
          const kashu = event.target.checked;
          const rezulto = document.getElementById("analizo_rezulto");

          if (kashu) {
            rezulto.classList.add("hidden_text");
          } else {
            rezulto.classList.remove("hidden_text");
          }
        });
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


