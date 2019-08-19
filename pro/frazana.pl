/***

% una pasho: transformu liston da vortoj en analizitajn vortojn, ekz. tiel
% vortanalizo("kiuj",V,S),functor(F,S,1), term_variables(F,[V]).
% F = pron('kiu/j')
% alternative al dunivela listo [['kiu/j',pron],['ir/is',verb]...]

% dua pasho: frazanalizo sur la listo de analizitaj vortoj
***/

/******************* vortspecoj kaj kazoj *************/

v_pron(Pron) --> [pron(Pron)].

v_pron(Pron) --> [perspron(Pron)].

v_subst(Vorto) --> [subst(Vorto)].

v_subst(Vorto) --> [best(Vorto)].

v_subst(Vorto) --> [parc(Vorto)].

v_adj(Vorto) --> [adj(Vorto)].

v_adv(Vorto) --> [adv(Vorto)].

v_prep(Vorto) --> [prep(Vorto)].

v_nombr(Vorto) --> [nombr(Vorto)].

v_art(Vorto) --> [art(Vorto)].

v_konj(Vorto) --> [konj(Vorto)].


/**
pron([_,Speco]) :-
	sub(Speco,'pron').

subst([_,Speco]) :-
	sub(Speco,'subst').

adj([_,'adj']).

art([_,'art']).

prep([_,'prep']).

nombr([_,'nombr']).
**/

% last ne funkcias kiel antau 30 jaroj, do mir redifinis
%lasta(Fin,V) :-
%  atomic_list_concat(L,',',V),
%  lists:last(L,Fin).

subst_kazo(Vorto,'n') :-
  atomic_list_concat(Partoj,'/',Vorto),
  last(Partoj,Fin),
  memberchk(Fin,[on,ojn]).

subst_kazo(Vorto,'') :-
  atomic_list_concat(Partoj,'/',Vorto),
  last(Partoj,Fin),
  memberchk(Fin,[o,oj]).

adj_kazo(Vorto,'n') :-
  atomic_list_concat(Partoj,'/',Vorto),
  last(Partoj,Fin),
  memberchk(Fin,[an,ajn]).

adj_kazo(Vorto,'') :-
  atomic_list_concat(Partoj,'/',Vorto),
  last(Partoj,Fin),
  memberchk(Fin,[a,aj]).

adv_kazo(Vorto,'n') :-
  atomic_list_concat(Partoj,'/',Vorto),
  last(Partoj,Fin),
  Fin = en.

adv_kazo(Vorto,'') :-
  atomic_list_concat(Partoj,'/',Vorto),
  last(Partoj,Fin),
  Fin = e.

pron_kazo(Pron,'n') :-
  atomic_list_concat(Partoj,'/',Pron),
  last(Partoj,Fin),
  memberchk(Fin,[n,jn]).

pron_kazo(Pron,'') :-
  atomic_list_concat(Partoj,'/',Pron),
  last(Partoj,Fin),
  \+ memberchk(Fin,[n,jn]).

v_subst(Vorto,Kazo) --> v_subst(Vorto),
  { subst_kazo(Vorto,Kazo) }.

v_pron(Vorto,Kazo) --> v_pron(Vorto),
  { pron_kazo(Vorto,Kazo) }.

v_adj(Vorto,Kazo) --> v_adj(Vorto),
  { adj_kazo(Vorto,Kazo) }.

v_adv(Vorto,Kazo) --> v_adv(Vorto),
  { adv_kazo(Vorto,Kazo) }.


/**
subst_nomin([V,Speco]) :-
	sub(Speco,'subst'),
	lasta(Fin,V),
	memberchk(Fin,['o','oj']).

subst_akuz([V,Speco]) :-
	sub(Speco,'subst'),
	lasta(Fin,V),
	memberchk(Fin,['on','ojn']).

pron_nomin([V,Speco]) :-
	sub(Speco,'pron'),
	\+lasta('n',V).

pron_akuz([V,Speco]) :-
	sub(Speco,'pron'),
	lasta('n',V).

adv([_,'adv']).

adj_nomin(Vorto) :-
	Vorto = [V,'adj'],
	lasta(Fin,V),
	memberchk(Fin,['a','aj']).

adj_akuz([V,'adj']) :-
	lasta(Fin,V),
	memberchk(Fin,['an','ajn']).
**/

konj_verb(Verbo) :-
  atomic_list_concat(Partoj,'/',Verbo),
  last(Partoj,Fin),
  memberchk(Fin,[as,is,os,us,u]).

inf_verb(Verbo) :-
  atomic_list_concat(Partoj,'/',Verbo),
  last(Partoj,Fin),
  Fin = i.

verbo(Vorto,tr) --> [tr(Vorto)].
verbo(Vorto,ntr) --> [ntr(Vorto)].
verbo(Vorto,verb) --> [verb(Vorto)].

v_asisosusu(Vorto,Speco) -->
  verbo(Vorto,Speco),
  { konj_verb(Vorto) }.

v_inf(Vorto,Speco) -->
  verbo(Vorto,Speco),
  { inf_verb(Vorto) }.


/**
verbo([_,Speco]) :-
	sub(Speco,'verb').

asisosusu([V,Speco]) :-
	21sub(Speco,'verb'),
	lasta(Fin,V),
	memberchk(Fin,['as','is','os','us','u']).

inf([V,Speco]) :-
	sub(Speco,'verb'),
	lasta('i',V).
**/


v_infprep(Vorto) --> [infprep(Vorto)].

v_intj(Vorto) --> [intj(Vorto)].


/**
infprep([_,'infprep']).

intj([_,'intj']).
**/

/******************* vortgrupoj **********/

%  senlime 
g_adv([Adv]) --> v_adv(Adv).

%  tute senlime 
g_adv([Adv|Vortoj]) --> v_adv(Adv), g_adv(Vortoj).

% tute kaj senlime 
g_adv([Adv,Konj|Vortoj]) --> v_adv(Adv), v_konj(Konj), g_adv(Vortoj).



% granda
g_adj_([Adj],Kazo) --> v_adj(Adj,Kazo).

% tute kaj senlime granda 
g_adj_(Vortoj,Kazo) --> g_adv(Adv), g_adj_(Adj,Kazo),
  { append(Adv,Adj,Vortoj) }.


g_adj(Vortoj,Kazo) --> g_adj_(Vortoj, Kazo).

% tute kaj senlime granda kaj ege stulta
g_adj(Vortoj,Kazo) --> g_adj_(Adj1, Kazo), v_konj(Konj), g_adj_(Adj2,Kazo),
  { append([Adj1,[Konj],Adj2],Vortoj) }.



% oni kontrolu, chu ne nur kazo sed ankau nombro
% kongruas inter atributoj kaj subst-oj

g_subst_([Vorto],Kazo) --> v_subst(Vorto,Kazo).

g_subst_(Vortoj,Kazo) --> g_adj(Adj,Kazo), g_subst_(Subst,Kazo),
  { append(Adj,Subst,Vortoj) }.

% KOREKTU: senfina ciklo...
%%g_subst_(Vortoj,Kazo) --> g_subst_(Vj,Kazo), v_adj(V,Kazo),
%%  { append(Vj,[V],Vortoj) }.

g_subst_([Nombro|Vortoj],Kazo) --> v_nombr(Nombro), g_subst_(Vortoj,Kazo).


g_subst__(Vortoj,Kazo) --> g_subst_(Vortoj,Kazo).

% KOREKTU: la adverbo rilatas al la adjektivo, ekz. "tute alia parto",
% do necesas difino de adjhektiva grupo g_adj...
%g_subst__([Adv|Vortoj],Kazo) --> v_adv(Adv), g_subst_(Vortoj,Kazo).


% postpendigita adjektivogrupo
g_subst(Vortoj,Kazo) --> g_subst_(Subst,Kazo), g_adj(Adj,Kazo),
  { append(Subst,Adj,Vortoj) }.

g_subst(Vortoj,Kazo) --> g_subst__(Vortoj,Kazo).

g_subst([Art|Vortoj],Kazo) --> v_art(Art), g_subst__(Vortoj,Kazo).



/******************** subjekto *************/

% la granda urso
r_subjekto_(Vortoj) -->
  g_subst(Vortoj,'').

% li
r_subjekto_([Pron]) -->
  v_pron(Pron,'').

% tiuj uloj
r_subjekto_([Pron|Vortoj]) -->
  v_pron(Pron,''),
  g_subst(Vortoj,'').


r_subjekto__(Vortoj) --> r_subjekto_(Vortoj).

% ankau li, ne la granda urso, ankau tiuj uloj
r_subjekto__([Adv|Vortoj]) --> v_adv(Adv), r_subjekto_(Vortoj).


r_subjekto(Vortoj) -->
  r_subjekto__(Vortoj).

r_subjekto(Vortoj) -->
  r_subjekto__(Vortoj1),
  v_konj(Konj),
  r_subjekto(Vortoj2),
  { append([Vortoj1,[Konj],Vortoj2],Vortoj) }.


/********************* predikato ***********/

r_predikato([Vorto]) -->
	v_asisosusu(Vorto,_).


/****************** objekto ****************/

% fakte oni permesu ankau -ion/iun-pronomoj
r_objekto_([Pron]) --> v_pron(Pron,'n').

r_objekto_(Vortoj) --> g_subst(Vortoj,'n').

% tiujn ulojn
r_objekto_([Pron|Vortoj]) -->
  v_pron(Pron,'n'),
  g_subst(Vortoj,'n').


r_objekto__(Vortoj) --> r_objekto_(Vortoj).

% ankau lin, ne la grandan urson, ankau tiujn ulojn
r_objekto__([Adv|Vortoj]) --> v_adv(Adv), r_objekto_(Vortoj).


r_objekto(Vortoj) -->
  r_objekto__(Vortoj).

r_objekto(Vortoj) -->
  r_objekto__(Vortoj1),
  v_konj(Konj),
  r_objekto(Vortoj2),
  { append([Vortoj1,[Konj],Vortoj2],Vortoj) }.


/******************* nerekta objekto ********/

% ekz. antaŭ li
r_prepozitivo([Prep,Pron]) -->
  v_prep(Prep),
  v_pron(Pron).

% ekz. pri la granda urso; en la altan domon
r_prepozitivo([Prep|Vortoj]) -->
  v_prep(Prep),
  g_subst(Vortoj,_).

/******************* adverbo ****************/

% ekz. ne; hodiaŭ; rapide...
r_adverbo(Adv) -->
  v_adv(Adv).


/****************** predikativo **************/


/**
adjektivo([Vorto],Akuz) :-
	adj_akuz(Vorto), Akuz='n'; 
	adj_nomin(Vorto), Akuz=''.

adjektivo([Adv|Vortoj],Akuz) :-
	adv(Adv),
	adjektivo(Vortoj,Akuz).
**/


% li estas "granda"
r_predikativo([Adj]) -->
  v_adj(Adj,'').

% li estas "aparte granda"
% KOREKTU: g_adj anst. v_adj?
r_predikativo([Adv,Adj]) -->
  v_adv(Adv),
  v_adj(Adj,'').

/******************* nombro ******************/

g_nombr([Nombro]) -->
  v_nombr(Nombro).

g_nombr([N|Nj]) -->
  v_nombr(N),
  g_nombr(Nj).

/******************** interjekcio *************/

r_interjekcio([Vorto]) -->
	v_intj(Vorto).

/********************* infinitivo *************/

% rajdi
r_infinitivo([Vorto]) -->
	v_inf(Vorto,_).

% for rajdi
r_infinitivo([V1|Vortoj]) -->
	v_infprep(V1),
	r_infinitivo(Vortoj).

/********************* frazo ****************/

% frazo estas vico de iuj frazpartoj kiel subjekto, objekto, ktp.
% do eblas ankaý nekompletaj frazoj. Oni poste povas kontroli, æu
% la frazo estas kompleta. Skribitaj frazoj normale estu kompletaj
% parolitaj ne nepre.

% anstatau subj, obj, pred eble uzu demandvortojn
% kio, kiu, kion faras, sed tiukaze necesas ankau
% analizi iomete la sencon




f_frazeto([]) --> [].

f_frazeto([subj(Vortoj)|Resto]) --> r_subjekto(Vortoj), f_frazeto(Resto).

f_frazeto([obj(Vortoj)|Resto]) --> r_objekto(Vortoj), f_frazeto(Resto).

f_frazeto([pred(Vortoj)|Resto]) --> r_predikato(Vortoj), f_frazeto(Resto).

f_frazeto([prep(Vortoj)|Resto]) --> r_prepozitivo(Vortoj), f_frazeto(Resto).

f_frazeto([adv(Vortoj)|Resto]) --> r_adverbo(Vortoj), f_frazeto(Resto).

f_frazeto([prdk(Vortoj)|Resto]) --> r_predikativo(Vortoj), f_frazeto(Resto).

f_frazeto([inf(Vortoj)|Resto]) --> r_infinitivo(Vortoj), f_frazeto(Resto).

%%%%%%%%%

f_frazo(Vortoj) -->
  f_frazeto(Vortoj).

f_frazo([konj(Konj)|Vortoj]) -->
  v_konj(Konj),
  f_frazeto(Vortoj).

/***
frazo(Vortoj,Rezulto) :-
	frazeto(Vortoj,Rezulto).

frazo(Vortoj,Rezulto) :-
	append(F1,F2,Vortoj),
	interjekcio(F1),
	write('intj '), write_ln(F1),
	frazeto(F2,Rez),
	Rezulto = [[F1,'intj']|Rez].
***/

/********************* vortigo der litervico ***********************/

% FARENDA: anstatauigu per nova "legilo.pl"
/**
litero(C,C1) :-
        C >= 97, C =< 122, C1=C.         % 'a'...'z'
litero(C,C1) :-
        C >= 65, C =< 90, C1 is C-65+97. % 'A'...'Z' -> 'a'...'z'
litero(39,39).                  % apostrofo

legu_vorton([C1|Str],[C|Resto]) :-
	litero(C1,C), !,
        legu_vorton(Str,Resto).
legu_vorton(_,[]).

vort_komenco([C1|Str],RStr) :-
	litero(C1,_),!,
	RStr=[C1|Str];
	vort_komenco(Str,RStr).
vort_komenco(_,[]).

legu_vortojn(LStr,Vortoj) :-
	LStr\=[],!,
	legu_vorton(LStr,LVorto),
	name(Vorto,LVorto),
	append(LVorto,S,LStr),
	vort_komenco(S,RStr),
	legu_vortojn(RStr,Vj),
	Vortoj=[Vorto|Vj].
legu_vortojn(_,[]).

vortigu(Str,Vortoj) :-
	name(Str,LStr),
	legu_vortojn(LStr,Vortoj).
**/


/******************** elig-funkcioj ********************/

eligu_vorterojn([Vortero]) :-
	write(Vortero).

eligu_vorterojn([Vortero|Resto]) :-
	write(Vortero), write(''''),
	eligu_vorterojn(Resto).

eligu_vorton([Vorto,Speco],_) :-
	%eligu_vorterojn(Vorto),
        write(Vorto),
	write(' ('), write(Speco), write(') ').

eligu_frazeron([Frazero,Tipo],_) :-
	write(Tipo), write(' = '),
	maplist(eligu_vorton,Frazero,_), nl.

eligu_strukturon(Frazstrukt) :-
	nl, write_ln('Solvo:'),
	maplist(eligu_frazeron,Frazstrukt,_), !, nl.

/********************** testoj ****************/

test_subj(1,F) :-
  phrase(r_subjekto(F), [perspron(li),konj(kaj),art(la),adj('grand/a'),best('urs/o')]).

test_subj(2,F) :-
  phrase(r_subjekto(F), [pron('tiu/j'),best('ul/oj')]).

test_obj(1,F) :-
  phrase(r_objekto(F),[pron('tiu/jn'),konj('aŭ'),art(la),subst('hund/on')]).

test_obj(2,F) :-
  phrase(r_objekto(F),[pron('tiu/jn'),konj('sed'),adv(ne),art(la),subst('hund/on')]).

test_obj(3,F) :-
  phrase(r_objekto(F),[adv(ne),art(la),subst('hund/on')]).

test_prep(1,F) :-
  phrase(r_prepozitivo(F), [prep(en), adv('tut/e'), adj('ali/a'), subst('part/o')]).

test(1,F) :-
  phrase(f_frazo(F), [perspron(li), ntr('ir/is')]).

test(2,F) :-
  phrase(f_frazo(F), [art(la),adj('grand/a'),best('urs/o'),adv('long/e'),ntr('dorm/is')]).

test(3,F) :-
  phrase(f_frazo(F), [art(la),adj('grand/a'),best('urs/o'),ntr('dorm/is'),prep('ĝis'),art(la),subst('maten/o')]).

test(4,F) :-
  phrase(f_frazo(F), [perspron(li),ntr('vol/is'),tr('kares/i'),art(la),subst('hund/on')]).

test(5,F) :-
  phrase(f_frazo(F), [perspron(li),konj(kaj),art(la),adj('grand/a'),best('urs/o'),ntr('vol/is'),tr('kares/i'),
    pron('tiu/jn'),konj('aŭ'),art(la),subst('hund/on')]).

test(6,F) :-
  phrase(f_frazo(F), [konj(tamen),perspron(li),konj(kaj),art(la),adj('grand/a'),best('urs/o'),ntr('vol/is'),tr('kares/i'),
    pron('tiu/jn'),konj('sed'),adv(ne),art(la),subst('hund/on')]).



