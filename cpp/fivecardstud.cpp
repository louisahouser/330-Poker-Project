/*

CLIENT FILE

-- 4 CLASSES USED:
	-- gameMode
	-- createDeck

*/


#include "deckOfCards.h"
#include <iostream>
#include <fstream>

int main(int argc, char *argv[]){

	// First mode is "random"
	if(argc == 1){

		cout << "*** POKER HAND ANALYZER ***\n" << endl;

		bool test = false;

		// create ORDERED deck of cards from symbols
		createDeck deck(test);		
		
		// shuffle the deck
		deck.shuffleDeck();
		
		// display shuffled deck
		deck.retrieveCard();

		// deal the six hands from the top of the deck
		deck.dealHands();

		cout << endl;

		deck.printHands();
		
		cout << endl;

		// show what remains in the deck
		deck.remainingDeck();
		
		deck.printResult();

	///// HANDLE NOT GOOD ARG VALUE
	}else if(argc != 2){
		cerr << "Usage: " << argv[0] << " <filename> " << endl;
		
	///// HANDLE TEST DECK
	}else{
		cout << " *** P O K E R   H A N D  A N A L Y Z E R ***\n\n" << endl;
		cout << "*** USING TEST DECK ***\n" << endl;

		string filename = argv[1];
		cout << "*** File: " << filename << endl;

		gameMode mode;
		mode.readFile(filename);
		createDeck testDeck;
		testDeck.retrieveDeck(mode);
		mode.callDeckClass(testDeck);
		testDeck.printResult();
		

	}
	return 0;

}
