/* -*- Mode: Prolog -*- */
:- module(analizo_servo,
	  [ server/1			% +Port
	  ]).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
%:- use_module(library(http/http_server_files)).
%:- use_module(library(http/http_files)).
:- use_module(library(http/http_parameters)). % reading post data
%%:- use_module(library(http/http_session)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_unix_daemon)).
%:- use_module(library(http/http_openid)).
:- use_module(library(http/http_path)).
:- use_module(library(http/html_write)).
%%:- use_module(library(http/http_open)).
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

init :-
    set_prolog_flag(encoding,utf8).
	  
%%http:location(cit,root(cit),[]).

:- http_handler('/', http_redirect(moved,root(.)),[]).
:- http_handler(root(analizo), analizo,[]). % [authentication(ajaxid)]).
:- http_handler(root(analinioj), analinioj,[]). % [authentication(ajaxid)]).


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
    http_parameters(Request,
	    [
	    teksto(Teksto, [length<150000])
	    ]),
    format('Content-type: text/plain~n~n'),
    atomic_list_concat(Lines,'\n',Teksto),
    maplist(analizu_linion,Lines).
    %concurrent_maplist(analizu_linion,Lines).

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
    maplist(analizu_linion(Mode),Lines,Rezultoj),
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
    exclude(ana_ekskludo(Mode),RList,Rez).

ana_ekskludo(kontrolendaj,X) :- memberchk(X.takso,[bona,signo,nombro,mlg]).
