:- module(revo_radikoj,[
	      revo_radikaro/0
	  ]).

:- use_module(library(sgml)).
:- use_module(library(xpath)).
:- use_module(library(semweb/rdf_db)).

:- dynamic radiko/3, evi/2, mlg/1, nr/3, nr_/3, vorto/3.
:- multifile r/3, v/3.

:-consult('vrt/v_esceptoj2.pl').
:-consult('vrt/v_mallongigoj.pl').
:-consult('vrt/v_vortoj.pl').
:-consult('vrt/v_radikoj.pl').
:-consult('vrt/v_elementoj.pl').


revo_xml('./xml/*.xml').
voko_rdf_klasoj('./owl/voko.rdf').
%revo_xml('/home/revo/revo/xml/*.xml').
%voko_rdf_klasoj('/home/revo/voko/owl/voko.rdf').

radik_dosiero('pro/revo/v_revo_radikoj.pl').
vort_dosiero('pro/revo/v_revo_vortoj.pl').
nomo_dosiero('pro/revo/v_revo_nomoj.pl').
evi_dosiero('pro/revo/v_revo_evitindaj.pl').
mlg_dosiero('pro/revo/v_revo_mallongigoj.pl').

:- rdf_register_prefix(voko,'http://purl.org/net/voko#').

/** <module> Kreilo de Revo-vortaro

  Kreas vortaron de Prolog-faktoj el XML-Revo-artikoloj.
  Rezulto estas la sekvaj dosieroj:

  * vrt/v_revo_radikoj.pl
  entenas radikojn en la formo =|r(hom,subst).|=

  * vrt/v_revo_vortoj.pl
  entenas vortetojn en la formo =|v(tus,intj).|=

  * vrt/v_revo_nomoj.pl
  entenas nomradikojn en la formo 
  =|nr('Zamenhof',pers).|= kaj =|nr_('zamenhof',pers).|=
  La minuskla formo enestas aldone pro uzado end derivado, ekz. zamenhof/a

  * vrt/v_revo_evitindaj.pl
  entenas evitindajn vortojn (markitaj per EVI en Revo)
  en la formo =|evi('agitator',"agitatoro").|=

  * vrt/v_revo_mallongigoj.pl
  entenas mallongigojn el Revo en la formo =|mlg('DNA').|=
  Ĝis nune la origina kapvorto, do la signifo de la mallongigo,
  ne estas skribata.

  Por eltrovi vortspecojn kiel besto aŭ persono per referenco al Voko-klasoj
  necesas enlegi ilin el dosiero $VOKO/owl/voko.rdf antaŭ la traserĉado de la XML-artikoloj.

  La predikato revo_radikaro/0 procedas ĉiujn tri paŝojn: legi la voko-klasojn, 
  traserĉi la artikolojn kaj skribi la rezulton.

  La procedo antaŭsupozas, ke Voko-klasoj troviĝas en /home/revo/voko/owl,
  Revo-artikoloj en /home/revo/revo/xml kaj la rezulta vortaro iros al ./vrt/

  @author Wolfram Diestel
  @license GPL
 */


% %%%%%%%%%
% bazaj predikatoj por traserĉi artikolojn pri radikoj kaj skribi ilin
% %%%%%%%%

helpo :- format('revo_radikaro :- load_voko_classes, revo_trasercho, skribu.').

%% revo_radikaro is det.
% 
% La predikato revo_radikaro/0 procedas tiujn tri paŝojn: legi la voko-klasojn, 
% traserĉi la artikolojn kaj skribi la rezulton.
%==
% revo_radikaro :-
%   load_voko_classes, 
%   revo_trasercho, 
%   skribu.
%==

revo_radikaro :-
  load_voko_classes, 
  revo_trasercho, 
  skribu.

%! revo_trasercho is det.
%

revo_trasercho :-
  (\+ sub_class(rabobestoj,bestoj) -> throw('chu vi shargis la voko-klasojn jam?'); true),

  retractall(radiko(_,_)),
  retractall(evi(_,_)),
  retractall(mlg(_)),

  revo_xml(Xml),
%  atom_concat(Pado,'/*.xml',XMLDosieroj),
  expand_file_name(Xml,Dosieroj),
 
  forall(
      member(Dosiero,Dosieroj),
      catch(
        (
          % format('~w -> ',[Dosiero]),
          once((
            revo_art(Dosiero)
            ;
            throw(eraro(ne_analizita))
          ))
        ),
        Exc,
        handle_exception(Dosiero,Exc)
      )
   ).

%! skribu is det.
%

skribu :-
  skribu_radikojn,
  skribu_vortojn,
  skribu_nomojn,
  skribu_mallongigojn,
  skribu_evitindajn.



skribu_radikojn :-
  radik_dosiero(Dos),
  format('skribas al ''~w''...~n',[Dos]),
  setup_call_cleanup(
    open(Dos,write,Out),
    skribu_radikojn(Out),
    close(Out)
  ).

skribu_radikojn(Out) :-
  setof(
    Rad-(Ofc,Spec), % ordigu oficialecon antaŭ vortspeco por havi '' post la oficialaj!
    radiko(Rad,Spec,Ofc),
    Chiuj),
  %keysort(Chiuj,Ordigitaj),
  reverse(Chiuj,Renversitaj),
  forall(
    member(R-(O_,S),Renversitaj), % renversu por ke "senil" analiziĝu antaŭ "sen/il" ktp.
    % format(Out,'r(''~w'',~w) --> "~w".~n',[R,S,R])
    (
      vrt_ofc(O_,O),
      once((
        r(R,S,O) % se estas en la baza vortaro ne skribu al revo-vortaro
        ;
        format(Out,'r(~q,~q,~q).~n',[R,S,O]) 
      ))
    )
  ).

skribu_vortojn :-
  vort_dosiero(Dos),
  format('skribas al ''~w''...~n',[Dos]),
  setup_call_cleanup(
    open(Dos,write,Out),
    skribu_vortojn(Out),
    close(Out)
  ).

skribu_vortojn(Out) :-
  setof(
    Vrt-(Ofc,Spec), % ordigu oficialecon antaŭ vortspeco por havi '' post la oficialaj!
    vorto(Vrt,Spec,Ofc),
    Chiuj),
  %keysort(Chiuj,Ordigitaj),
  reverse(Chiuj,Renversitaj),
  forall(
    member(V-(O_,S),Renversitaj), 
    (
      vrt_ofc(O_,O),
      once((
        v(V,S,O) % se estas en la baza vortaro ne skribu al revo-vortaro
        ;
        format(Out,'v(~q,~q,~q).~n',[V,S,O])  
      ))
    )
  ).

skribu_nomojn :-
  nomo_dosiero(Dos),
  format('skribas al ''~w''...~n',[Dos]),
  setup_call_cleanup(
    open(Dos,write,Out),
    (
      skribu_nomojn_maj(Out),
      skribu_nomojn_min(Out)
    ),
    close(Out)
  ).

skribu_nomojn_maj(Out) :-
  setof(
    Rad-(Ofc,Spec), % ordigu oficialecon antaŭ vortspeco por havi '' post la oficialaj!
    nr(Rad,Spec,Ofc),
    Chiuj),
  %keysort(Chiuj,Ordigitaj),
  reverse(Chiuj,Renversitaj),
  forall(
    member(R-(O_,S),Renversitaj),
    (
      vrt_ofc(O_,O),
      format(Out,'nr(~q,~q,~q).~n',[R,S,O])  
    )
  ).

skribu_nomojn_min(Out) :-
  setof(
    Rad-(Ofc,Spec), % ordigu oficialecon antaŭ vortspeco por havi '' post la oficialaj!
    nr_(Rad,Spec,Ofc),
    Chiuj),
  %keysort(Chiuj,Ordigitaj),
  reverse(Chiuj,Renversitaj),
  forall(
    member(R-(O_,S),Renversitaj), 
    (
      vrt_ofc(O_,O),
      format(Out,'nr_(~q,~q,~q).~n',[R,S,O])
    )
  ).

skribu_evitindajn :-
  evi_dosiero(Dos),
  format('skribas al ''~w''...~n',[Dos]),
  setup_call_cleanup(
    open(Dos,write,Out),
    skribu_evitindajn(Out),
    close(Out)
  ).

skribu_evitindajn(Out) :-
  forall(
    evi(Art,Vort),
    format(Out,'evi(''~w'',"~w").~n',[Art,Vort])
  ).

skribu_mallongigojn :-
  mlg_dosiero(Dos),
  format('skribas al ''~w''...~n',[Dos]),
  setup_call_cleanup(
    open(Dos,write,Out),
    skribu_mallongigojn(Out),
    close(Out)
  ).

skribu_mallongigojn(Out) :-
  forall(
    mlg(Mlg),
    format(Out,'mlg(~q).~n',[Mlg])
  ).

load_voko_classes :-
  % ial dufoje legi tion ne funkcias fidinde, do ni
  % faros nur, se bestoj ne jam troviĝas...
  sub_class(rabobestoj,bestoj)->true
  ;
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
% bezonataj informojn kiel radiko, vortspeco kaj mallongigoj.
% La rezulto estas faktoj, el kiuj poste kreiĝos la vortlistoj.
% Evitindaj radikoj kaj nomradikoj estas aparte traktitaj.

revo_art(Dosiero) :-
  load_xml_file(Dosiero,DOM),
  catch(
    (
      revo_rad(DOM,Radiko,Speco,Ofc),!, % enestu nur unu, 
                % do ni ne plu serĉas aliajn radikojn //art/kap/rad 
      revo_mlg(DOM,Mallongigoj),

      % ne jam preta, teste... var - TIEL NI TROVOS NUR UNU var! sed foje enestas du!
      once((
        revo_var(DOM,VarRad,VOfc) %, format('DBG var: ~w: ~w~n',[Dosiero,VarRad])
        ; true
      ))
          
      % format('~w (~w)~n',[Radiko,Speco]),
    ),
    Exc,
    (
      Exc = rad_evi(Radiko) 
        -> assert_evi(Dosiero,Radiko), throw(averto('EVI'))
        ; throw(Exc)
    )
  ),

  % memoru la rezulton de la analizo kiel faktoj
  assert_vorto(DOM,Radiko,Speco,Ofc),
  (nonvar(VarRad) -> assert_vorto(DOM,VarRad,Speco,VOfc); true),
  assert_mlg(Mallongigoj).


assert_vorto(DOM,Radiko,Speco,Ofc) :-
  %%assert_radiko(DOM,Radiko,Speco),
  ofc_vrt(Ofc,OVrt),!,

  once((
    % se temas pri majuskla nomo, registru 
    % kiel nomradiko, kaj ankau minuskle	
    nomo_majuskla(Radiko),
    assertz(nr(Radiko,Speco,OVrt)),
    assert_nomo_minuskla(Radiko,Speco,OVrt)
    ;
    % interjekciojn registru kiel vort(et)o
    Speco == intj,
    assertz(vorto(Radiko,Speco,OVrt))
    ;
    % normalaj radikoj
    assertz(radiko(Radiko,Speco,OVrt)),
    % se la radiko aldone uzighas kiel interjekcio...
    once((
      revo_intj(DOM,_),      
      assertz(vorto(Radiko,intj,OVrt))
      ;
      true
    ))
  )).

/**
assert_radiko(DOM,Radiko,Speco) :-
  once((
    % se temas pri majuskla nomo, registru 
    % kiel nomradiko, kaj ankau minuskle	
    nomo_majuskla(Radiko),
    assertz(nr(Radiko,Speco)),
    assert_nomo_minuskla(Radiko,Speco,Ofc)
    ;
    % interjekciojn registru kiel vort(et)o
    Speco == intj,
    assertz(vorto(Radiko,Speco))
    ;
    % normalaj radikoj
    assertz(radiko(Radiko,Speco)),
      % se la radiko aldone uzighas kiel interjekcio...
      once((
        revo_intj(DOM,_),
        assertz(vorto(Radiko,intj))
        ;
        true))
  )).
**/

assert_nomo_minuskla(Nomo,Speco,Ofc) :-
    atom_codes(Nomo,[K|Literoj]),
    upper_lower(K,M),
    atom_codes(MNomo,[M|Literoj]),
    ofc_vrt(Ofc,OVrt),!,
    assertz(nr_(MNomo,Speco,OVrt)).

assert_mlg(Mallongigoj) :-
    forall(
      member(Mlg,Mallongigoj),
      once((
        mlg(Mlg) % se jam enestas, ne re-registru !
        ;
        assertz(mlg(Mlg))
      ))
    ).
	  

assert_evi(Dosiero,Kap) :-
  % format('assert_evi(''~w'',~w).',[Dosiero,Kap]),
  once(
    (
      % konstruu la kapvorton el radiko kaj finaĵo
      xpath(Kap,rad(normalize_space),Radiko),
      xpath(Kap,/self(content),Content),
      (fin_text(Content,Fin) -> true; Fin=''),
      atom_concat(Radiko,Fin,Kapvorto),
      % elprenu la dosieronomon el la pado
      file_base_name(Dosiero,Dos),
      sub_atom(Dos,Len,_,_,'.xml'),
      sub_atom(Dos,_,Len,_,Nomo),
      % assertu evitindaĵon
      assertz(evi(Nomo,Kapvorto))
   )
 ).


revo_rad(DOM,Radiko,Speco,Ofc) :-
  xpath(DOM,//art/kap,Kap),
  xpath(Kap,rad(normalize_space),Radiko),
  atom_length(Radiko,L), 
  (L=<1 
    -> throw(averto('ellasante unuliteran radikon')) % ne akceptu radikojn unuliterajn
    ; true
  ),

  % ni bezonos la unua derivaĵon en la artikolo
  % por analizi EVI, vorspecon, klasojn
  xpath(DOM,//drv(1),Drv),

  % eltrovu la oficialecon
  once((
    xpath(Kap,ofc(normalize_space),Ofc)
    ;
  % evitindecon de neoficialaj vortoj (en drv[1] aŭ drv[1]/snc[1] ni tie notas kiel 'e')
    xpath(Drv,uzo(@tip=stl,text),'EVI'),
    Ofc = 'e'
    ;
    xpath(Drv,snc(1)/uzo(@tip=stl,text),'EVI'),
    Ofc = 'e'
    ;
    % nek oficiala nek evitinda:
    Ofc=''
  )),

  % eltrovu la vortspecon de la radiko 
  % per voko-klaso, gramatika etikedo aŭ finaĵo
  once(
    revo_kls(Drv,Speco);
    revo_gra(Drv,Speco);
    revo_fin(Kap,Speco);
    throw_netrovita(Radiko)
  ). 

throw_netrovita(Radiko) :-
  once((
    % estas en baza vortaro
    p(Radiko,_), 
    format(atom(Msg),'speco ne eltrovita, sed estas ~q- en baza vortaro',[Radiko]),
    throw(averto(Msg))
    ;
    s(Radiko,_,_), 
    format(atom(Msg),'speco ne eltrovita, sed estas -~q- en baza vortaro',[Radiko]),
    throw(averto(Msg))
    ;
    f(Radiko,_), 
    format(atom(Msg),'speco ne eltrovita, sed estas -~q en baza vortaro',[Radiko]),
    throw(averto(Msg))
    ;
    (v(Radiko,Speco,_);i(Radiko,Speco);u(Radiko,Speco)), 
    format(atom(Msg),'speco ne eltrovita, sed estas ~q,~q en baza vortaro',[Radiko,Speco]),
    throw(averto(Msg))
    ;
    r(Radiko,Speco,_), 
    format(atom(Msg),'speco ne eltrovita, sed estas ~q/,~q en baza vortaro',[Radiko,Speco]),
    throw(averto(Msg))
    ;
    % ne estas en baza vortaro
    format(atom(Msg),'speco de ''~w'' ne eltrovita, ellasante la vorton',[Radiko]),
    throw(eraro(Msg))
  )).

revo_kls(Drv,parc) :-
  xpath(Drv,//ref(@lst),Klaso),
  Klaso='voko:parencoj'. 

revo_kls(Drv,pers) :-
  xpath(Drv,//ref(@lst),Klaso),
  atom_concat('voko:',C,Klaso),
  sub_class(C,personoj).

revo_kls(Drv,best) :-
  xpath(Drv,//ref(@lst),Klaso),
  atom_concat('voko:',C,Klaso),
  sub_class(C,bestoj).

revo_gra(Drv,Speco) :-
  xpath(Drv,//gra/vspec(text),VSpeco),
  once(
    VSpeco = ntr -> Speco = ntr;
    VSpeco = tr -> Speco = tr;
    VSpeco = x -> Speco = tr;
    VSpeco = sufikso -> Speco = suf;
    VSpeco = prefikso -> Speco = pref;
    VSpeco = pronomo -> Speco = pron;
    VSpeco = sonimito -> Speco = intj;
    sub_atom(VSpeco,_,_,_,ekkrio) -> Speco = intj
  ).

revo_fin(Kap,Speco) :-
  xpath(Kap,/self(content),Content),
  fin_text(Content,Fin),
  once(
    Fin = i -> Speco = verb;
    Fin = o -> Speco = subst;
    Fin = a -> Speco = adj;
    Fin = e -> Speco = adv
  ).

fin_text(Elementoj,Fin) :-
  once(
  (
    member(El,Elementoj), 
    atom(El), 
    sub_atom(El,0,1,_,'/'),
    sub_atom(El,1,1,_,Fin)
  )).

revo_mlg(DOM,Mallongigoj) :-
  findall(
    Mlg,
    (
      xpath(DOM,//mlg(normalize_space),Mlg),
      % ignoru unusignajn kaj minusklajn mallongigojn
      atom_length(Mlg,L), L>1, nur_majuskloj(Mlg)
    ),
    Mallongigoj
  ).

revo_var(DOM,VarRad,Ofc) :-
  xpath(DOM,//art/kap/var/kap,Kap),
  xpath(Kap,rad(normalize_space),VarRad),
  atom_length(VarRad,L), 
  (L=<1 
    -> throw(averto('ignoras unuliteran radikon')) % ne akceptu radikojn unuliterajn
    ; true
  ),

  % eltrovu la oficialecon
  once((
    xpath(Kap,ofc(normalize_space),Ofc)
    ;
%%    % PLIBONIGU: la sekvan ni jam faras en revo_rad, ĉu ni fakte ripetu tie ĉi?
%%    % evitindecon de neoficialaj vortoj (en drv[1] aŭ drv[1]/snc[1] ni tie notas kiel 'e')
%%    xpath(DOM,//drv(1),Drv),
%%    (
%%      xpath(Drv,uzo(@tip=stl,text),'EVI');
%%      xpath(Drv,snc(1)/uzo(@tip=stl,text),'EVI')
%%    ),
%%    Ofc = 'e'
%%    ;
%%    % nek oficiala nek evitinda:
    Ofc=''
  )).

%  \+ (
%    xpath(Kap,uzo(@tip=stl,text),'EVI'), %throw(var_evi(Kap))
%    format('DBG var EVI: ~w~n',[Var])
%  ).

revo_intj(DOM,VSpeco) :-
   xpath(DOM,//drv,Drv),
   xpath(Drv,/drv/kap(text),''),
   xpath(Drv,/drv/gra/vspec(text),VSpeco),
   (VSpeco = sonimito ;  sub_atom(VSpeco,_,_,_,ekkrio)).

% ĉar ni inverse ordigos la vortaron ni
% uzos signojn por oficialeco, kiuj en
% Askio estas en la dezirata loko:
% ! = evitinda
% + = vorto neoficiale aldonita
% 1-9, 1953 ks = per oficiala aldono
% F = fundamenta
ofc_vrt('*','F').
ofc_vrt('','+').
ofc_vrt('e','!').
ofc_vrt(O,O) :- nonvar(O).
ofc_vrt(_,'+').

% retraduki F -> * antaŭ sekurigi!
vrt_ofc('F','*').
vrt_ofc(O,O).


nomo_majuskla(Nomo) :-
  atom_codes(Nomo,[L|_]),
  upper_lower(L,_).

nur_majuskloj(Atom) :-
  atom(Atom),
  atom_codes(Atom,Codes),
  nur_majuskloj(Codes).

nur_majuskloj([]).
nur_majuskloj([M|Literoj]) :-
  upper_lower(M,_),
  nur_majuskloj(Literoj).

    
test(X) :- 
 xpath(element(kap, [], ['\n  ', element(rad, [], [abaĵur]), '/o ', element(fnt, [], [element(bib, [], [...])]), '\n']), self, X).

  
