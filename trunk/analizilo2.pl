:- use_module(library(sgml)).

:-consult('vortaro.pl').
%%:-consult('derivado.pl').
:-consult('dcg/vortpartoj_dcg.pl').
:-consult('dcg/vorto_dcg.pl').
%:-consult('frazana.pl').
:-consult('dcg/teksto_dcg.pl').

output(html).

/********** analizi unuopajn vortoj aw tutajn tekstojn ***************/

% noto: se vortanalizo fiaskas kontrolu per vortpartoj, kial la derivado/kunmetado/kunderivado ne efektiviĝas...

% analizas unuopan vorton
analizu_vorton(N) :-
	not(N = ''), 
        ( atom(N) -> atom_codes(N,C); C=N ),
        minuskligo(C,Cmin), majuskligo(C,Cmaj),
	once(
          (
	    vortanalizo(C,V,S), format('~w (~w)~n',[V,S]);
            vortanalizo(Cmin,V,S), format('~w (~w)~n',[V,S]);
            vortanalizo(Cmaj,V,S), format('~w (~w)~n',[V,S]);
	    vortpartoj(Cmin,P), format('~w - malstrikte!~n',[P]);
	    format('~s - NE analizebla!~n',[C])
	  )
        ).

analizu_vorton(Neanalizita,Vorto,Speco,Partoj,Rez) :-
	not(Neanalizita = ''), 
        ( atom(Neanalizita) -> atom_codes(Neanalizita,C); C=Neanalizita ),
        minuskligo(C,Cmin), majuskligo(C,Cmaj),
	once(
          (
	    vortanalizo(C,Vorto,Speco), Rez=bone;
            vortanalizo(Cmin,Vorto,Speco), Rez=minuskle;
            vortanalizo(Cmaj,Vorto,Speco), Rez=majuskle; 
	    vortpartoj(C,Partoj), Rez=malstrikte;
            Rez = neanalizebla
	  )
        ).

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


analizu_tekston_outfile(InFileName,OutFileName,VerdaListo) :-
  atom(InFileName),
  phrase_from_file(teksto(T),InFileName,[encoding(utf8)]),!,
  setup_call_cleanup(
     open(OutFileName,write,Out),
     with_output_to(Out,
       analizu_tekston_kopie_(T,VerdaListo)),
     close(Out)
  ).

analizu_tekston_outfile(InCodes,OutFileName,VerdaListo) :-
  is_list(InCodes),
  phrase(teksto(T),InCodes),!,
  setup_call_cleanup(
     open(OutFileName,write,Out),
     with_output_to(Out,
       analizu_tekston_kopie_(T,VerdaListo)),
     close(Out)
  ).

% analizas tutan tekstodosieron, kaj redonas la tekston kun
% ne analizeblaj vortoj markitaj
analizu_tekston_kopie(FileName,VerdaListo) :-
  atom(FileName),
  phrase_from_file(teksto(T),FileName,[encoding(utf8)]),!,
  analizu_tekston_kopie_(T,VerdaListo).

analizu_tekston_kopie(Stream,VerdaListo) :-
  is_stream(Stream),
  phrase_from_stream(teksto(T),Stream),!,
  analizu_tekston_kopie_(T,VerdaListo).

analizu_tekston_kopie(Txt,VerdaListo) :-
  is_list(Txt),
  phrase(teksto(T),Txt),!,
  analizu_tekston_kopie_(T,VerdaListo).

analizu_tekston_kopie_(T,VerdaListo) :-
  skribu_kapon,
  forall(member(M,T),
      once(
        (
	   M = v(V), 
	   memberchk(V,VerdaListo),
	   skribu_vorton(verda,V,_,_,_)
	   ;
	   analizu_teksteron(M)
	)
      )
  ),!,
  skribu_voston.

analizu_teksteron(Tekstero) :-
      Tekstero = v(V), length(V,L), 
	( L>1 *->  
	    analizu_vorton(V,Vorto,Spc,Partoj,Rez), 
	    (
	       nonvar(Vorto), parto_nombro(Vorto,'-',Nv), Nv>2 
	       *-> skribu_vorton(dubebla,V,Vorto,Spc,Partoj)
				% TODO: se analizu_vorton redonus jen ankau partojn pli facilus trakti...
		; skribu_vorton(Rez,V,Vorto,Spc,Partoj)
	     );
	  % unuopan literon skribu kiel signo...
	  skribu_signojn(s(V))
	);

       skribu_signojn(Tekstero);
       skribu_nombron(Tekstero);
       %skribu_fremdvorton(Tekstero);
       format(atom(Exc),'nekonata tekstparto ~w~n',[Tekstero]), throw(Exc).


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

% fremdvorto...
skribu_vorton(malstrikte,_,_,_,[fv(F,_)]) :-
 output(html)
  -> format(atom(Sgn),'"~s"',[F]), xml_quote_cdata(Sgn,Quoted,utf8), 
  format('<span class="malstrikte">~s</span>',[Quoted])
  ; format('"~s"',[F]).

skribu_vorton(malstrikte,Vorto,_,_,Partoj) :-
  output(html) 
  -> format('<span class="malstrikte">~s: ~w</span>',[Vorto,Partoj])
  ; format('?~s: ~w?',[Vorto,Partoj]).

skribu_vorton(bone,_,Analizita,_,_) :-
  format('~w',Analizita).

skribu_vorton(minuskle,_,Analizita,_,_) :-
  majuskligo_atom(Analizita,Majuskla),
  format('~w',Majuskla).

skribu_vorton(majuskle,_,Analizita,_,_) :-
  minuskligo_atom(Analizita,Minuskla),
  format('~w',Minuskla).

skribu_vorton(neanalizebla,Vorto,_,_,_) :-
  output(html)
  -> format('<span class="neanaliz">~s</span>',[Vorto])
  ; format('>>>~s<<<',[Vorto]).

skribu_vorton(dubebla,_,Analizita,_,_) :-
  output(html)
  -> format('<span class="dubebla">~w</span>(?)',[Analizita])
  ; format('~w(?)',[Analizita]).

skribu_vorton(verda,Vorto,_,_,_) :-
  output(html)
  -> format('<span class="verda">~s</span>',[Vorto])
  ; format('>>~s<<',[Vorto]).

skribu_signojn(s(S)) :-  
 output(html)
 -> atom_codes(Sgn,S), xml_quote_cdata(Sgn,Quoted,utf8), write(Quoted)
 ; format('~s',[S]).
skribu_nombron(n(N)) :-  format('~s',[N]).

/***
skribu_fremdvorton(fv(F)) :-  
  output(html)
  -> format(atom(Sgn),'"~s"',[F]), xml_quote_cdata(Sgn,Quoted,utf8), write(Quoted)
  ; format('"~s"',[F]).
***/

marku_dubebla :-
  output(html)
  -> format('<span class="dubebla">(?)</span>')
  ; format('(?)').


% analizas tutan tekstodosieron kaj donas la rezulton kiel listo
analizu_tekston_liste(Txt) :-
        phrase_from_file(teksto(T),Txt,[encoding(utf8)]),
        forall(member(M,T),
          once(
            (
               M = v(V) *-> analizu_vorton(V);
               true
            ) 
          )
        ),!.


/*************
% analizas tutan tekstodosieron
analizu_tekston2(Txt) :-
  read_file_to_codes(Txt,Teksto,[]),
  phrase(teksto(T),Teksto),
  forall(member(M,T),
          (
             M = v(V) *->  (analizu_vorton(V);true) ; true
      %       M = s(S) *->  write(S)
          )
        ),!.
**************/

vortanalizo(Vorto,Analizita,Speco) :-
  vortpartoj(Vorto,Partoj),
  (
    phrase(vorto(Analizita,Speco),Partoj)%;
    %phrase(kunmetita_vorto(Analizita,Speco),Partoj)
  ).



spc_fin_(Spc,Fin) :-
 (
    sub(Spc,subst), Fin=f(o,subst);
    sub(Spc,adj), Fin=f(a,adj),!;
    sub(Spc,verb), Fin=f(i,vrb);
    sub(Spc,adv), Fin=f(e,adv)
  ).

derivajho(Radiko,Derivajho,Speco) :-
  atom_codes(Radiko,RadCodes),
  phrase(r(Rad,Spc),RadCodes),
  phrase(s(Suf,AlSpc,DeSpc),_),
  spc_fin_(AlSpc,Fin),
  %member(Fin,[f(o,subst),f(a,adj),f(i,verb),f(e,adv)]),
  %member(Fin,[f(o,subst)]),
  phrase(vorto(Derivajho,Speco),[r(Rad,Spc),s(Suf,AlSpc,DeSpc),Fin]).

derivajho(Radiko,Derivajho,Speco) :-
  atom_codes(Radiko,RadCodes),
  phrase(r(Rad,Spc),RadCodes),
  phrase(p(Pref,AlSpc),_),
  spc_fin_(AlSpc,Fin),
  %member(Fin,[f(o,subst),f(a,adj),f(i,verb),f(e,adv)]),
  %member(Fin,[f(o,subst)]),
  phrase(vorto(Derivajho,Speco),[p(Pref,AlSpc),r(Rad,Spc),Fin]).
%test: derivajho(abel,D,_), writeln(D),fail.

derivajhoj(Radiko,Derivajhoj) :-
  setof(D,Spc^derivajho(Radiko,D,Spc),Derivajhoj).

testo(Vorto) :-
  vortpartoj(Vorto,Partoj),
  maplist(writeln,Partoj).

% ekz. grandegul
testo_suf(Vorto,N) :-
  phrase(radika_vorto_sen_fino(Partoj),Vorto),
  phrase(radv_sen_fin(V,S,N),Partoj),
  format('~w ~w~n',[V,S]).


/********************* analizaj funkcioj por frazoj ******************/

/***********************

analizu_elementon(v(Vorto),Analizita,Speco) :-
  vortanalizo(Vorto,Analizita,Speco).


analizu_elementon(s(Signoj),[]) :-
  Rezulto=Signoj.


povorta_analizo(Signoj,Vortoj) :-
%	vortigu(Signoj,Frazo),!,
        phrase(teksto(Frazo),Signoj),
	maplist(analizu_elementon,Frazo,Vortoj).

frazanalizo(Signoj,Rezulto) :-
%	vortigu(Signoj,Frazo),!,
        phrase(teksto(Frazo),Signoj),
	maplist(analizu_elementon,Frazo,Vortoj),
        %%% KOREKTU: necesas adapti "frazo" tiel, ke ĝi akzeptas la alternadon de analizita vorto kaj signoj en la listo...
        %%% alternative eble uzu dcg "frazo", char ghi kunigas chion ghis signo (komo ktp.) en unu listo...
	frazo(Vortoj,Rezulto),
	eligu_strukturon(Rezulto).

% tio funkciis nur, ĉar "vortigu" permesas
% ĉesi jam antaŭ la fino de la frazo
% eble tio estis iom neeleganta maniero -> aldonu en la dcg gramatiko de legilo
% varianton, kiu permesas ignori reston...?

parta_frazanalizo(Signoj,Rezulto) :-
%	vortigu(Signoj,Frazo),
        phrase(teksto(Frazo),Signoj),
	maplist(analizu_elementon,Frazo,Vortoj),
        %%% KOREKTU: necesas adapti "frazo" tiel, ke ĝi akzeptas la alternadon de analizita vorto kaj signoj en la listo...
	frazo(Vortoj,Rezulto),!,
	eligu_strukturon(Rezulto).


*******************/
