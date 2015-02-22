%:- use_module(library(sgml)).

:-consult('vortaro3.pl').
:-consult('gra/gramatiko.pl').
:-consult('gra/vorto_gra.pl').

vortanalizo(Vorto,Ana,Spc) :-
  analyze(Vorto,Struct,Spc),
  reduce(Struct,Ana).

