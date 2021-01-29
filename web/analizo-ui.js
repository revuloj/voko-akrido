// alineo por ni finiĝas ĉe frazsigno antaŭ linirompo aŭ ĉe pluraj linirompoj
const eop = /([\.?!\n]+[ \t\r]*)\n+/g; 
// ĉe tro longaj alineoj ni enŝovos alineojn meze ĉe frazfinoj
const max_par_len = 1000; 
// ni limigas la longecon de analizebla teksto por ne "eterne" ŝargi la servilon
const max_sgn_ana = 500000;
// ni sendas analiz-petojn nur laŭ intervaloj al la servilo, por iom protekti gin de tro granda ŝarĝo
const time_between_req = 1200;

const eos = /([\.?!;:]+)[ \t]+/g;

when_doc_ready(
    function() { 
        //const submit = document.getElementById("analizo_submit");
        const form = document.getElementById("analizo_form");
        const shrg_btn = document.getElementById("url_shargi");
        const forg_btn = document.getElementById("analizo_forigu");
        const kash_box = document.getElementById("analizo_kashu");
        const form_url = form.getAttribute("action");
        //form.removeAttribute("action");

        /***********************************************************
        //   Sendi la tekston por analizo          
        /***********************************************************/

        form.addEventListener("submit", function(event) {
            event.preventDefault();
            document.getElementById("analizo_eraro").textContent = "";

            var viditaj = [];
            var signoj = 0;

            const teksto = document.getElementById("analizo_teksto").value;
            const rezulto = document.getElementById("analizo_rezulto");
            rezulto.innerHTML = "<ol></ol>";

            // Ni sendas la tekston alineo post alineo por pli rapide vidi unuajn
            // rezultojn...
            teksto.split(/[\.?! \t\r]+\n/).every(

              function (alineo,nro) {

                setTimeout(() => { // por indulgi la servilon
                    // ni sendas ĉiun alineon nur post nro sekundoj
                  HTTPRequest('POST', form_url, {
                    numero: (nro+1),
                    formato: 'html',
                    teksto: alineo
                  },
                  function(data) {
                      // Success!
                      const parser = new DOMParser();
                      const doc = parser.parseFromString("<li><p>"+data+"</p></li>","text/html");
                      const ol = rezulto.querySelector("ol");

                      // kaŝu ripetojn
                      if (document.getElementById("analizo_kashu").checked) {
                        for (let span of doc.body.querySelectorAll("span")) {
                          if (! span.classList.contains("nro")) {
                            if ( viditaj.indexOf(span.textContent) > 0 )
                              span.classList.add("hidden");
                            else
                              viditaj.push(span.textContent);
                          }
                        }
                      }

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
                  },  null, null, show_http_error);

                }, nro*time_between_req); // post (nro*time_between_req) ms ni sendas 
                              // la alineon por analizo - tio iom protektas la
                              // servilon kaj la retumilon de tro da samtempaj
                              // demandoj 
                // ni limigas la analizon al cirkaŭ miliono da signoj
                signoj += alineo.length;
                return (signoj < max_sgn_ana);
              }
            );
        });

        /***********************************************************
        // Ŝargi tekston de URL el la reto
        /***********************************************************/

        shrg_btn.addEventListener("click", function(event) {
          event.preventDefault();
          document.getElementById("analizo_eraro").textContent = "";

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
                /*
                const normalized = doc.body.innerText
                  .replace(/[\t ]+\n/g,"\n") // forigu spacojn antaŭ linirompoj
                  .replace(/\n\n+/g,"\n\n") // maksimume du sinsekvaj linirompoj
                  .replace(/([\.?!]\n)([^\n])/g,"$1\n$2"); // aldonu linirompon ĉe alineo
                  */
                teksto.value = alineoj(doc.body.innerText); // textContent enhavus ankaŭ skriptojn k.s.;
                const len = teksto.value.length;
                document.getElementById("analizo_eraro").textContent += "La teksto ampleksas " +
                  (len>9999? Math.round(len/1000)+ " mil" : len) +" signojn.";
                if (len > max_sgn_ana) {
                  document.getElementById("analizo_eraro").textContent +=
                    " Atentu, ke analiziĝos nur "+(max_sgn_ana/1000)+" mil unuajn signojn. " +
                    "Bv. dividu la tekston kaj analizu parton post parto.";
                }
            }, null, null, show_http_error);
          }
        });

        // Viŝu ĉion: URL-on, tekston, analizan rezulton
        forg_btn.addEventListener("click", function(event) {
          event.preventDefault();
            document.getElementById("analizo_url").value='';
            document.getElementById("analizo_teksto").value='';
            document.getElementById("analizo_rezulto").textContent='';
        });

        /***********************************************************
        // Kaŝi la oficialajn vortojn por elstarigi la kontrolendajn 
        // t.e. neoficialaj, dubindaj, eraraj, neanalizeblaj
        // kaj kaŝu ankaŭ ties ripetojn por ne tedi kontrolleganton
        // PLIBONIGU: se ni premas tion dum la analizo ni havas interferencon inter ambaŭ....
        /***********************************************************/
        kash_box.addEventListener("click", function(event) {
          const kashu = event.target.checked;
          const rezulto = document.getElementById("analizo_rezulto");

          if (kashu) {            
            rezulto.classList.add("hidden_text");
            // kaŝu ripetojn
            var viditaj = [];
            for (let span of rezulto.querySelectorAll("span")) {
              if ( viditaj.indexOf(span.textContent) > 0 )
                span.classList.add("hidden");
              else
                viditaj.push(span.textContent);
            }
          } else {
            rezulto.classList.remove("hidden_text");
            // malkaŝu ripetojn
            for (let span of rezulto.querySelectorAll(".hidden")) 
              span.classList.remove("hidden");
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

function show_http_error(request,response) {
  //console.log("HTTP ERROR:"+response);
  const err = document.getElementById("analizo_eraro");
  err.textContent="Eraro dum ŝargo de enhavo! ";

  if (response) {
    const json=JSON.parse(response);
    err.textContent += json.code + ": "+ json.message;
  } else {
    err.textContent += "Neniu respondo de la servilo!";
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
          if (onError) onError(this,this.response);
      }
      if (onFinish) onFinish();
    };
    
    request.onerror = function() {
      // konekteraro
      console.error('Eraro dum konektiĝo por ' + url);
      if (onError) onError(this,this.response);
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


// aldonu malplenajn liniojn ĉe alineoj
// kaj tro longajn alineojn devidu en plurajn
function alineoj(text) {
  var alineoj = [];
  var a, last = 0;

  //console.debug(text);

  function normalize(str) {
    //console.debug("str: "+str);
    return str
      .replace(/[\t ]+\n/g,"\n") // forigu spacojn antaŭ linirompoj
      .replace(/^([ \t]{4})[ \t]+/g,"$1") // maksimume 4 spacoj alinekomence
      .replace(/(\n[ \t]{4})[ \t]+/g,"$1") // maksimume 4 spacoj linikomence
      .replace(/[\s]*$/,"\n") // anst. finajn spacojn per sola linirompo
      //.replace(/\n\n+/g,"\n\n"); // maksimume du sinsekvaj linirompoj
  }

  function aldonu(aln) {
    if (aln.length > max_par_len) {
      sub_alineoj(aln);
    } else {
      //console.debug("aln: "+aln);
      if (/\w/.test(aln)) alineoj.push(aln);
    }
  }

  function sub_alineoj(long) { 
    var s, l=0;
    // trovu frazojn ĝis max_len kaj
    // tie kreu apartan alineon
    while (s = eos.exec(long)) {
      const e = s.index+s[0].length;
      if (e-l > max_par_len) {
        const sa = long.substring(l,e);
        alineoj.push(sa+"\n");
        l = e; 
      }
    }
    // aldonu reston
    alineoj.push(long.substring(l));
  }
  
  // trakuru la tekston serĉante alineojn...
  while (a = eop.exec(text)) {
    const ei = a.index+a[0].length;
    //console.debug("last: "+text.substr(last,20)+ "...\nei: "+text.substr(ei,20)+"...")
    aldonu(normalize(text.substring(last,ei)));
    last = ei;
  }
  
  // aldonu la reston
  aldonu(normalize(text.substring(last)));

  return alineoj.join("\n");
}

