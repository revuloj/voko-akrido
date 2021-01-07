:- module(analizilo,[
	      vortanalizo/3,
	      vortanalizo/4,
	      preparu_tekston/2, 
	      analizu_tekston_kopie/2,
	      analizu_tekston_liste/3,
	      analizu_tekston_outfile/3]).

:- use_module(library(sgml)). % por xml_quote_cdata
:- use_module(library(time)).
:- use_module(vortaro).
:- use_module('gra/gramatiko.pl').
%:-consult('gra/esceptoj.pl').
%:- use_module('gra/vorto_gra.pl').

:-ensure_loaded('dcg/teksto_dcg.pl'). % por dishaki tekston en vortojn

output(html).

vorto_max_infer(10000000). % 10 mio: maksimume tiom da rezonpaŝoj (inferences) daŭru vortanalizo


/** <module> Vort- kaj tekstanalizilo

  Vi povas analizi unuopajn vortojn aŭ tutajn tekstojn.
*/

%! vortanalizo(+Vorto:atom,-Analizita:atom,-Speco:atom) is nondet.
%
% Analizas unuopan vorton kaj redonas reduktitan (linearan) formon de la analizo kaj la vortspecon.
% Se pluraj analizoj estas eblaj laŭ la reguloj ili doniĝas unu post la alia.

vortanalizo(Vorto,Ana,Spc) :-
  vorto_max_infer(MaxI),
  call_with_inference_limit(
      (
      analyze(Vorto,Struct,Spc),
      reduce(Struct,Ana)
      ),
      MaxI,
      _
  ).


vortanalizo(Vorto,Ana,Spc,same) :-
  % PLIBONIGU: uzu anstataue la pli novan call_with_inference_limit(.. 1000000)
  vorto_max_infer(MaxI),
  catch(
    call_with_inference_limit( 
      vortanalizo(Vorto,Ana,Spc),
      MaxI,
      Result
    ),
    _Exc,
    (Result='inference_limit_exceeded' -> fail; true)
  ).

vortanalizo(Vorto,Ana,Spc,Uskl) :-
  %minuskligo(Vorto,VrtMin), 
  majuskloj(Vorto,VrtMin,Uskl),
  % PLIBONIGU: uzu anstataue la pli novan call_with_inference_limit(.. 1000000)
  vorto_max_infer(MaxI),
  catch(
    call_with_inference_limit(
      vortanalizo(VrtMin,Ana,Spc),
      MaxI,
      Result
    ),
    _Exc,
    (Result='inference_limit_exceeded' -> fail; true)
  ).

/***
minuskligo_atom(Vorto,Minuskle):-
  atom_codes(Vorto,[V|Vosto]),
  to_lower(V,M),
  atom_codes(Minuskle,[M|Vosto]).
***/

minuskligo([],[]).
minuskligo([V|V1],[M|M1]) :- 
    to_lower(V,M),
    minuskligo(V1,M1).

/***
majuskligo_atom(Vorto,Majuskle):-
  atom_codes(Vorto,[V|Vosto]),
  to_upper(V,M),
  atom_codes(Majuskle,[M|Vosto]).
***/

%%% majuskligo([V|Vosto],[M|Vosto]) :- to_upper(V,M).

majuskloj([],[],0:0).

majuskloj([V|Vj],[M|Mj],1:R) :- 
  upper_lower(V,M),  
  majuskloj(Vj,Mj,U1:R1),
  R is U1+R1.

majuskloj([L|Vj],[L|Mj],0:R) :- 
  majuskloj(Vj,Mj,U1:R1),
  R is U1+R1.

% Nombro donas, el kiom da partoj apartigitaj per Signo konsistas Vorto
% malplenaj partoj ne kalkuliĝas!
parto_nombro(Vorto,Signo,Nombro) :-
  atomic_list_concat(Partoj,Signo,Vorto),
  foldl(non_empty,Partoj,0,Nombro).
%  proper_length(Partoj,Nombro).

non_empty('',N,N):-!.
non_empty(_,N,N_1):-succ(N,N_1).


% Source: InFileName aŭ InCodes
analizu_tekston_outfile(Source,OutFileName) :-
  analizu_tekston_outfile(Source,OutFileName,[]).


%! analizu_tekston_outfile(+ElDosiero:atom,+AlDosiero:atom,+VerdaListo:list).
%! analizu_tekston_outfile(+Teksto:list,+AlDosiero:atom,+VerdaListo:list).
%
% Analizas kompletan tekston el tekstdosiero aŭ rekte donitan kiel argumento. La rezulto estas skribita al _AlDosiero_.
% La VerdaListo estas listo de vortoj kiel ne estos analizataj sed tuj akceptataj, kiam ili aperas en la teksto.
% Uzu ekz-e por propraj nomoj aŭ nekutima mallongigoj.

analizu_tekston_outfile(InFileName,OutFileName,VerdaListo) :-
  atom(InFileName),
  phrase_from_file(teksto(T),InFileName,[encoding(utf8)]),!,
  analizo_output(OutFileName,T,VerdaListo).

analizu_tekston_outfile(InCodes,OutFileName,VerdaListo) :-
  is_list(InCodes),
  phrase(teksto(T),InCodes),!,
  analizo_output(OutFileName,T,VerdaListo).

preparu_tekston(InCodes,Teksto) :-    
  is_list(InCodes),
  phrase(teksto(Teksto),InCodes),!.

analizo_output(OutFileName,T,VerdaListo) :-
  setup_call_cleanup(
    open(OutFileName,write,Out),
    with_output_to(Out,
     (
       skribu_kapon,
       analizu_tekston_kopie_(T,VerdaListo),
       skribu_voston
     )),
    close(Out)
  ).

%! analizu_tekston_kopie(+Dosiero:atom,+VerdaListo:list). 
%! analizu_tekston_kopie(+Fluo:stream,+VerdaListo:list).
%! analizu_tekston_kopie(+Teksto:list,+VerdaListo:list).
%
% Analizas kompletan tekston el tekstdosiero aŭ datumfluo. La rezulto estas skribita al STDOUT.
% La VerdaListo estas listo de vortoj kiel ne estos analizataj sed tuj akceptataj, kiam ili aperas en la teksto.

% analizas tutan tekstodosieron, kaj redonas la tekston kun
% ne analizeblaj vortoj markitaj
analizu_tekston_kopie(FileName,VerdaListo) :-
  atom(FileName),
  phrase_from_file(teksto(T),FileName,[encoding(utf8)]),!,
  analizu_tekston_kopie_(T,VerdaListo),!.

analizu_tekston_kopie(Stream,VerdaListo) :-
  is_stream(Stream),
  phrase_from_stream(teksto(T),Stream),!,
  analizu_tekston_kopie_(T,VerdaListo),!.

analizu_tekston_kopie(Txt,VerdaListo) :-
  is_list(Txt),
  phrase(teksto(T),Txt),!,
  analizu_tekston_kopie_(T,VerdaListo),!.


analizu_tekston_kopie_([],_).
 
analizu_tekston_kopie_([v(Vorto)|Text],VerdaListo) :-
  length(Vorto,L), L>1, % ne analizu unuopajn literojn
%  statistics(cputime,C1),
%  statistics(inferences,I1),

  debug(analizo,'~s',[Vorto]),

  once((
    % PLIBONIGU: okaze forigu verdan liston, ĉar ni nun markas
    % per <nom>, <nac>, <frm> en Revo-artikoloj, ni povos
    % jam anticipe escpeti tiujn vortojn
    memberchk(Vorto,VerdaListo),
    skribu_vorton(verda,Vorto,_,_,_)
   ;
    atom_codes(Nf,Vorto), 
    nf(Nf,_), % nomo-fremda
    skribu_vorton(verda,Vorto,_,_,_)
   ;   
    atom_codes(Mlg,Vorto), 
    mlg(Mlg), % che kelkaj mallongigoj oni devus kontroli chu poste venas punkto
    skribu_vorton(mlg,Vorto,_,_,_)
   ;
    vortanalizo(Vorto,Ana,Spc,Uskl), !,
     %(
       %nonvar(Ana), 
       once((
         var(Ana), % neanalizita
         skribu_vorton(neanalizebla,Vorto,_,_,_)
         ;
         % kunmetita vorto kun pli ol du radikoj: kontrolenda
         parto_nombro(Ana,'-',Nv), Nv>2, skribu_vorton(dubebla,Vorto,Ana,Spc,Uskl)
         ; 
         % kuntirita vorto: kontrolenda
         parto_nombro(Ana,'~',Nv), Nv>1, skribu_vorton(kuntirita,Vorto,Ana,Spc,Uskl)
         ; 
         skribu_vorton(bona,Vorto,Ana,Spc,Uskl)
       ))
     %)
   ;
    % la vorto ne estis analizebla
    skribu_vorton(neanalizebla,Vorto,_,_,_)
  )),
%  statistics(inferences,I2), 
%  statistics(cputime,C2),
%  C is C2-C1, I is I2-I1,
%  (C>5 -> format(' [i~d,c~2f] ',[I,C]); true), 
  analizu_tekston_kopie_(Text,VerdaListo).


analizu_tekston_kopie_([v(V)|Text],VL) :-
  length(V,L), L=<1, % ne analizu unuopajn literojn
  skribu_signojn(s(V)),
  analizu_tekston_kopie_(Text,VL).


analizu_tekston_kopie_([s(S)|Text],VL) :-
  skribu_signojn(s(S)),
  analizu_tekston_kopie_(Text,VL).

analizu_tekston_kopie_([n(N)|Text],VL) :-
  skribu_nombron(n(N)),
  analizu_tekston_kopie_(Text,VL).

analizu_tekston_kopie_(Tekstero,_) :-
  format(atom(Exc),'nekonata tekstparto ~w~n',[Tekstero]), 
  throw(Exc).


%%%%%%%%%

analizu_tekston_liste(Txt,VerdaListo,Rezulto) :-
    is_list(Txt),
    phrase(teksto(T),Txt),!,
    analizu_tekston_liste_(T,VerdaListo,Rezulto).

analizu_tekston_liste_([],_,[]).
 
analizu_tekston_liste_([v(Vorto)|Text],VerdaListo,[Rezulto|Resto]) :-
  length(Vorto,L), L>1, % ne analizu unuopajn literojn
%  statistics(cputime,C1),
%  statistics(inferences,I1),
  once((
    % PLIBONIGU: okaze forigu verdan liston, ĉar ni nun markas
    % per <nom>, <nac>, <frm> en Revo-artikoloj, ni povos
    % jam anticipe escpeti tiujn vortojn
    memberchk(Vorto,VerdaListo),
    atom_codes(V,Vorto), 
    Rezulto = _{takso:verda,vorto:V}
   ;
    atom_codes(Nf,Vorto), 
    nf(Nf,_), % nomo-fremda
    skribu_vorton(verda,Vorto,_,_,_)    
   ;
    atom_codes(Mlg,Vorto), 
    mlg(Mlg), % che kelkaj mallongigoj oni devus kontroli chu poste venas punkto
    Rezulto = _{takso:mlg,vorto:Mlg}
   ;
    vortanalizo(Vorto,Ana,Spc,Uskl), !,
     %(
       %nonvar(Ana) -> 
       once((
         var(Ana), % neanalizebla
         atom_codes(V,Vorto), 
         Rezulto = _{takso:neanalizebla,vorto:V}
         ;
         parto_nombro(Ana,'-',Nv), Nv>2,   
         % uskleco(Uskl,Vorto,U2,Ana,A), 
         atom_codes(V,Vorto), term_to_atom(Uskl,U),
         Rezulto = _{takso:dubebla,vorto:V,analizo:Ana,speco:Spc,uskl:U}
         ; 
         parto_nombro(Ana,'~',Nv), Nv>1, 
         %uskleco(Uskl,Vorto,U2,Ana,A), 
         atom_codes(V,Vorto), term_to_atom(Uskl,U),
         Rezulto = _{takso:kuntirita,vorto:V,analizo:Ana,speco:Spc,uskl:U}
         ; 
         %uskleco(Uskl,Vorto,U2,Ana,A), 
         atom_codes(V,Vorto), term_to_atom(Uskl,U),
         Rezulto = _{takso:bona,vorto:V,analizo:Ana,speco:Spc,uskl:U}
       ))
     %)
   ;
    atom_codes(V,Vorto), 
    Rezulto = _{takso:neanalizebla,vorto:V}
  )),
%  statistics(inferences,I2), 
%  statistics(cputime,C2),
%  C is C2-C1, I is I2-I1,
%  (C>5 -> format(' [i~d,c~2f] ',[I,C]); true), 
  analizu_tekston_liste_(Text,VerdaListo,Resto).


analizu_tekston_liste_([v(V)|Text],VL,[_{takso:signo,vorto:S}|Resto]) :-
  length(V,L), L=<1, % ne analizu unuopajn literojn
  atom_codes(S,V),
  analizu_tekston_liste_(Text,VL,Resto).

analizu_tekston_liste_([s(S)|Text],VL,[_{takso:signo,vorto:S1}|Resto]) :-
  atom_codes(S1,S),
  analizu_tekston_liste_(Text,VL,Resto).

analizu_tekston_liste_([n(N)|Text],VL,[_{takso:nombro,vorto:N1}|Resto]) :-
  atom_codes(N1,N),
   analizu_tekston_liste_(Text,VL,Resto).

analizu_tekston_liste_(Tekstero,_,_) :-
  format(atom(Exc),'nekonata tekstparto ~w~n',[Tekstero]), 
  throw(Exc).

%%%%%%%


skribu_kapon :-
  output(html) 
  -> format('<html><head>'),
     format('<meta http-equiv="content-type" content="text/html; charset=utf-8">'),
     format('<link title="stilo" type="text/css" rel="stylesheet" href="../stilo.css">'),
     format('</head><body><a href="../klarigoj.html">vidu ankaŭ la klarigojn</a><pre>~n')
  ; true.

skribu_voston :-
  output(html) 
  -> format('~n</pre></body></html>~n')
  ; true.

skribu_vorton(bona,Vorto,Analizita,_,Uskl) :-
  uskleco(Uskl,Vorto,U,Analizita,A),
  oficialeco(A,LOfc,AO),
  once((
    LOfc = [], % neniu aparta oficialec-informo
    format('~w~w',[U,AO])
    ;
    output(html)
    -> 
    (
      ofc_classes(LOfc,Cls), % kreu klasliston de oficialeco
      format('<span class="~w">~w~w</span>',[Cls,U,AO])
    ); format('~w~w',[U,AO])
  )).

%skribu_vorton(bona,Vorto,Analizita,_,minuskle) :-
% % majuskligo_atom(Analizita,Majuskla),
%  format('"~s"::~w',[Vorto,Analizita]).

skribu_vorton(neanalizebla,Vorto,_,_,_) :-
  output(html)
  -> format('<span class="neanaliz">~s</span>',[Vorto])
  ; format('>>>~s<<<',[Vorto]).

skribu_vorton(dubebla,Vorto,Analizita,_,Uskl) :-
  uskleco(Uskl,Vorto,U,Analizita,A),
  oficialeco(A,LOfc,AO),
  once((
    LOfc = [], % neniu aparta oficialec-informo
    format('~w~w',[U,AO])
    ;
    output(html)
    -> 
    (
      ofc_classes(LOfc,Cls), % kreu klasliston de oficialeco
     format('<span class="dubebla ~w">~w~w</span>(?)',[Cls,U,AO])
    ); format('~w~w(?)',[U,A])
  )).

skribu_vorton(kuntirita,Vorto,Analizita,_,Uskl) :-
  uskleco(Uskl,Vorto,U,Analizita,A),
  oficialeco(A,LOfc,AO),
  once((
    LOfc = [], % neniu aparta oficialec-informo
    format('~w~w',[U,AO])
    ;
    output(html)
    -> 
    (
      ofc_classes(LOfc,Cls), % kreu klasliston de oficialeco
      format('<span class="kuntirita ~w">~w~w</span>',[Cls,U,AO])
    ); format('~w~w(!)',[U,A])
  )).

skribu_vorton(verda,Vorto,_,_,_) :-
  output(html)
  -> format('<span class="verda">~s</span>',[Vorto])
  ; format('>>~s<<',[Vorto]).

skribu_vorton(mlg,Vorto,_,_,_) :-
  output(html)
  -> format('<span class="mlg">~s</span>',[Vorto])
  ; format('~s',[Vorto]).

skribu_signojn(s(S)) :-  
 output(html)
 -> atom_codes(Sgn,S), xml_quote_cdata(Sgn,Quoted,utf8), write(Quoted)
 ; format('~s',[S]).
skribu_nombron(n(N)) :-  format('~s',[N]).



uskleco(_:1,Vorto,U,Analizita,Analizita) :-
  format(atom(U),'[~s:] ',[Vorto]),!.

% uskleco dum analizo perdiĝis, do ni remetas ĝin
% laŭ la origina vorto

uskleco(1:0,_,'',Analizita,Ana) :-
  atom_codes(Analizita,[A|Nalizita]),
  to_upper(A,A1),
  atom_codes(Ana,[A1|Nalizita]).

uskleco(_,_,'',Analizita,Analizita).


% oficialeco enestas kiel [...]
% ni enmetos <sup>...</sup> tiuloke
% plibonigu anst. serĉi kaj anstaŭigi [...]
% estus pli bone difini formulbazitan
% transformilon Analizita -> HTML
% kaj Analizita -> Text, evtl-e ankaŭ JSON?
oficialeco(A,[Ofc|ORest],A1) :-
  sub_atom(A,Left,1,_,'['),
  sub_atom(A,Right,1,_,']'),!,
  % rigardu, ĉu dekstre estas pliaj [...]
  sub_atom(A,0,Left,_,ALeft),
  R1 is Right+1, sub_atom(A,R1,_,0,ARight),
  oficialeco(ARight,ORest,ARest),
  % malplena krampo signifas neoficiala!
  Len is Right-Left-1, 
  once((
    Len = 0, % ne devus plu okazi, ĉar ni nun uzas '+' anst. '' por neoficialaj
    Ofc = n,
    atomic_list_concat([ALeft,ARest],A1)
    ;
    Len < 5, L1 is Left+1,
    sub_atom(A,L1,Len,_,Ofc),
    atomic_list_concat([ALeft,'<sup>',Ofc,'</sup>',ARest],A1)
    ;
    %throw('Nevalida oficialeco, tro longa!')
    format('Nevalida oficialeco, tro longa!')
  )).

% se ne plu enestas [...]
oficialeco(A,[],A).

ofc_classes(LOfc,Classes) :-
  maplist(ofc_cls,LOfc,LCls),
  setof(C,member(C,LCls),CSet),
  atomic_list_concat(CSet,' ',Classes).

ofc_cls('*','o_f'):-!.
ofc_cls('!','evi'):-!.
ofc_cls('+','o_n'):-!.
ofc_cls(O,C) :- atom_concat(o_, O, C).


