/* -*- Mode: Prolog -*- */

%:- use_module(library(http/http_error)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http_json)).

:- use_module(library(debug)).

:- initialization(init).

init :-
    server(9999),
    debug(ana).
	  
% analinioj normally expects JSON, method GET we would
% expect domain_error(method, Method)
% according to https://www.swi-prolog.org/pldoc/doc_for?object=http_read_json/3

% ok: curl -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:9999/analinioj
% ok: curl -X POST -d '' http://localhost:9999/analinioj
% nok: curl http://localhost:9999/analinioj

:- http_handler(root(analinioj), analinioj,[]). 
	      
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

analinioj(Request) :-
    debug(ana,'ANA ~q',[Request]),
    catch(
        (
            http_read_json(Request, json(JSON)),
            debug(ana,'ANA 2 ~q',[JSON]),    
            reply_json(json([status=ok]))
        ),
        E,
        (
            debug(ana,'ANA exc ~q',[E]),
            reply_json(json([status=exc]))
        )
    ).

