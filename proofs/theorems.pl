% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/legacyrescue').

% Domain: every legacy call over lists from [], [a], [a, b], with each argument either given or left open
% where that is safe, and every conjunction, disjunction and negation of two of them.
l(L) :- member(L, [[], [a], [a, b]]).
call_d(concat_old(B, A, _)) :- l(A), l(B).
call_d(concat_old(_, _, C)) :- l(C).
call_d(len_old(_, L)) :- l(L).
call_d(len_old(N, L)) :- l(L), between(0, 2, N).
call_d(rev_old(L, _)) :- l(L).
call_d(member_old(L, _)) :- l(L).
call_d(member_old(L, a)) :- l(L).
goal_d(G) :- call_d(G).
goal_d(G) :- call_d(A), call_d(B), member(G, [(A, B), (A ; B), (A, \+ B)]).

% 1. After rescue no deprecated call remains.
theorem(nothing_old_left) :- forall(goal_d(G), ( rescue(G, G2), deprecated(G2, []) )).

% 2. The rescued goal has exactly the same answers as the old one.
theorem(same_answers) :- forall(goal_d(G), ( rescue(G, G2), term_variables(G, Vs), findall(Vs, legacyrescue:G, A1), findall(Vs, legacyrescue:G2, A2), A1 =@= A2 )).

% 3. Rescuing twice is the same as rescuing once.
theorem(idempotent) :- forall(goal_d(G), ( rescue(G, G2), rescue(G2, G3), G3 == G2 )).

% 4. Goals with no legacy calls are left alone, and every rule maps to a defined current predicate with a permutation of its arguments.
theorem(leaves_new_code_alone) :- forall(member(G, [append(_, _, [a]), (length([a], N), N > 0), \+ member(b, [a])]), ( rescue(G, G2), G2 == G )), forall(rule(_/Ar, New, Order), ( numlist(1, Ar, Is), msort(Order, Is), current_predicate(lists:New/Ar) -> true ; New == length )).
