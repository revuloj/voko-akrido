:- module(revo_radikoj,[
	      revo_radikaro/0
	  ]).

:- use_module(library(sgml)).
:- use_module(library(xpath)).
:- use_module(library(semweb/rdf_db)).

:- dynamic radiko/2, evi/2, mlg/1, nr/2, nr_/2, vorto/2.

revo_xml('/home/revo/revo/xml/*.xml').
voko_rdf_klasoj('/home/revo/voko/owl/voko.rdf').
radik_dosiero('vrt/v_revo_radikoj.pl').
vort_dosiero('vrt/v_revo_vortoj.pl').
nomo_dosiero('vrt/v_revo_nomoj.pl').
evi_dosiero('vrt/v_revo_evitindaj.pl').
mlg_dosiero('vrt/v_revo_mallongigoj.pl').

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
          revo_art(Dosiero)
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
  findall(
    Rad-Spec,
    radiko(Rad,Spec),
    Chiuj),
  keysort(Chiuj,Ordigitaj),
  reverse(Ordigitaj,Renversitaj),
  forall(
    member(R-S,Renversitaj), % renversu por ke "senil" analiziĝu antaŭ "sen/il" ktp.
    % format(Out,'r(''~w'',~w) --> "~w".~n',[R,S,R])
    format(Out,'r(''~w'',~w).~n',[R,S])  
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
  findall(
    Vrt-Spec,
    vorto(Vrt,Spec),
    Chiuj),
  keysort(Chiuj,Ordigitaj),
  reverse(Ordigitaj,Renversitaj),
  forall(
    member(V-S,Renversitaj), 
    format(Out,'v(''~w'',~w).~n',[V,S])  
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
  findall(
    Rad-Spec,
    nr(Rad,Spec),
    Chiuj),
  keysort(Chiuj,Ordigitaj),
  reverse(Ordigitaj,Renversitaj),
  forall(
    member(R-S,Renversitaj),
    format(Out,'nr(''~w'',~w).~n',[R,S])  
  ).

skribu_nomojn_min(Out) :-
  findall(
    Rad-Spec,
    nr_(Rad,Spec),
    Chiuj),
  keysort(Chiuj,Ordigitaj),
  reverse(Ordigitaj,Renversitaj),
  forall(
    member(R-S,Renversitaj), 
    format(Out,'nr_(''~w'',~w).~n',[R,S])  
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
    format(Out,'mlg(''~w'').~n',[Mlg])
  ).

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


revo_art(Dosiero) :-
  load_xml_file(Dosiero,DOM),
  catch(
        (
	 revo_rad(DOM,Radiko,Speco),
	 revo_mlg(DOM,Mallongigoj)
       % format('~w (~w)~n',[Radiko,Speco]),
        ),
        Exc,
        (
          Exc = rad_evi(Kap) 
           -> assert_evi(Dosiero,Kap), throw(averto('EVI'))
           ; throw(Exc)
        )
     ),
  once((
    % se temas pri majuskla nomo, registru 
    % kiel nomradiko, kaj ankau minuskle	
    nomo_majuskla(Radiko),
    assertz(nr(Radiko,Speco)),
    assert_nomo_minuskla(Radiko,Speco)
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
  )),
  assert_mlg(Mallongigoj).


assert_nomo_minuskla(Nomo,Speco) :-
    atom_codes(Nomo,[K|Literoj]),
    upper_lower(K,M),
    atom_codes(MNomo,[M|Literoj]),
    assertz(nr_(MNomo,Speco)).

assert_mlg(Mallongigoj) :-
    forall(
      member(Mlg,Mallongigoj),
      assertz(mlg(Mlg))
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


revo_rad(DOM,Radiko,Speco) :-
  xpath(DOM,//art/kap,Kap),
  xpath(Kap,rad(normalize_space),Radiko),
  atom_length(Radiko,L), 
  (L=<1 
    -> throw(averto('ignoras unuliteran radikon')) % ne akceptu radikojn unuliterajn
    ; true
  ),
  xpath(DOM,//drv(1),Drv),
  \+ (
    xpath(Drv,uzo(@tip=stl,text),'EVI'), throw(rad_evi(Kap));
    xpath(Drv,snc(1)/uzo(@tip=stl,text),'EVI'), throw(rad_evi(Kap))
  ),
  once(
   revo_kls(Drv,Speco);
   revo_gra(Drv,Speco);
   revo_fin(Kap,Speco);
   throw(eraro('speco ne eltrovita'))
  ). 

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
      atom_length(Mlg,L), L>1, nur_majuskloj(Mlg)
    ),
    Mallongigoj
  ).

revo_intj(DOM,VSpeco) :-
   xpath(DOM,//drv,Drv),
   xpath(Drv,/drv/kap(text),''),
   xpath(Drv,/drv/gra/vspec(text),VSpeco),
   (VSpeco = sonimito ;  sub_atom(VSpeco,_,_,_,ekkrio)).

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

  
