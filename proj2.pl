%  File     : proj2.pl
%  Author   : Dafu Ai 766586
%  Origin   : Monday, 2 October 2017
%  Purpose  : COMP30020 Project 2 - Math Puzzle Solver
%  Note     : This is the main & only source file for this project.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% My approach simply utilizes the funcationality provided by
%% the constraint programming library. Achieves a very high efficiency.
%% 1. Apply all constraints with procedures of my own and built-in (eg sum/3).
%% 2. Get the ground solution with maplist/2 and label/1.
%% 3. Done!
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Libraries used.
:- ensure_loaded(library(clpfd)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% puzzle_solution(Puzzle)
%% Solves the Math Puzzle (Puzzle will be ground and cohere with the rules).
%% Puzzle    : as described in the project spec.
puzzle_solution(Puzzle) :-
  Puzzle = [_|Rows],                      % Apply the four constraints below
  number_range_constraint(Rows),
  diagonals_constraint(Rows),
  rows_constraint(Rows),
  columns_constraint(Puzzle),
  maplist(label, Puzzle).                 % Find the ground solution!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% number_range_constraint(Rows)
%% Apply constraint to the Rows (i.e. the puzzle) such that square is
%% Rows      <- expect all rows of the Puzzle except the heading row.

number_range_constraint(Rows) :-
  inner_rows(Rows, InnerRows),
  append(InnerRows, Vs), Vs ins 1..9.     % Apply number range contraint

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% inner_rows(Rows, InnerRows)
%% Find inner rows (i.e. all number squares) so that they can be applied
%%   with the number constraint. Tail recursive.
%% Rows      <- expect all rows of the Puzzle except the heading row.
%% InnerRows -> gives rows where the heading (i.e. first element) has been
%%              excluded.

inner_rows(Rows, InnerRows) :-
  inner_rows(Rows, [], InnerRows).

inner_rows([], InnerRows, InnerRows).
inner_rows([Row|TailRows], InnerRows0, InnerRows) :-
  Row = [_|Content],
  append(InnerRows0, [Content], InnerRows1),
  inner_rows(TailRows, InnerRows1, InnerRows).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% diagonals_constraint(Rows)
%% Apply constraint to Rows such that all squares on the diagonal are of the
%%   same value. Tail recursive.
%% Rows <- expect all rows of the Puzzle except the heading row.

diagonals_constraint(Rows) :-
  Rows = [Row1|Rx],
  nth0(1, Row1, DiagFirst),               % Special case for 0th row
  diagonals_constraint(DiagFirst, 2, Rx).

diagonals_constraint(_, _, []).
diagonals_constraint(DiagPrev, N, RestRows) :-
  RestRows = [Row|TailRows],
  nth0(N, Row, DiagCurr),
  DiagCurr #= DiagPrev,                   % Compare current and prev diagnal val
  N1 is N + 1,                            % Increment index for next row
  diagonals_constraint(DiagPrev, N1, TailRows).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% rows_constraint(Rows)
%% Apply Row constraint (as below) to Rows
%% Rows <- expect all rows of the Puzzle except the heading row.

rows_constraint([]).
rows_constraint(Rows) :-
  Rows = [Row|TailRows],
  row_constraint(Row),
  rows_constraint(TailRows).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% row_constraint(Row)
%% Apply constraint Row (well, strictly speaking, either Row/Column)
%%   such that the given row/col satisfy the following rules:
%% 1. Row contains no repeated digits
%% 2. The heading of reach row and column holds
%%    either the sum or the product of all the digits in that row or column
%% Row <- a row in the puzzle.

row_constraint(Row) :-
  Row = [Heading|Squares],
  all_distinct(Squares),
  (   sum(Squares, #=, Heading);            % Just use the build-in
      product_constraint(Squares, Heading)  % My own contraint procedure
  ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% columns_constraint(Puzzle)
%% Apply constraints to columns of the Puzzle.
%% Take the transpose to get the columns, and
%%   just treat columns as rows!
%% Puzzle  <- expect as described in the project spec.

columns_constraint(Puzzle) :-
  transpose(Puzzle, [_|TransposeRows]),
  rows_constraint(TransposeRows).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% product_constraint(Squares, Product)
%% Apply constraint to the Squares such that
%%   the heading of reach row and column holds
%%   either the sum or the product of all the digits in that row or column
%% Tail recursive.
%% Squares <- expect all the squares in a row
%% Product <- expect the heading

product_constraint(Squares, Product) :-
  product_constraint(Squares, 1, Product).

product_constraint([], Product, Product).
product_constraint([Square|TailSquares], Product0, Product) :-
  Product1 #= Product0 * Square,
  product_constraint(TailSquares, Product1, Product).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
