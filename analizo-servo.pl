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

% difinu la aplikaĵon "redaktilo"
%%:- use_module(agordo).
%%:- use_module(redaktilo_auth).
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
/*    
    agordo:get_config([
	 http_cit_root(AppRoot),
%	 web_dir(WebDir),
%	 voko_dir(VokoDir),
	 http_cit_scheme(Scheme),
	 http_cit_host(Host),
	 http_cit_port(Port),
	 http_session_timeout(Timeout)
	]),
    set_setting(http:prefix,AppRoot),
    set_setting(http:public_scheme,Scheme),
    set_setting(http:public_port,Port),
    set_setting(http:public_host,Host),
    http_set_session_options([
	cookie(redaktilo_seanco),
	timeout(Timeout),
	path(AppRoot)
	])
    .init*/ 

    % la lokaj dosierujoj el kiuj servi dosierojn
%    assert(user:file_search_path(web,WebDir)),
%    assert(user:file_search_path(static,web(static)))
%    assert(user:file_search_path(voko,VokoDir)),

	  
%%http:location(cit,root(cit),[]).

% redirect from / to /citajhoj/, when behind a proxy, this is a task for the proxy
:- http_handler('/', http_redirect(moved,root(.)),[]).
%%:- http_handler(root(.), http_redirect(moved,root('cit/')),[]).
%:- http_handler(cit(.), reply_files, [prefix,authentication(openid)]).
%:- http_handler(static(.), reply_static_files, [prefix]).

%:- http_handler(red(revo_bibliogr), revo_bibliogr, []).
:- http_handler(root(analizo), analizo,[]). % [authentication(ajaxid)]).



help :-
    format('~`=t~51|~n'), 
    format('|               Analizo-Serĉo.~t~50||~n'),
    format('~`=t~51|~n~n'),
    format('Programo por lanĉi la Analizoserĉservon. Vi povas aŭ~n'),
    format('tajpi interage ĉe la prolog-interpretilo: ~n~n'),
    format('   server(8000) ~n~n'),
    format('por lanĉi la servon ĉe retpordo 8000;~n'),
    format('aŭ lanĉi ĝin kiel fona servo,~n'),
    format('t.e. demono, per la predikato "daemon".~n'),
    format('Vidu la tiucelan skripton "run-search.sh".~n~n'),
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

/*
analizu_liniojn_([]).
analizu_liniojn_([Line|Lines]) :-
    atom_codes(Line,Codes),
    analizu_tekston_kopie(Codes,[]), nl,
    analizu_liniojn_(Lines).
*/

analizu_linion(Line) :-
    atom_codes(Line,Codes),
    analizu_tekston_kopie(Codes,[]), nl.
