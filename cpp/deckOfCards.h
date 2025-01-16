
/*

SPECIFICATION FILE

-- 4 CLASSES:
	-- gameMode
	-- player
	-- createCard
	-- createDeck

*/

#include <string>
#include <unordered_map>
#include <list>
#include <vector>
#include "globals.h"
using namespace std;

// PUBLIC METHOD TO BE CALLED WIHTOUT SPECIFIYING OBJECT
int rankSuits(char suit);
int getFaceValue(const string& faceString);

class createDeck;

class createCard{
public:

/*
 * CLASS TO BE USED TO INITIALLY CREATE DECK OF CARDS USING ARRAY OF CREATECARDS
 */ 
	string suit;
	string face;

	/// CONSTRUCTORS
	createCard();
	createCard(string i, string j);


};

class gameMode{
public:

/*
 * CLASS TO BE USED WHEN AN INPUT FILE IS GIVEN RATHER THAN CREATING OUR OWN DECK
 */

	string entries[6][5]; 	// holds the deck with each entry as a specific card
	string filename;	// holds name of input file
	string testArray[6];	// holds the 6 hands of cards

	/// CONSTRUCTORS
	gameMode();
	gameMode(bool test);

	/// METHODS
	void readFile(string filename);		// read the input file
	void setTestDeck();			// set the test deck
	void callDeckClass(createDeck& b);	// call rankHands in createDeck class
};

class player{
public:

/*
 * CLASS TO BE USED BY CREATEDECK CLASS
 * 	-- handles each hand of cards
 */

	string cards;
	string hand;
	int order;
	list<string> wordList;	
	unordered_map<string, int> wordCount;

	/// CONSTRUCTORS
	player();
	player(string hand2, list<string> wordList2, int order2); 

	/// METHODS
	void setFinalScores();
	void convertHand(string cards);
	void evaluateHand();
private:
	vector<string> keepCount;
    	unordered_map<char, int> suitCount;
    	unordered_map<int, int> rankCount;
    
    	bool isFlush();
    	bool isStraight();
    	bool isRoyal();
    	void findPairs();

};

class createDeck{
public:
		
/*
 * CLASS FOR CREATING DECK, RANKING AND PRINTING
 * 	-- uses createCard class
 * 	-- uses player class 
 */ 
	player result[6];
	string c1;
	string c2;
	string c3;
	string c4;
	string c5;
	string c6;
	createCard deckArray[4][13];	
	string deltCards[6];
	int rows = sizeof(deckArray) / sizeof(deckArray[0]);
	int cols = sizeof(deckArray[0]) / sizeof(deckArray[0][0]);
	
	/// CONSTRUCTORS
	createDeck(); 
	createDeck(bool test);
	
	/// METHODS
	void retrieveDeck(gameMode mode);
	void retrieveCard();
	void shuffleDeck();
	void printHands();
	void dealHands();
	void remainingDeck();
	void rankHands(string arr[]);
	void fillBlanks();
	void swap(player& a, player& b);
	void tieBreakers();
	void sortOrder();
	vector<int> getKickers(const player& p);
	char getHighCardSuit(const player& p);
	bool compareTOAK(const vector<int>& h1, const vector<int>& h2);
	char getHighCardNIP(const player& p);
	char getHighCardNI2P(const player& p);
	void printResult();
	char getPairSuit(const player& p);
	vector<int> getTwoPairRanks(const player& p);
	int getKicker(const player& p);
	int getPairRank(const player& p);
	int getHighCard(const player& p);
	int getTOAKRank(const player& p);
	int getFOAKRank(const player& p);
};

