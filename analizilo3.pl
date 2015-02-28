:- use_module(library(sgml)). % por xml_quote_cdata
:-consult('vortaro3.pl').
:-consult('gra/gramatiko2.pl').
:-consult('gra/vorto_gra.pl').
:-ensure_loaded('dcg/teksto_dcg.pl'). % por dishaki tekston en vortojn

output(html).

/********** analizi unuopajn vortoj aŭ tutajn tekstojn ***************/

vortanalizo(Vorto,Ana,Spc) :-
  analyze(Vorto,Struct,Spc),
  reduce(Struct,Ana).


vortanalizo(Vorto,Ana,Spc,bone) :-
  vortanalizo(Vorto,Ana,Spc).

vortanalizo(Vorto,Ana,Spc,minuskle) :-
  minuskligo(Vorto,VrtMin), 
  vortanalizo(VrtMin,Ana,Spc).


minuskligo_atom(Vorto,Minuskle):-
  atom_codes(Vorto,[V|Vosto]),
  to_lower(V,M),
  atom_codes(Minuskle,[M|Vosto]).

minuskligo([V|Vosto],[M|Vosto]) :- to_lower(V,M).

majuskligo_atom(Vorto,Majuskle):-
  atom_codes(Vorto,[V|Vosto]),
  to_upper(V,M),
  atom_codes(Majuskle,[M|Vosto]).

majuskligo([V|Vosto],[M|Vosto]) :- to_upper(V,M).

parto_nombro(Vorto,Signo,Nombro) :-
  atomic_list_concat(Partoj,Signo,Vorto),
  proper_length(Partoj,Nombro).

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
    (
      open(OutFileName,write,Out),
      skribu_kapon
    ),
    with_output_to(Out,
       analizu_tekston_kopie_(T,VerdaListo)),
    (
      skribu_voston,
      close(Out)
    )
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
  once((
    memberchk(Vorto,VerdaListo),
    skribu_vorton(verda,Vorto,_,_)
   ;
    atom_codes(Mlg,Vorto), 
    mlg(Mlg), % che kelkaj mallongigoj oni devus kontroli chu poste venas punkto
    skribu_vorton(mlg,Vorto,_,_)
   ;
    vortanalizo(Vorto,Ana,Spc,Rim), 
     (
       nonvar(Ana), parto_nombro(Ana,'-',Nv), Nv>2 
       *-> skribu_vorton(dubebla,Vorto,Ana,Spc)
       ; skribu_vorton(Rim,Vorto,Ana,Spc)
     )
   ;
    skribu_vorton(neanalizebla,Vorto,_,_)
  )),
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

skribu_vorton(bone,_,Analizita,_) :-
  format('~w',Analizita).

skribu_vorton(minuskle,_,Analizita,_) :-
  majuskligo_atom(Analizita,Majuskla),
  format('~w',Majuskla).



skribu_vorton(neanalizebla,Vorto,_,_) :-
  output(html)
  -> format('<span class="neanaliz">~s</span>',[Vorto])
  ; format('>>>~s<<<',[Vorto]).

skribu_vorton(dubebla,_,Analizita,_) :-
  output(html)
  -> format('<span class="dubebla">~w</span>(?)',[Analizita])
  ; format('~w(?)',[Analizita]).

skribu_vorton(verda,Vorto,_,_) :-
  output(html)
  -> format('<span class="verda">~s</span>',[Vorto])
  ; format('>>~s<<',[Vorto]).

skribu_vorton(mlg,Vorto,_,_) :-
  output(html)
  -> format('<span class="mlg">~s</span>',[Vorto])
  ; format('~s',[Vorto]).

skribu_signojn(s(S)) :-  
 output(html)
 -> atom_codes(Sgn,S), xml_quote_cdata(Sgn,Quoted,utf8), write(Quoted)
 ; format('~s',[S]).
skribu_nombron(n(N)) :-  format('~s',[N]).





