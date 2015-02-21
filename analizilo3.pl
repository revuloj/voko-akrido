%:- use_module(library(sgml)).

%:-consult('vortaro.pl').
:-consult('gra/gramatiko.pl').
:-consult('gra/vorto_gra.pl').


:- multifile r/2, v/2, mlg/1, nr/2, nr_/2.

%:-consult('vrt/v_esceptoj.pl').
%:-consult('vrt/v_mallongigoj.pl').
%:-consult('vrt/v_revo_mallongigoj.pl').
:-consult('vrt/v_elementoj.pl').
:-consult('vrt/v_vortoj.pl').
%:-consult('vrt/v_fremdvortoj.pl').
:-consult('vrt/v_revo_nomoj.pl').
% vicordo gravas, vortelementoj kiel radikoj
% rekoniĝu nur post la pli longaj "normalaj" radikoj
:-consult('vrt/v_revo_radikoj.pl').
:-consult('vrt/v_revo_vortoj.pl').
:-consult('vrt/v_radikoj.pl').
