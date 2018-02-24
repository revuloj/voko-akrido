/* -*- Mode: Prolog -*- */

:- use_module(library(sgml)).
:- use_module(library(xpath)).
:- use_module(library(semweb/rdf_db)).

:- dynamic fak_difino/4, kls_difino/4.

revo_xml('/home/revo/revo/xml/*.xml').
voko_rdf_klasoj('/home/revo/voko/owl/voko.rdf').

:- rdf_register_prefix(voko,'http://purl.org/net/voko#').

/** <module> Kreilo de Revo-vortaro

  Kreas liston de Revo-difinoj klasigitaj laŭ fako kaj laŭ kategorio (vortklaso: urboj, muzikiloj ktp.)

  Por eltrovi vortspecojn kiel besto aŭ persono per referenco al Voko-klasoj
  necesas enlegi ilin el dosiero $VOKO/owl/voko.rdf antaŭ la traserĉado de la XML-artikoloj.

  La procedo antaŭsupozas, ke Voko-klasoj troviĝas en /home/revo/voko/owl,
  Revo-artikoloj en /home/revo/revo/xml kaj la rezulta vortaro iros al ./

  @author Wolfram Diestel
  @license GPL
  @year 2018
 */


% %%%%%%%%%
% bazaj predikatoj por traserĉi artikolojn pri markoj, klasoj, fakoj, difinoj kaj skribi ilin
% %%%%%%%%

revo_difinoj :-
  load_voko_classes, 
  revo_trasercho, 
  skribu.

%! revo_trasercho is det.
%

revo_trasercho :-
  (\+ sub_class(rabobestoj,bestoj) -> throw('chu vi shargis la voko-klasojn jam?'); true),

  retractall(fak_difino(_,_,_,_)),
  retractall(kls_difino(_,_,_,_)),

  revo_xml(Xml),
%  atom_concat(Pado,'/*.xml',XMLDosieroj),
  expand_file_name(Xml,Dosieroj),
 
  forall(
      member(Dosiero,Dosieroj),
      catch(
        (
          % format('~w -> ',[Dosiero]),
            revo_art(Dosiero) -> true
	 ;
  	    throw(eraro('ne trovis ĉion en artikolo'))
        ),
        Exc,
        handle_exception(Dosiero,Exc)
      )
   ).

%! skribu is det.
%

skribu :-
    export_facts_csv(fak_difino(fak,dif,mrk,kap)),
    export_facts_csv(kls_difino(kls,dif,mrk,kap)).

load_voko_classes :-
  rdf_retractall(_,_,_),
  voko_rdf_klasoj(RdfFile),
  rdf_load(RdfFile,[]),
  rdf_set_predicate(rdfs:subClassOf,transitive(true)).


%%%%%%%%%%
% helpaj predikatoj
%%%%%%%%%

sub_class(X,Class) :-
%  rdf_global_id(voko:X,VX),
  rdf_global_id(voko:Class,VClass),
  rdf_global_id(voko:X,VX),
  rdf_reachable(VX,rdfs:subClassOf,VClass).


handle_exception(Dosiero,Exception) :-
  once(
    (
      Exception = eraro(Eraro), format('~w -> ERARO: ~w~n',[Dosiero,Eraro]);
      Exception = averto(Averto), format('~w -> AVERTO: ~w~n',[Dosiero,Averto])
    )
  ).

%! revo_art(+Dosiero).
%
% Trakuras XML-Revo-artikolon (DOM) kaj elkribras la
% bezonataj informojn kiel radiko, kapvorto, fako, klaso, difino.
% La rezulto estas faktoj, el kiuj poste kreiĝos la difinlistoj.

revo_art(Dosiero) :-
    load_xml_file(Dosiero,DOM),
    xpath(DOM,//kap(1),Kap),
    xpath(Kap,rad(normalize_space),Radiko),
    forall(revo_drv(DOM,Radiko),true).

revo_drv(DOM,Radiko) :-
  xpath(DOM,//drv,Drv),
  xpath(Drv,/drv(@mrk),Marko),

%%%  format('>>>drv: ~w~n',[Marko]),
  % traktu kapvorton
  xpath(Drv,kap,Kap),
  revo_kap(Kap,Radiko,Kapvorto),
   
  (revo_fak(Drv,Fako) -> true; Fako = ''),

  once((
    % derivaĵo havas sencojn -> traktu nur tiujn	      
    forall(revo_snc(Drv,Marko,Radiko,Kapvorto,Fako),true)

    ;

    % se ne estas sencoj difino estas rekte en drv...
    xpath(Drv,dif(content),Difino),
    % eltrovu la vortspecon de la radiko 
    % per voko-klaso, gramatika etikedo aŭ finaĵo
    (revo_kls(Drv,Klaso) -> true; Klaso = ''),
    
    % debug
    format('~w kap:~w fak:~w kls:~w dif:~w~n',[Marko,Kapvorto,Fako,Klaso]),

    (Fako \= '' -> assertz(fak_difino(Fako,Difino,Marko,Kapvorto)); true),
    (Klaso \= '' -> assertz(kls_difino(Klaso,Difino,Marko,Kapvorto)); true)
  )).
    

revo_snc(Drv,DrvMrk,Radiko,Kapvorto,DrvFako) :-
  xpath(Drv,//snc,Snc),
  (
      xpath(Snc,/snc(@mrk),Marko) -> true %%%, format('>>>snc: ~w~n',[Marko])
   ;
      Marko = DrvMrk %%%, format('>>>snc sen mrk~n')
  ),
  
  xpath(Snc,dif,Dif),
  revo_dif(Dif,Radiko,Difino),

  % eltrovu la vortspecon de la radiko 
  % per voko-klaso, gramatika etikedo aŭ finaĵo
  (revo_kls(Snc,Klaso) -> true; Klaso = ''),
  (revo_fak(Snc,Fako) -> true; Fako = DrvFako),
  
  % debug
  format('~w kap:~w fak:~w kls:~w dif:~w~n',[Marko,Kapvorto,Fako,Klaso,Difino]),

  (Fako \= '' -> assertz(fak_difino(Fako,Difino,Marko,Kapvorto)); true),
  (Klaso \= '' -> assertz(kls_difino(Klaso,Difino,Marko,Kapvorto)); true).

revo_kls(Drv,Klaso) :-
  xpath(Drv,//ref(@lst),Kls),
  sub_atom(Kls,5,_,0,Klaso).

revo_fak(Drv,Fako) :-
  xpath(Drv,uzo(@tip=fak,text),Fako).


revo_kap(Kap,Radiko,Kapvorto) :-
    xpath(Kap,/kap(content),L),
    kapvorto(L,Radiko,L1),
    atomic_list_concat(L1,K),
    normalize_space(atom(Kapvorto),K).

kapvorto([],_,[]).
kapvorto([A|Rest],Rad,Kap) :- atom(A), sub_atom(A,0,1,_,','), !, kapvorto(Rest,Rad,Kap). % ignoru kio venas post komo
kapvorto([A|Rest],Rad,[A|Kap]) :- atom(A), !, kapvorto(Rest,Rad,Kap).
% KOREKTU: tld majusklo: lit="M" ne jam traktata
kapvorto([element(tld,_,_)|Rest],Rad,[Rad|Kap]) :- !, kapvorto(Rest,Rad,Kap).
kapvorto([_|Rest],Rad,Kap) :- kapvorto(Rest,Rad,Kap). % ignoru aliajn elementojn kiel ofc, fnt, var


revo_dif(Dif,Radiko,Difino) :-
    xpath(Dif,/dif(content),L),
    exclude(is_elm(ekz),L,L1),
    content(L1,Radiko,L2),
    atomic_list_concat(L2,D),
    normalize_space(atom(Difino),D).

is_elm(Elm,element(Elm,_,_)).
content([],_,[]).
content([A|Rest],Rad,[A|Content]) :- atom(A), !, content(Rest,Rad,Content).
content([element(tld,_,_)|Rest],Rad,[Rad|Content]) :- !, content(Rest,Rad,Content).
content([element(_,_,Cnt)|Rest],Rad,Content) :-
    content(Cnt,Rad,Cnt1),
    content(Rest,Rad,Cnt2),
    append(Cnt1,Cnt2,Content).
    
    
test(X) :- 
 xpath(element(kap, [], ['\n  ', element(rad, [], [abaĵur]), '/o ', element(fnt, [], [element(bib, [], [...])]), '\n']), self, X).

  
export_facts_csv(FunctorTemplate) :-
  functor(FunctorTemplate,Predicate,Arity),
  atomic_list_concat([Predicate,'.csv'],ExportFile),
  format('~nwriting all facts ~w/~w to ~w...~n',[Predicate,Arity,ExportFile]),

  setup_call_cleanup(
    open(ExportFile, write, Out),
        (
          % write CSV column headers
          csv_write_stream(Out, [FunctorTemplate], [functor(Predicate),arity(Arity),separator(0';)]),
          % query data and write on fact per line
      functor(Goal,Predicate,Arity),  
      forall(call(Goal),
            ( 
                  format(atom(Fact),'~k.~n',Goal),
                  atom_to_term(Fact,Row,[]),
                  csv_write_stream(Out,[Row],[functor(Predicate),arity(Arity),separator(0';)]) 
                )
      )
        ),
        close(Out)
  ).
