:- use_module(library(sgml)). % por xml_quote_cdata
:- use_module(library(time)).
:-consult('vortaro3.pl').
:-consult('gra/gramatiko2.pl').
:-consult('gra/esceptoj.pl').
:-consult('gra/vorto_gra.pl').
:-ensure_loaded('dcg/teksto_dcg.pl'). % por dishaki tekston en vortojn

output(html).

/********** analizi unuopajn vortoj aŭ tutajn tekstojn ***************/

vortanalizo(Vorto,Ana,Spc) :-
  analyze(Vorto,Struct,Spc),
  reduce(Struct,Ana).


vortanalizo(Vorto,Ana,Spc,same) :-
  % PLIBONIGU: uzu anstataue la pli novan call_with_inference_limit(.. 1000000)
  catch(
    call_with_time_limit(3, % max. 3s
      vortanalizo(Vorto,Ana,Spc)),
    Exc,
    (sub_atom(Exc,0,_,_,'time_limit_exceeded') -> fail; true)).

vortanalizo(Vorto,Ana,Spc,Uskl) :-
  %minuskligo(Vorto,VrtMin), 
  majuskloj(Vorto,VrtMin,Uskl),
  % PLIBONIGU: uzu anstataue la pli novan call_with_inference_limit(.. 1000000)
  catch(
    call_with_time_limit(3, % max. 3s
    vortanalizo(VrtMin,Ana,Spc)),
    Exc,
    (sub_atom(Exc,0,_,_,'time_limit_exceeded') -> fail; true)).

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


parto_nombro(Vorto,Signo,Nombro) :-
  atomic_list_concat(Partoj,Signo,Vorto),
  foldl(non_empty,Partoj,0,Nombro).
%  proper_length(Partoj,Nombro).

non_empty('',N,N):-!.
non_empty(_,N,N_1):-succ(N,N_1).

% Source: InFileName aŭ InCodes
analizu_tekston_outfile(Source,OutFileName) :-
  analizu_tekston_outfile(Source,OutFileName,[]).

analizu_tekston_outfile(InFileName,OutFileName,VerdaListo) :-
  atom(InFileName),
  phrase_from_file(teksto(T),InFileName,[encoding(utf8)]),!,
  analizo_output(OutFileName,T,VerdaListo).

analizu_tekston_outfile(InCodes,OutFileName,VerdaListo) :-
  is_list(InCodes),
  phrase(teksto(T),InCodes),!,
  analizo_output(OutFileName,T,VerdaListo).

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
  once((
    memberchk(Vorto,VerdaListo),
    skribu_vorton(verda,Vorto,_,_,_)
   ;
    atom_codes(Mlg,Vorto), 
    mlg(Mlg), % che kelkaj mallongigoj oni devus kontroli chu poste venas punkto
    skribu_vorton(mlg,Vorto,_,_,_)
   ;
    vortanalizo(Vorto,Ana,Spc,Uskl), 
     (
       nonvar(Ana), 
       once((
         parto_nombro(Ana,'-',Nv), Nv>2, skribu_vorton(dubebla,Vorto,Ana,Spc,Uskl)
         ; 
         parto_nombro(Ana,'~',Nv), Nv>1, skribu_vorton(kuntirita,Vorto,Ana,Spc,Uskl)
         ; 
         skribu_vorton(bona,Vorto,Ana,Spc,Uskl)
       ))
     )
   ;
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
  format('~w~w',[U,A]).

%skribu_vorton(bona,Vorto,Analizita,_,minuskle) :-
% % majuskligo_atom(Analizita,Majuskla),
%  format('"~s"::~w',[Vorto,Analizita]).

skribu_vorton(neanalizebla,Vorto,_,_,_) :-
  output(html)
  -> format('<span class="neanaliz">~s</span>',[Vorto])
  ; format('>>>~s<<<',[Vorto]).

skribu_vorton(dubebla,Vorto,Analizita,_,Uskl) :-
  uskleco(Uskl,Vorto,U,Analizita,A),
  (output(html)
  -> format('<span class="dubebla">~w~w</span>(?)',[U,A])
  ; format('~w~w(?)',[U,A])).

skribu_vorton(kuntirita,Vorto,Analizita,_,Uskl) :-
  uskleco(Uskl,Vorto,U,Analizita,A),
  (output(html)
  -> format('<span class="kuntirita">~w~w</span>',[U,A])
  ; format('~w~w(!)',[U,A])).

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

uskleco(1:0,_,'',Analizita,Ana) :-
  atom_codes(Analizita,[A|Nalizita]),
  to_upper(A,A1),
  atom_codes(Ana,[A1|Nalizita]).

uskleco(_,_,'',Analizita,Analizita).


