:- module(cases, [title/1, case/3]).
:- use_module('../prolog/legacyrescue').
:- use_module(engine).
title('legacyrescue').
l_g(L) :- rnd_int(0, 3, N), length(L, N), maplist([X]>>rnd_pick([a, b, c], X), L).
call_g(G) :- rnd_int(1, 5, K), ( K =:= 1 -> l_g(A), l_g(B), G = concat_old(B, A, _) ; K =:= 2 -> l_g(L), G = len_old(_, L) ; K =:= 3 -> l_g(L), G = rev_old(L, _) ; K =:= 4 -> l_g(L), rnd_pick([a, b], X), G = member_old(L, X) ; rnd_pick([append([a], [b], _), length([a], _), reverse([a, b], _)], G) ).
goal_g(G) :- rnd_int(1, 4, K), call_g(A), call_g(B), nth1(K, [A, (A, B), (A ; B), findall(x, A, _)], G).
case(rescue, [G], rescue) :- goal_g(G).
case(deprecated, [G], deprecated) :- goal_g(G).
case(answers, [G], answers) :- goal_g(G).
answers(G, A-B) :- rescue(G, G2), term_variables(G, Vs), findall(Vs, legacyrescue:G, A), findall(Vs, legacyrescue:G2, B).
