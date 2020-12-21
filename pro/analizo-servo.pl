/* -*- Mode: Prolog -*- */
:- module(analizo_servo,
	  [ server/1,			% +Port
         daemon/0
	  ]).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
%:- use_module(library(http/http_server_files)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_parameters)). % reading post data
%%:- use_module(library(http/http_session)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_unix_daemon)).
%:- use_module(library(http/http_openid)).
:- use_module(library(http/http_path)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_open)).
%:- use_module(library(settings)).
:- use_module(library(xpath)).

:- multifile http:location/3.
:- dynamic   http:location/3.

% TODO: is http/http_error autoloaded?
% see http://www.swi-prolog.org/pldoc/man?section=http-debug

:- use_module(library(debug)).

:- use_module(analizilo).

:- debug(http(request)).
%:- debug(sercho(what)).
%:- debug(sercho(stats)).
%:- debug(openid(_)).

:- initialization(init).
:- initialization(help,main).
%%%%%%%%%%%:- thread_initialization(thread_init).

max_char(500000). % maksimuma longeco de analizenda teksto
    % pli bone mallongigu kaj postulu sendi alineojn anst. tutaj dokumentoj!

init :-
    set_prolog_flag(encoding,utf8).

:- current_prolog_flag(os_argv, Argv), writeln(Argv).
	  
user:file_search_path('web','../web').    
http:location(akrido,root(akrido),[]).

:- http_handler('/', http_redirect(moved,root(akrido)),[]).
% analizo akceptas parametron "teksto" kaj redonas la rezulton de la analizo same kiel nuda teksto
:- http_handler(root(analizo), analizo,[]). % [authentication(ajaxid)]).
% analinioj akceptas JSON kun po-linia analizaĵo kaj redonas kontrolendajn vortoj kun lininumeroj
:- http_handler(root(analinioj), analinioj,[]). % [authentication(ajaxid)]).
% proxy: legu retpaĝon de alia servilo (pro CORS tio ofte ne eblas rekte de la kliento!)
:- http_handler(root(http_proxy), http_proxy,[]). % [authentication(ajaxid)]).
% statikaj dosieroj por retpaĝa interfaco
:- http_handler(akrido(.), http_reply_from_files(web(.),[]),[prefix]). % [authentication(ajaxid)]).

help :-
    format('~`=t~51|~n'), 
    format('|               Analizo-Serĉo.~t~50||~n'),
    format('~`=t~51|~n~n'),
    format('Programo por lanĉi la Analizoserĉservon. Vi povas aŭ~n'),
    format('tajpi interage ĉe la prolog-interpretilo: ~n~n'),
    format('   server(8081). ~n~n'),
    format('por lanĉi la servon ĉe retpordo 8081;~n'),
    format('aŭ lanĉi ĝin kiel fona servo,~n'),
    format('t.e. demono, per la predikato "daemon".~n'),
    format('Vidu la tiucelan skripton "run-anasrv.sh".~n~n'),
    prolog.
	       
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

daemon :-
    http_daemon.


analizo(Request) :-
%%    ajax_auth(Request),
    max_char(MaxChr),
    http_parameters(Request,
	    [
	    teksto(Teksto, [length<MaxChr])
	    ]),
    format('Content-type: text/plain~n~n'),
    atomic_list_concat(Lines,'\n',Teksto),
    maplist(analizu_linion,Lines).
    % ni ne povas uzi concurrent_ dum ni skribas rekte al STDOUT!
    %concurrent_maplist(analizu_linion,Lines).


% legas JSON el Request, kiu enhavu objekton, kies
% parametroj estas lininombroj kaj la valoroj estas la
% teksto sur tiu linio
% krome povas enesti moduso: "kontrolendaj" por rericevi
% nur neĝuste analizitajn vorojn (eraroj kaj eblaj eraroj)
% apriore estas moduso: "komplete" por rericevi ĉiujn vortojn
% analizitaj/neanalizeblaj:
% { 1: "bla bla bla", 3: "eĥoŝanĝo", 10: "ĉiuĵaŭde kaj sabate", moduso: "kontrolendaj"}

analinioj(Request) :-
    debug(http(ana),'ANAlinioj ~q',[Request]),
    http_read_json(Request, json(JSON)),
    debug(http(ana),'ANAlinioj 2 ~q',[JSON]),
    %format('Content-type: text/plain~n~n'),
    once((
        selectchk(moduso=Mode,JSON,Lines)
        ;
        Lines = JSON, Mode=komplete
        )),
        concurrent_maplist(analizu_linion(Mode),Lines,Rezultoj),
    exclude(malplena,Rezultoj,Nemalplenaj),
    reply_json(json(Nemalplenaj)).

malplena(_=[]).

analizu_linion(Line) :-
    atom(Line),
    atom_codes(Line,Codes),
    analizu_tekston_kopie(Codes,[]), nl.

analizu_linion(Mode,N=Line,N=Rez) :-
    atom_codes(Line,Codes), %format('~w::',[N]),
    analizu_tekston_liste(Codes,[],RList),
    % redukto la rezulton al linioj kun kontrolendaj/eraraj vortoj 
    exclude(ana_ekskludo(Mode),RList,Rez).

% por ekskludi ĉiujn liniojn en la rezulto, kiuj ne entenas kontrolendajn aŭ eraroj/neanalizeblajn vortojn
ana_ekskludo(kontrolendaj,X) :- memberchk(X.takso,[bona,signo,nombro,mlg]).

http_proxy(Request) :-
    http_parameters(Request,
	    [
	    url(Url, [length<500])
        ]),
    debug(analizilo(proxy),'malfermonte ~q...',[Url]),
    http_open(Url,StreamIn,[status_code(Status),header(content_type,ContentType)]),!,
    debug(analizilo(proxy),'status: ~q, contentType: ~q',[Status,ContentType]),
    format('Content-type: ~w~n~n',[ContentType]),
    set_stream(StreamIn,encoding(utf8)),
    set_stream(current_output,encoding(utf8)),
    copy_stream_data(StreamIn, current_output),
    close(StreamIn).
    
