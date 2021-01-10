:- module(analizilo,[
	      vortanalizo/3,
	      vortanalizo/4,
	      vortanalizo/5,
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

%output(html).

vorto_max_infer(10000000). % 10 mio: maksimume tiom da rezonpaŝoj (inferences) daŭru vortanalizo


/** <module> Vort- kaj tekstanalizilo

  Vi povas analizi unuopajn vortojn aŭ tutajn tekstojn.
*/

%! vortanalizo(+Vorto:atom,-Analizita:atom,-Speco:atom) is nondet.
%
% Analizas unuopan vorton kaj redonas reduktitan (linearan) formon de la analizo kaj la vortspecon.
% Se pluraj analizoj estas eblaj laŭ la reguloj ili doniĝas unu post la alia.

vortanalizo(Vorto,Ana,Spc) :-
  vortanalizo(Vorto,Ana,Spc,text).

vortanalizo(Vorto,Ana,Spc,text) :-
  vorto_max_infer(MaxI),
  call_with_inference_limit(
      (
      analyze(Vorto,Struct,Spc),
      %reduce(Struct,Ana)
      ana_txt(Struct,Ana)
      ),
      MaxI,
      _
  ).

vortanalizo(Vorto,Struct,Spc,struct) :-
  vorto_max_infer(MaxI),
  call_with_inference_limit(
      (
      analyze(Vorto,Struct,Spc)
      ),
      MaxI,
      _
  ).

vortanalizo(Vorto,Ana,Spc,html) :-
  vorto_max_infer(MaxI),
  call_with_inference_limit(
      (
      analyze(Vorto,Struct,Spc),
      %reduce(Struct,Ana)
      ana_html(Struct,Ana)
      ),
      MaxI,
      _
  ).

vortanalizo(Vorto,Ana,Spc,same,Format) :-
  % PLIBONIGU: uzu anstataue la pli novan call_with_inference_limit(.. 1000000)
  vorto_max_infer(MaxI),
  catch(
    call_with_inference_limit( 
      vortanalizo(Vorto,Ana,Spc,Format),
      MaxI,
      Result
    ),
    _Exc,
    (Result='inference_limit_exceeded' -> fail; true)
  ).

vortanalizo(Vorto,Ana,Spc,Uskl,Format) :-
  %minuskligo(Vorto,VrtMin), 
  majuskloj(Vorto,VrtMin,Uskl),
  % PLIBONIGU: uzu anstataue la pli novan call_with_inference_limit(.. 1000000)
  vorto_max_infer(MaxI),
  catch(
    call_with_inference_limit(
      vortanalizo(VrtMin,Ana,Spc,Format),
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
  analizu_tekston_outfile(Source,OutFileName,text).


%! analizu_tekston_outfile(+ElDosiero:atom,+AlDosiero:atom,+Format:atom).
%! analizu_tekston_outfile(+Teksto:list,+AlDosiero:atom,+Format:atp,).
%
% Analizas kompletan tekston el tekstdosiero aŭ rekte donitan kiel argumento. La rezulto estas skribita al _AlDosiero_.
% Format povas esti text aŭ html.

analizu_tekston_outfile(InFileName,OutFileName,Format) :-
  atom(InFileName),
  phrase_from_file(teksto(T),InFileName,[encoding(utf8)]),!,
  analizo_output(OutFileName,T,Format).

analizu_tekston_outfile(InCodes,OutFileName,Format) :-
  is_list(InCodes),
  phrase(teksto(T),InCodes),!,
  analizo_output(OutFileName,T,Format).

preparu_tekston(InCodes,Teksto) :-    
  is_list(InCodes),
  phrase(teksto(Teksto),InCodes),!.

analizo_output(OutFileName,T,Format) :-
  setup_call_cleanup(
    open(OutFileName,write,Out),
    with_output_to(Out,
     (
       skribu_kapon(Format),
       analizu_tekston_kopie_(T,Format),
       skribu_voston(Format)
     )),
    close(Out)
  ).

%! analizu_tekston_kopie(+Dosiero:atom,+Format:atom). 
%! analizu_tekston_kopie(+Fluo:stream,+Format:atom).
%! analizu_tekston_kopie(+Teksto:list,+Format:atom).
%
% Analizas kompletan tekston el tekstdosiero aŭ datumfluo. La rezulto estas skribita al STDOUT.
% Format povas esti text aŭ html

% analizas tutan tekstodosieron, kaj redonas la tekston kun
% ne analizeblaj vortoj markitaj
analizu_tekston_kopie(FileName,Format) :-
  atom(FileName),
  phrase_from_file(teksto(T),FileName,[encoding(utf8)]),!,
  analizu_tekston_kopie_(T,Format),!.

analizu_tekston_kopie(Stream,Format) :-
  is_stream(Stream),
  phrase_from_stream(teksto(T),Stream),!,
  analizu_tekston_kopie_(T,Format),!.

analizu_tekston_kopie(Txt,Format) :-
  is_list(Txt),
  phrase(teksto(T),Txt),!,
  analizu_tekston_kopie_(T,Format),!.


analizu_tekston_kopie_([],_).
 
analizu_tekston_kopie_([v(Vorto)|Text],Format) :-
  length(Vorto,L), L>1, % ne analizu unuopajn literojn
%  statistics(cputime,C1),
%  statistics(inferences,I1),

  debug(analizo,'~s',[Vorto]),

  once((
    /* forigante verdan liston, ĉar ni nun markas
    % per <nom>, <nac>, <frm> en Revo-artikoloj, ni povos
    % jam anticipe escpeti tiujn vortojn
    memberchk(Vorto,Format),
    skribu_vorton(verda,Vorto,_,_,_)
   ;*/
    atom_codes(Nf,Vorto), 
    nf(Nf,_), % nomo-fremda
    skribu_vorton(Format,verda,Vorto,_,_,_)
   ;   
    atom_codes(Mlg,Vorto), 
    mlg(Mlg), % che kelkaj mallongigoj oni devus kontroli chu poste venas punkto
    skribu_vorton(Format,mlg,Mlg,_,_,_)
   ;
    vortanalizo(Vorto,Ana,Spc,Uskl,Format), !,
     %(
       %nonvar(Ana), 
       once((
         var(Ana), % neanalizita
         skribu_vorton(Format,neanalizebla,Vorto,_,_,_)
         ;
         % kunmetita vorto kun pli ol du radikoj: kontrolenda
%% KOREKTU: momente en HTML ne plu funkcias!!!         
%%         parto_nombro(Ana,'-',Nv), Nv>2, skribu_vorton(Format,dubebla,Vorto,Ana,Spc,Uskl)
%%         ; 
%%         % kuntirita vorto: kontrolenda
%%         parto_nombro(Ana,'~',Nv), Nv>1, skribu_vorton(Format,kuntirita,Vorto,Ana,Spc,Uskl)
%%         ; 
         skribu_vorton(Format,bona,Vorto,Ana,Spc,Uskl)
       ))
     %)
   ;
    % la vorto ne estis analizebla
    skribu_vorton(Format,neanalizebla,Vorto,_,_,_)
  )),
%  statistics(inferences,I2), 
%  statistics(cputime,C2),
%  C is C2-C1, I is I2-I1,
%  (C>5 -> format(' [i~d,c~2f] ',[I,C]); true), 
  analizu_tekston_kopie_(Text,Format).


analizu_tekston_kopie_([v(V)|Text],Format) :-
  length(V,L), L=<1, % ne analizu unuopajn literojn
  skribu_signojn(Format,s(V)),
  analizu_tekston_kopie_(Text,Format).


analizu_tekston_kopie_([s(S)|Text],Format) :-
  skribu_signojn(Format,s(S)),
  analizu_tekston_kopie_(Text,Format).

analizu_tekston_kopie_([n(N)|Text],Format) :-
  skribu_nombron(n(N)),
  analizu_tekston_kopie_(Text,Format).

analizu_tekston_kopie_(Tekstero,_) :-
  format(atom(Exc),'nekonata tekstparto ~w~n',[Tekstero]), 
  throw(Exc).


%%%%%%%%%

analizu_tekston_liste(Txt,Format,Rezulto) :-
    is_list(Txt),
    phrase(teksto(T),Txt),!,
    analizu_tekston_liste_(T,Format,Rezulto).

analizu_tekston_liste_([],_,[]).
 
analizu_tekston_liste_([v(Vorto)|Text],Format,[Rezulto|Resto]) :-
  length(Vorto,L), L>1, % ne analizu unuopajn literojn
%  statistics(cputime,C1),
%  statistics(inferences,I1),
  once((
    /* forigante verdan liston, ĉar ni nun markas
    % per <nom>, <nac>, <frm> en Revo-artikoloj, ni povos
    % jam anticipe escpeti tiujn vortojn
    memberchk(Vorto,VerdaListo),
    atom_codes(V,Vorto), 
    Rezulto = _{takso:verda,vorto:V}
   ;*/
    atom_codes(Nf,Vorto), 
    nf(Nf,_), % nomo-fremda
    skribu_vorton(Format,verda,Vorto,_,_,_)    
   ;
    atom_codes(Mlg,Vorto), 
    mlg(Mlg), % che kelkaj mallongigoj oni devus kontroli chu poste venas punkto
    Rezulto = _{takso:mlg,vorto:Mlg}
   ;
    vortanalizo(Vorto,Ana,Spc,Uskl,Format), !,
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
  analizu_tekston_liste_(Text,Format,Resto).


analizu_tekston_liste_([v(V)|Text],Format,[_{takso:signo,vorto:S}|Resto]) :-
  length(V,L), L=<1, % ne analizu unuopajn literojn
  atom_codes(S,V),
  analizu_tekston_liste_(Text,Format,Resto).

analizu_tekston_liste_([s(S)|Text],Format,[_{takso:signo,vorto:S1}|Resto]) :-
  atom_codes(S1,S),
  analizu_tekston_liste_(Text,Format,Resto).

analizu_tekston_liste_([n(N)|Text],Format,[_{takso:nombro,vorto:N1}|Resto]) :-
  atom_codes(N1,N),
   analizu_tekston_liste_(Text,Format,Resto).

analizu_tekston_liste_(Tekstero,_,_) :-
  format(atom(Exc),'nekonata tekstparto ~w~n',[Tekstero]), 
  throw(Exc).

%%%%%%%


skribu_kapon(text).
skribu_kapon(html) :-
  format('<html><head>'),
  format('<meta http-equiv="content-type" content="text/html; charset=utf-8">'),
  format('<meta name="viewport" content="width=device-width,initial-scale=1">'),
  format('<link title="stilo" type="text/css" rel="stylesheet" href="../stilo.css">'),
  format('</head><body><a href="../klarigoj.html">vidu ankaŭ la klarigojn</a><pre>~n').

skribu_voston(text).
skribu_voston(html) :-
  format('~n</pre></body></html>~n').


skribu_vorton(text,bona,Vorto,Analizita,_,Uskl) :-
  uskleco(Uskl,Vorto,U,Analizita,A),
  format('~w~w',[U,A]).
skribu_vorton(text,neanalizebla,Vorto,_,_,_) :-
  format('>>>~s<<<',[Vorto]).
skribu_vorton(text,dubebla,Vorto,Analizita,_,Uskl) :-
  uskleco(Uskl,Vorto,U,Analizita,A),
  format('~w~w(?)',[U,A]).
skribu_vorton(text,kuntirita,Vorto,Analizita,_,Uskl) :-
  uskleco(Uskl,Vorto,U,Analizita,A),
  format('~w~w(!)',[U,A]).
skribu_vorton(text,verda,Vorto,_,_,_) :-
  format('>>~s<<',[Vorto]).
skribu_vorton(text,mlg,Mlg,_,_,_) :-
  format('~w',[Mlg]).


skribu_vorton(html,bona,Vorto,Analizita,_,Uskl) :- 
  %format('~q',[Uskl]),
  uskleco(Uskl,Vorto,_,Analizita,A),
  html_write(A,[]).

%skribu_vorton(bona,Vorto,Analizita,_,minuskle) :-
% % majuskligo_atom(Analizita,Majuskla),
%  format('"~s"::~w',[Vorto,Analizita]).

skribu_vorton(html,neanalizebla,Vorto,_,_,_) :-
  atom_codes(V,Vorto),
  html_write([element(span,[class=neanaliz],[V])],[]).

skribu_vorton(html,dubebla,Vorto,Analizita,_,Uskl) :-
  %format('~q',[Uskl]),
  uskleco(Uskl,Vorto,_,Analizita,A),
  % PLIBONIGU: temas pri longaj kunmetoj (pli ol 3 partoj)
  % aŭ aldonu la klason jam en regul_trf:ana_html
  % aŭ ŝovu gin ene de la span-elemento troviĝante en Analizita
  % momente ni havas nestitan span-en-span!
  html_write([element(span,[class=dubebla],A)],[]).

skribu_vorton(html,kuntirita,Vorto,Analizita,_,Uskl) :-
  %format('~q',[Uskl]),
  uskleco(Uskl,Vorto,_,Analizita,A),
  html_write(A,[]).

skribu_vorton(html,verda,Vorto,_,_,_) :-
  atom_codes(V,Vorto),
  html_write([element(span,[class=verda],[V])],[]).

skribu_vorton(html,mlg,Mlg,_,_,_) :-  
  html_write([element(span,[class=mlg],[Mlg])],[]).


skribu_signojn(text,s(S)) :-  
  format('~s',[S]).
skribu_signojn(html,s(S)) :-  
  atom_codes(Sgn,S), xml_quote_cdata(Sgn,Quoted,utf8), write(Quoted).

skribu_nombron(n(N)) :-  format('~s',[N]).


% uzenda kiel: uskleco(Uskl,Vorto,U,Analizita,A)
% Uskl povas esti: 
% - same
% - 1:0 (komenca majusklo)
% - 1:1 (tutmajuskla)

% ni ne facile povas remeti la origina majusklecon
% sed ni montras la originan en [...] antaŭ la
% analizita vorto

uskleco(_:1,Vorto,U,Analizita,Analizita) :-
  format(atom(U),'[~s:] ',[Vorto]),!.

% uskleco dum analizo perdiĝis, sed ni remetas ĝin
% laŭ la origina vorto
uskleco(1:0,_,'',Analizita,Ana) :-
  atomic(Analizita), % Formato=text
  atom_codes(Analizita,[A|Nalizita]),
  to_upper(A,A1),
  atom_codes(Ana,[A1|Nalizita]).

% Formato=html
uskleco(1:0,_,'',[element(El,Attr,[C|Ontent])],[element(El,Attr,[C1|Ontent])]) :-
  atom_codes(C,[A|R]),
  to_upper(A,A1),
  atom_codes(C1,[A1|R]).

% senŝanĝa
uskleco(_,_,'',Analizita,Analizita).

/***

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

***/


