# FiveCardStud

This repo holds all src files for fivecardstud poker game written in four different languages. These languages include Java, c++, c, and Fortran. There are directories within this repo for each language which will contain the code for that specified language.


## CPP

This folder contains all of the source files for running fivecardstud poker in c++. 
There are four files: fivecardstud.cpp	deckOfCards.cpp  deckOfCards.h	globals.h

To pull files:

git checkout -- cpp

To Compile:
g++ -g -o fivecardstud deckOfCards.cpp fivecardstud.cpp

To Run Random:
./fivecardstud

To Run Handsets:
./fivecardstud ../handsets/<filename>

## JAVA

This folder contains all of the source files for running fivecardstud poker in Java.
There are 6 files: CreateCard.java  CreateDeck.java  FiveCardStud.java  GameMode.java  Globals.java  Player.java

To pull files:

git checkout -- java

To Compile: 

javac *.java

To Run Random:

java FiveCardStud

To Run Handsets:

java FiveCardStud ../handsets/<filename>

## CSHARP

This folder contains all of the source files for running fivecardstud poker in C#.

There are 6 files: CreateCard.cs CreateDeck.cs FiveCardStud.cs GameMode.cs Globals.cs Player.cs

To pull files:

git checkout -- csharp

To Compile: 

mcs CreateCard.cs CreateDeck.cs FiveCardStud.cs GameMode.cs Globals.cs Player.cs -out:FiveCardStud.exe

To Run Random:

mono FiveCardStud.exe

To Run Handsets:

mono FiveCardStud.exe ../handsets/<filename>

## PYTHON

This folder contains all of the source files for running fivecardstud poker in Python.

There are two files: deckOfCards.py fiveCardStud.py

To pull files:

git checkout -- python

To Compile and Run Random:

python3 fiveCardStud.py

To Compile and Run Handsets:

python3 fiveCardStud.py ../handsets/<filename>

## FORTRAN

This folder contains all of the source files for running fivecardstud poker in Fortran, however, the program itself is not fully successful as I really struggle with writing in Fortran and do not wish it upon my worst enemy (not as bad as assembly though).

There are 6 files: card_module.f08  deck_module.f08  game_mode_module.f08  hand_module.f08  poker_analyzer_f08  poker_constants.f08

To pull files:

git checkout -- Fortran

To Compile:

gfortran -c poker_constants.f08 && gfortran -c card_module.f08 && gfortran -c deck_module.f08 && gfortran -c hand_module.f08 && gfortran -c game_mode_module.f08 && gfortran poker_constants.o card_module.o deck_module.o hand_module.o game_mode_module.o poker_analyzer.f08 -o poker_analyzer

To Run Random:

./poker_analyzer

To Run Handsets:

./poker_analyzer ../handsets/<filename>

## PERL

This folder contains all of the source files for running fivecardstud poker in Perl. 

There is only one file: poker.perl

To pull files:

git checkout -- perl

To Compile & Run Random:

perl poker.perl

To Compile & Run Handsets:

perl poker.perl ../handsets/<filename>

## GO

This folder contians all of the source files for running fivecardstud poker in Go.

There are 4 files: main.go game.go deck.go go.mod

To pull files:

git checkout -- go

To Compile & Run Random:

go run *.go

To Compile & Run Handsets:

go run *.go ../handsets/<filename>

## JULIA

This folder contains all of the source files for running fivecardstud poker in Julia.

There are 3 files: DeckOfCards.jl  FiveCardStud.jl  PokerGame.jl

To pull files:

git checkout -- julia

To Compile & Run Random:

julia PokerGame.jl

To Compile & Run Handsets:

julia PokerGame.jl ../handsets/<filename>

## RUST

This folder contains all of the source files for running fivecardstud poker in Rust.

There are 6 files: card.rs deck.rs game.rs main.rs player.rs Cargo.toml

To pull files:

git checkout -- rust

To Compile:

cargo build

To Run Random:

cargo run

To Run Handsets:

cargo run ../handsets/<filename> 

## LISP

This folder contains all of the source files for running fivecardstud poker in Lisp.

There are 3 files: deck.lisp hands.lisp poker.lisp

To pull files:

git checkout -- lisp

To Compile & Run Random:

./poker.lisp

To Compile & Run Handsets:

./poker.lisp ../handsets/<filename>
