% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/legacyrescue').

% Domain: every legacy call over lists from [], [a], [a, b], with each argument either given or left open
% where that is safe, and every conjunction, disjunction and negation of two of them; and the same
% calls passed by name to call/N, maplist, include, exclude and foldl, alone and before a legacy call.
l(L) :- member(L, [[], [a], [a, b]]).
call_d(concat_old(B, A, _)) :- l(A), l(B).
call_d(concat_old(_, _, C)) :- l(C).
call_d(len_old(_, L)) :- l(L).
call_d(len_old(N, L)) :- l(L), between(0, 2, N).
call_d(rev_old(L, _)) :- l(L).
call_d(member_old(L, _)) :- l(L).
call_d(member_old(L, a)) :- l(L).
% Retired predicates passed by name to call/N, maplist, include, exclude and foldl.
meta_d(call(rev_old, L, _)) :- l(L).
meta_d(call(concat_old(B), A, _)) :- l(A), l(B).
meta_d(call(len_old, N, L)) :- l(L), between(0, 2, N).
meta_d(maplist(len_old, _, [L1, L2])) :- l(L1), l(L2).
meta_d(maplist(rev_old, [L], _)) :- l(L).
meta_d(maplist(concat_old(B), [A1, A2], _)) :- l(A1), l(A2), l(B).
meta_d(include(member_old(L), [a, b], _)) :- l(L).
meta_d(exclude(member_old(L), [a, b], _)) :- l(L).
meta_d(foldl(concat_old, [L1, L2], [], _)) :- l(L1), l(L2).
goal_d(G) :- call_d(G).
goal_d(G) :- meta_d(G).
goal_d((A, B)) :- meta_d(A), call_d(B).
goal_d(G) :- call_d(A), call_d(B), member(G, [(A, B), (A ; B), (A, \+ B)]).

% 1. After rescue no deprecated call remains.
theorem(nothing_old_left) :- forall(goal_d(G), ( rescue(G, G2), deprecated(G2, []) )).

% 2. The rescued goal has exactly the same answers as the old one.
theorem(same_answers) :- forall(goal_d(G), ( rescue(G, G2), term_variables(G, Vs), findall(Vs, legacyrescue:G, A1), findall(Vs, legacyrescue:G2, A2), A1 =@= A2 )).

% 3. Rescuing twice is the same as rescuing once.
theorem(idempotent) :- forall(goal_d(G), ( rescue(G, G2), rescue(G2, G3), G3 == G2 )).

% 4. Goals with no legacy calls are left alone, and every rule maps to a defined current predicate with a permutation of its arguments.
theorem(leaves_new_code_alone) :- forall(member(G, [append(_, _, [a]), (length([a], N), N > 0), \+ member(b, [a])]), ( rescue(G, G2), G2 == G )), forall(rule(_/Ar, New, Order), ( numlist(1, Ar, Is), msort(Order, Is), current_predicate(lists:New/Ar) -> true ; New == length )).

% An old name is anywhere in the term: as a goal, or passed by name as a closure.
has_old_name(G) :- sub_term(S, G), nonvar(S), ( atom(S) ; compound(S) ), functor(S, N, _), rule(N/_, _, _), !.

% 5. After rescue no retired predicate name is left anywhere in the goal, including closures.
theorem(no_old_name_left) :- forall(goal_d(G), ( rescue(G, G2), \+ has_old_name(G2) )).

% 6. deprecated/2 reports something exactly when a retired name is in the goal.
theorem(deprecated_finds_every_old_name) :- forall(goal_d(G), ( deprecated(G, D), ( D == [] -> \+ has_old_name(G) ; has_old_name(G) ) )).
