/*

IMPLEMENTATION FILE

-- 4 CLASSES:
	-- gameMode
	-- player
	-- createCard
	-- createDeck


*/

// imports

#include <iostream>
#include <unordered_map>
#include <sstream>
#include <unordered_set>
#include <iterator>
#include <list>
#include <vector>
#include <fstream>
#include <algorithm>
#include <random>
#include "deckOfCards.h"
#include "globals.h"
using namespace std;


///// GLOBAL VARIABLES INCLUDED FROM globals.h
bool RSF = false;
bool SF = false;
bool FOAK = false;
bool FH = false;
bool FLUSH = false;
bool STRAIGHT = false;
bool TOAK = false;
bool TP = false;
bool PAIR = false;
bool HC = false;

/// public method to be called on by tieBreaker to sort by weight of suit
int rankSuits(char suit){

	switch(suit){

		case 'D': return 1;
		case 'C': return 2;
		case 'H': return 3;
		case 'S': return 4;
		default: return 0;

	}	

}

int getFaceValue(const string& faceString){
	int faceVal = -1;
	
	if(faceString == "J"){
		faceVal = 11;
	}else if(faceString == "Q"){
		faceVal = 12;
	}else if(faceString == "K"){
		faceVal = 13;
	}else if(faceString == "A"){
		faceVal = 14;
	}else{
		faceVal = stoi(faceString);
	}

	return faceVal;

}

/*
 *
 * GAMEMODE ----------------------------------------------------------------
 *
 */

// no parameter constructor
gameMode::gameMode(){
	bool test = false;
}

// constructor with test bool to tell there is a file to read
gameMode::gameMode(bool test){
	test = true;
}

void gameMode::readFile(string filename){
///// READS FILE, ACCOUNTS FOR DUPLICATES AND INABILITY TO OPEN FILE
//	parses through file and builds array entries
//	calls on setTestDeck()

	string dupArray[30];
	int entryCount = 0;
	string line;
	string parsedLine;
	ifstream inputFile(filename);
	
	/// check if file cannot be opened and then exit if so
	if(!inputFile){
		cerr << "ERROR! COULD NOT OPEN FILE: " << filename << endl;
		exit(EXIT_FAILURE);
	}

	/// parse through file and exit if duplicate is found
	//	assign entries array the values of parsedLine variable
	int row = 0;
	while(getline(inputFile, line) && row < 6){
		
		stringstream ss(line);
		int col = 0;
		while(getline(ss, parsedLine, ',') && col < 5){
			bool isDup = false;

			// catch dupes
			for(int i = 0; i < entryCount; i++){
				if(dupArray[i] == parsedLine){
					cerr << "*** ERROR - DUPLICATE CARD FOUND IN DECK *** \n\n\n *** DUPLICATE: " << parsedLine << endl;
					exit(EXIT_FAILURE);
				}
			}
		
			// catch lowercase suits
			if(!isupper(parsedLine.back())){
				cerr << "*** ERROR - SUITS MUST BE UPPERCASE *** \n\n\n INVALID SUIT: " << parsedLine << endl;
				exit(EXIT_FAILURE);

			} 

			// deal with parsed line
			dupArray[entryCount++] = parsedLine;
			entries[row][col] = parsedLine;
			col++;
				
			//// Check for length of card
			if( parsedLine.length() == 1 || parsedLine.length() > 3){
				cerr << "*** ERROR - CARDS MUST BE 3 CHARACTERS LONG *** \n\n\n INVALID CARD LENGTH: " << parsedLine << endl;
				exit(EXIT_FAILURE);
			}
			parsedLine = "";
			}
		row++;
	}

	// CLOSE FILE
	inputFile.close();

	// print the contents of entries for the user to see the contents of the file given as input
	for(int i = 0; i < 6; i++){
		for(int j = 0; j < 5; j++){
			if(j == 4){	
				cout << entries[i][j] << endl;
			}else{
				cout << entries[i][j] << ",";
			}

		}
	}

	// continue through process of test deck
	setTestDeck();

}

void gameMode::setTestDeck(){

///// FORMAT THE TEST DECK TO REMOVE WHITESPACES AND CONCATENATE THEM TO BE A STRING 
//	concattenated version gets added to testArray
//	prints out testArray
	
	for(int i = 0; i < 6; i++){
		string line = "";
		for(int j = 0; j < 5; j++){
			string temp = entries[i][j];
			// erase whitespaces
			temp.erase(remove_if(temp.begin(), temp.end(), ::isspace), temp.end());
			entries[i][j] = temp;
			line += temp + " ";
		}
		// append line to testArray for printing and later use
		testArray[i] = line;
	}
	
	// print six hands to user
	cout << "\n***Here are the six hands... " << endl;
	for(int k = 0; k < 6; k++){
		cout << testArray[k] << endl;
	}
}


/*
 *
 * CREATECARD ----------------------------------------------------------------
 *
 */

createCard::createCard(){
	/// constructor with no parameters
}

/// constructor with string parameters i and j
createCard::createCard(string i, string j){

	suit = i;
	face = j;

}

/*
 *
 * PLAYER  ----------------------------------------------------------------
 *
 */

player::player(){
	/// constructor with no parameters
}

/// constructor with hand string, wordList, and order parameters
player::player(string hand2, list<string> wordList2, int order2){

	hand = hand2;
	wordList = wordList2;
	order = order2;	

	convertHand(hand);
}

void player::convertHand(string cards){

//// SEPARATES FACE AND SUIT, ASSIGNS THEM TO MAPS, AND CONVERTS FACESTRING TO INT FACEVAL
//	calls on evaluateHand() 

//prepares for next round by setting all to false to prevent overlap
RSF = false;
SF = false;
FOAK = false;
FH = false;
FLUSH = false;
STRAIGHT = false;
TOAK = false;
TP = false;
PAIR = false;
HC = false;

	/// create stringstream object of input cards so it can be parsed and separated
	stringstream iss(cards);
	string word;

	while(iss >> word){
		// add word to wordList
		wordList.push_back(word);
	
		// separate suit and face
		string faceString = word.substr(0, word.length() - 1);
		//faceString.erase(remove_if(faceString.begin(), faceString.end(), ::isspace), faceString.end());
		char suitChar = word.back();

		// keep track of number of suits
		suitCount[suitChar]++; 

		//// assign royal values a int value and convert string to int
		int faceVal;

		
		if(faceString == "10"){
			faceVal = 10;
		}else if(faceString == "J"){
			faceVal = 11;
		}else if(faceString == "Q"){
			faceVal = 12;
		}else if(faceString == "K"){
			faceVal = 13;
		}else if(faceString == "A"){
			faceVal = 14;
		}else{

			//faceVal = stoi(faceString);

            		try {
                		faceVal = stoi(faceString);
            		} catch (const invalid_argument& e) {
                		cerr << "*** ERROR - INVALID FACE STRING CONVERSION: " << faceString << endl;
                		exit(EXIT_FAILURE);
            		} catch (const out_of_range& e) {
                		cerr << "*** ERROR - FACE STRING OUT OF RANGE: " << faceString << endl;
                		exit(EXIT_FAILURE);
            		}	
		}
	
		// keep track of number of ranks
		rankCount[faceVal]++;	
		//faceString = "";
		//faceVal = 0;	
	}
	
	// continue through process by calling next method
	evaluateHand();

}

void player::evaluateHand(){

//// CALLS ON HAND FUNCTIONS TO EVALUATE AND THEN ASSIGN BOOLS
//	calls on findPairs to continue process

	bool flush = isFlush();
	bool straight = isStraight();

	if(isFlush() && isStraight() && isRoyal()){
		RSF = true;
	}else if(flush && straight){
		SF = true;
	}else if(flush){
		FLUSH = true;
	}else if(straight){
		STRAIGHT = true;
	}

	// continue through process by calling next method
	findPairs();

}

bool player::isFlush(){

//// RETURNS IF STRING IS FLUSH OR NOT

	// if suitCount = 5 then there is a flush because that means a suit appeared 5 times in the string
	for(const auto& suit : suitCount){
		if(suit.second == 5){
			return true;
		}
	}
	
	// return false if suit.second condition was not met
	return false;

}

bool player::isStraight(){

//// RETURNS IF STRING IS STRAIGHT OR NOT
//	takes account for low ace as well

	bool cont = true;
	vector<int> rankings;
	// add rankCount to vector rankings so that we can sort it
	for(const auto& rank : rankCount){
		if(rank.second == 1){

			rankings.push_back(rank.first);

		}
	}

	if(rankings.size() < 5){
		return false;
	}

	// sort the rankings to be in order
	sort(rankings.begin(),rankings.end());
	
	// check if sequential; if not then cont = false
	for(int i = 1; i < rankings.size(); i++){

		if(rankings[i] != rankings[i-1] + 1){
			cont = false;
			break;
		}

	}

	// hard coding (ish) to see if its a low ace situation
	if(rankings == vector<int>{2,3,4,5,14}){
		cont = true;
	}

	// return cont value 
	return cont;

}	


bool player::isRoyal(){

///// RETURNS IF HAND IS ROYAL BY CHECKING IF THERE IS ONE OF EACH ROYAL VALUE IN RANKCOUNT

    return rankCount[10] > 0 && rankCount[11] > 0 && rankCount[12] > 0 &&
           rankCount[13] > 0 && rankCount[14] > 0;

}

void player::findPairs(){

///// FINDS PAIRS, THREEOFAKINDS, FOUROFAKINDS, TWOPAIRS, AND FULLHOUSES

	int PAIRCount = 0;
	int TOAKCount = 0;
	int FOAKCount = 0;

	for(const auto& rank : rankCount){
		
		/// if a rank has val 4 then there are four of a kind
		if(rank.second == 4){
			FOAK = true;

		/// if a rank has val 3 then there are three of a kind
		}else if(rank.second == 3){
			TOAK = true;
		}else if(rank.second == 2){
			/// this way we can check for two pairs
			PAIRCount++; 
		}

	}

	/// check for two pair versus just pair
	if(PAIRCount == 2){
		TP = true;
	}else if(PAIRCount == 1){
		PAIR = true;
	}

	/// check for a full house and otherwise sets HC true
	if(TOAK && PAIR){
		FH = true;
	}else if(!PAIR && !TOAK && !FOAK){
		HC = true;
	}

}



void player::setFinalScores(){

///// RUNS THROUGH ALL GLOBAL BOOLS AND CHECKS THEM TO BE TRUE BY RANK
//	assigns hand, wordList, order for player constructor to be called
//	sets up for next round by setting bool to false

	if(RSF){
		hand = "Royal Straight Flush";
		wordList = wordList;
		order = 5;
		RSF = false;
	}else if(SF){
		hand = "Straight Flush";
		wordList = wordList;
		order = 6;
		SF = false;
	}else if(FOAK){
		hand = "Four of a Kind";
		wordList = wordList;
		order = 7;
		FOAK = false;
	}else if(FH){
		hand = "Full House";
		wordList = wordList;
		order = 8;
		FH = false;
	}else if(FLUSH){
		hand = "Flush";
		wordList = wordList;
		order = 9;
		FLUSH = false;
	}else if(STRAIGHT){
		hand = "Straight";
		wordList = wordList;
		order = 10;
		STRAIGHT = false;
	}else if(TOAK){
		hand = "Three of a Kind";
		wordList = wordList;
		order = 11;
		TOAK = false;
	}else if(TP){
		hand = "Two Pair";
		wordList = wordList;
		order = 12;
		TP = false;
	}else if(PAIR){
		hand = "Pair";
		wordList = wordList;
		order = 13;
		PAIR = false;
	}
	else{
		hand = "High Card";
		wordList = wordList;
		order = 14;
		
	}


}

/*
 *
 * CREATEDECK ----------------------------------------------------------------
 *
 */

createDeck::createDeck(){
// no parameter constructor 
}

/// parameter to handle false test
createDeck::createDeck(bool test){

	string suits[4] = {"D","C","H","S"};

	string faces[13] = {"A","2","3","4",
			    "5","6","7","8",
			    "9","10","J","Q",
			    "K"};

	for(int i = 0; i < 4; ++i){
	
		for(int j = 0; j < 13; ++j){
			
			deckArray[i][j] = createCard(suits[i], faces[j]); 	
			
		}

	}
}

/// parameter to retrieve testDeck
void createDeck::retrieveDeck(gameMode mode){

	for(int i = 0; i < 6; i++){
		deltCards[i] = mode.testArray[i];
	}
	
}

//int convertFaceToRank(const string& face){

//}

void createDeck::retrieveCard(){

///// CREATES STRING FROM DECKARRAY AND PRINTS VALUES FOR USER
	
	cout << "*** Shuffled 52 card deck: " << endl;

	string card = "";
	for(int k = 0; k < rows; ++k){
		for(int m = 0; m < cols; ++m){
			card = deckArray[k][m].face + deckArray[k][m].suit;
			cout << card << "  "; 
		}
		cout << endl;
	}
	
}

void createDeck::shuffleDeck(){
/*
 *
 * SHUFFLES DECK BY TURNING INTO FLAT ARRAY, SHUFFLING, THEN RETURNING TO 3D ARRAY
 *
 */
	// flatten deckArray into a 1d array
	
	vector<createCard> flat2Vec;
	for(int i = 0; i < rows; ++i){
		for(int j = 0; j < cols; ++j){

			flat2Vec.push_back(deckArray[i][j]);		

		}
	} 	


	// shuffle the array
	
	random_device randDEV;
	mt19937 g(randDEV());
	shuffle(flat2Vec.begin(), flat2Vec.end(), g);


	// turn back into 2d array plz
	
	int loc = 0;
	for(int k = 0; k < rows; ++k){
		for(int m = 0; m < cols; ++m){

			deckArray[k][m] = flat2Vec[loc++];

		}
	}

}

void createDeck::printHands(){
/*
 *
 * PRINT SIX HANDS	
 *
 */
	cout << "*** Here are the six hands..." << endl;
	
	for(int i = 0; i < 6; ++i){
		cout << deltCards[i] << endl;
	}

}

void createDeck::dealHands(){
/*
 *
 * DEALS HANDS BY FIRST ASSIGNING DECKARRAY CONCATENATION TO COUNT STRING
 *
 */
	
	int count = 1;
	int count2 = 1;

	for(int i = 0; i < rows; ++i){
		for(int j = 0; j < cols; ++j){

			if(count2 > 30){
				break;
			}

			if(count == 1){
				c1 += deckArray[i][j].face + deckArray[i][j].suit + " ";
				count++;
			} else if(count == 2){
				c2 += deckArray[i][j].face + deckArray[i][j].suit + " ";
				count++;
			} else if(count == 3){
				c3 += deckArray[i][j].face + deckArray[i][j].suit + " ";
				count++;
			} else if(count == 4){
				c4 += deckArray[i][j].face + deckArray[i][j].suit + " ";
				count++;
			} else if(count == 5){
				c5 += deckArray[i][j].face + deckArray[i][j].suit + " ";
				count++;
			} else if(count == 6){
				c6 += deckArray[i][j].face + deckArray[i][j].suit + " ";
				count = 1; 	
			} 
			count2++;
		}
	}

	// assigns values of strings to array of strings
	deltCards[0] = c1;
	deltCards[1] = c2;
	deltCards[2] = c3;
	deltCards[3] = c4;
	deltCards[4] = c5;
	deltCards[5] = c6;
}


void createDeck::remainingDeck(){
/*
 *
 * PRINTS OUT WHAT WAS NOT DEALT FROM DECK 
 *
 */

	// create string that will be set to the suit and face of each object in the array and then print it
	
	cout << "*** Here is what remains in the deck... " << endl;

	string card = "";
	int count = 0;
	for(int k = 0; k < rows; ++k){
		for(int m = 0; m < cols; ++m){
			if(count < 30){
				count += 1;
			}else{	
				card = deckArray[k][m].suit + deckArray[k][m].face;
				cout << card << "  ";
			} 
		}
	}
	cout << endl;

	// continues process by calling on rankHands method given the array of string hands deltCards
	rankHands(deltCards);
	
}


void createDeck::rankHands(string arr[]){
/*
 *
 * RANKS CARDS BY CALLING player.SETFINALSCORES AND SETTING RESULT ENTRY TO IT FOR PRINTING LATER
 *
 */

	list<string> demo;
	int otherCount = 0; // count any remaining like for a FH
	for(int i = 0; i < 6; ++i){
		player currentCard(arr[i], demo, 0);	
		currentCard.setFinalScores();
		result[i] = currentCard;
	}
	cout << endl;
}


void createDeck::swap(player& a, player& b){
/*
 *
 * METHOD TO BE CALLED ON FOR BASIC SWAPPING OF PLAYERS
 *
 */

	player tempPlayer = b;
	b = a;
	a = tempPlayer;

}

void createDeck::tieBreakers(){

	for(int i = 0; i < 6; i++){
		for(int j = i + 1; j < 6; j++){			

			if(result[i].order == result[j].order){


				///////////////// FLUSHES
				
				if(result[i].hand == "Straight Flush" ||
				   result[i].hand == "Flush"	      ||
				   result[i].hand == "Royal Straight Flush"){

					if(rankSuits(result[i].wordList.back().back()) < rankSuits(result[j].wordList.back().back())){
						swap(result[i], result[j]);

					}else if(rankSuits(result[i].wordList.back().back()) == rankSuits(result[j].wordList.back().back())){

						if(getHighCard(result[i]) < getHighCard(result[j])){
							swap(result[i], result[j]);
						}	

					}

				}

				///////////////// STRAIGHT
				
				else if(result[i].hand == "Straight"){

					if(getHighCard(result[i]) < getHighCard(result[j])){

						swap(result[i], result[j]);

					}
				}
				
				///////////////// TWO PAIRS
				
				else if(result[i].hand == "Two Pair"){

					// the suit of the kicker 
					// (the one not in the pairs)
					// determines the winner 
					// using the suit ranking



                                        char suitI = getHighCardNI2P(result[i]);
                                        char suitJ = getHighCardNI2P(result[j]);

                                        if(rankSuits(suitI) < rankSuits(suitJ)){

                                                swap(result[i], result[j]);

                                        }else if(rankSuits(suitI) == rankSuits(suitJ)){

						if(suitI < suitJ){
                                                        swap(result[i], result[j]);
                                                }

                                        }

				}	
			
				///////////////// PAIR
				
				else if(result[i].hand == "Pair"){

					// the suit of the card with the highest value 
					// that is NOT part of the pair will determine
					// the winner using the suit ranking

					char suitI = getHighCardNIP(result[i]);
					char suitJ = getHighCardNIP(result[j]);

					if(rankSuits(suitI) < rankSuits(suitJ)){
					
						swap(result[i], result[j]);

					}else if(rankSuits(suitI) == rankSuits(suitJ)){
						
						if(suitI < suitJ){
							swap(result[i], result[j]);
						}		
	
					}

				}
				
				///////////////// HIGH CARD
		
				else if(result[i].hand == "High Card"){

					if(rankSuits(getHighCard(result[i])) < rankSuits(getHighCard(result[j]))){

						swap(result[i], result[j]);

					}else if(rankSuits(getHighCard(result[i])) == rankSuits(getHighCard(result[j]))){

						if(getHighCard(result[i]) < getHighCard(result[j])){
						
							swap(result[i], result[j]);
						
						}

					}

				}

				//////////////// TOAK	

				else if(result[i].hand == "Three of a Kind"){

					int rankI = getTOAKRank(result[i]);
					int rankJ = getTOAKRank(result[j]);

					if(rankI < rankJ) {
                        			swap(result[i], result[j]);
                    			} else if(rankI == rankJ) {
                        			vector<int> kickersI = getKickers(result[i]);
                        			vector<int> kickersJ = getKickers(result[j]);
 
						sort(kickersI.rbegin(), kickersI.rend());
						sort(kickersJ.rbegin(), kickersJ.rend());

                        			for(int k = 0; k < kickersI.size(); k++) {
                            				if(kickersI[k] < kickersJ[k]) {
                                				swap(result[i], result[j]);
                                				break;
                            				} else if(kickersI[k] > kickersJ[k]) {
                                				break;
                            				}
                        			}
						
						if(kickersI == kickersJ){

							char suitI = getHighCardSuit(result[i]);
							char suitJ = getHighCardSuit(result[j]);

							if(rankSuits(suitI) < rankSuits(suitJ)){

								swap(result[i], result[j]);
							}
						}
		
                    			}
				}
	
				/////////////// FOAK

				else if(result[i].hand == "Four of a Kind"){

					int rankI = getFOAKRank(result[i]);
					int rankJ = getFOAKRank(result[j]);

					if(rankI < rankJ) {
                        			swap(result[i], result[j]);
                    			} else if(rankI == rankJ) {
                        			int kickerI = getKicker(result[i]);
                        			int kickerJ = getKicker(result[j]);
						if(kickerI < kickerJ){
							swap(result[i], result[j]);
                        			}
                    			}
	
				}
				
				else if(result[i].hand == "Full House"){

					int rankI = getTOAKRank(result[i]);
					int rankJ = getTOAKRank(result[j]);

					if(rankI < rankJ) {
                        			swap(result[i], result[j]);
                    			} else if(rankI == rankJ) {
                        			vector<int> kickersI = getKickers(result[i]);
                        			vector<int> kickersJ = getKickers(result[j]);
 
                        			for(int k = 0; k < kickersI.size(); k++) {
                            				if(kickersI[k] < kickersJ[k]) {
                                				swap(result[i], result[j]);
                                				break;
                            				} else if(kickersI[k] > kickersJ[k]) {
                                				break;
                            				}
                        			}
                    			}
 
				}
				
			}					

		}
	}

}

char createDeck::getHighCardSuit(const player& p){

	int highCard = -1;
	char highSuit = ' ';
	unordered_map<string, int> countMap;

	for(const auto& card : p.wordList){
        	string face = card.substr(0, card.length() - 1);
        	countMap[face]++;
	}

	for(const auto& card : p.wordList){
        	string face = card.substr(0, card.length() - 1);
		char suit = card.back();

		if(countMap[face] == 1){
			int faceValue = getFaceValue(face);
			if(faceValue > highCard){
				highCard = faceValue;
				highSuit = suit;
			}
		}
	}

	return highSuit;

}

vector<int> createDeck::getKickers(const player& p) {
    unordered_map<string, int> countMap;
    vector<int> kickers;

    // Count occurrences of each face value and find TOAK rank
    for (const auto& card : p.wordList) {
        string face = card.substr(0, card.length() - 1);
        countMap[face]++;
    }

    // Collect kickers
    for (const auto& card : p.wordList) {
        string face = card.substr(0, card.length() - 1);
	if(countMap[face] == 1){
		kickers.push_back(getFaceValue(face));
	}
    }

    return kickers;
}


char createDeck::getHighCardNI2P(const player& p){

    int highCard = -1;
    char highSuit = ' ';
    unordered_map<string, int> countMap;
    
    // Count occurrences of each face value
    for(const auto& card : p.wordList) {
        string face = card.substr(0, card.length() - 1);
        countMap[face]++;
    }
    
    // Find highest card not in a pair and its suit
    for(const auto& card : p.wordList) {
        string face = card.substr(0, card.length() - 1);
        char suit = card.back();
        if(countMap[face] == 2) {
            int faceValue = getFaceValue(face);
            if(faceValue > highCard) {
                highCard = faceValue;
                highSuit = suit;
            }
	}
    }
    return highSuit;
	
}

char createDeck::getHighCardNIP(const player& p){

    int highCard = -1;
    char highSuit = ' ';
    unordered_map<string, int> countMap;
    
    // Count occurrences of each face value
    for(const auto& card : p.wordList) {
        string face = card.substr(0, card.length() - 1);
        countMap[face]++;
    }
    
    // Find highest card not in a pair and its suit
    for(const auto& card : p.wordList) {
        string face = card.substr(0, card.length() - 1);
        char suit = card.back();
        if(countMap[face] == 1) {
            int faceValue = getFaceValue(face);
            if(faceValue > highCard) {
                highCard = faceValue;
                highSuit = suit;
            }
        }
    }
    
    return highSuit;


}

int createDeck::getHighCard(const player& p) {
/*
 *
 * RETURNS INT
 * 	-- creates unordered_map countMap
 * 	-- goes through player parameters wordList and gets face and adds it to countMap
 * 	-- gets highest card of a string
 *
 */

    	unordered_map<string, int> countMap;
    	for (const auto& card : p.wordList) {
        	string face = card.substr(0, card.length() - 1); // face without suit
        	countMap[face]++;
    	}

    	int highCard = -1;
    	for (const auto& card : p.wordList) {
        	string face = card.substr(0, card.length() - 1); // face without suit
        	if (countMap[face] == 1) {
            		int faceValue = getFaceValue(face);
            		if (faceValue > highCard) {
                		highCard = faceValue;
            		}
        	}
    	}
    	return highCard;
}

int createDeck::getTOAKRank(const player& p){
/*
 * RETURNS INT
 * 	-- finds the rank of a TOAK and returns it
 */
	unordered_map<string, int> countMap;
	for(const auto& card : p.wordList){
		// parse face
		string face = card.substr(0, card.length() - 1);
		countMap[face]++;	
	}

	for(const auto& pair : countMap){
		if(pair.second == 3){
			return getFaceValue(pair.first);
		}
	}


		
	return -1;

}

int createDeck::getFOAKRank(const player& p){
/*
 * RETURNS INT
 * 	-- finds the rank of a FOAK and returns it
 */

	unordered_map<string, int> countMap;

	for(const auto& card : p.wordList){
		// parse face
		string face = card.substr(0, card.length() - 1);
		countMap[face]++;
	}

	for(const auto& pair : countMap){
		if(pair.second == 4){
			// return rank of TOAK

			return getFaceValue(pair.first);
		}
	}
	
	return -1;
}

vector<int> createDeck::getTwoPairRanks(const player& p) {
/*
 *
 * RETURNS VECTOR
 * 	-- creates vector ranks and unordered_map countMap
 * 	-- add faces in player parameters wordlist to countMap
 * 	-- adds rank to ranks vector
 * 	-- returns TwoPair Ranks in a SORTED vector
 *
 */

    	vector<int> ranks;
    	unordered_map<string, int> countMap;

    	for (const auto& card : p.wordList) {
        	string face = card.substr(0, card.length() - 1); 
        	countMap[face]++;
    	}

    	for (const auto& pair : countMap) {
        	if (pair.second == 2) {
		cout << "TP: " << pair.first << endl;
            	ranks.push_back(stoi(pair.first)); 
        	}
    	}

	sort(ranks.rbegin(), ranks.rend()); 
	return ranks;
}

int createDeck::getKicker(const player& p) {
/*
 *
 * RETURNS INT
 * 	-- creates vector of ints called ranks
 * 	-- for parameter p's wordlist we check if count of iteration of wordlist == 1 and then returns the int value of the face
 * 	-- KICKER = card not in the pairs of a TWO PAIR HAND
 *
 */
/*    	vector<int> ranks = getTwoPairRanks(p);
    	for (const auto& card : p.wordList) {
        	string face = card.substr(0, card.length() - 1); // face without suit
        	if (count(p.wordList.begin(), p.wordList.end(), face) == 1) {
            		return stoi(face); // Return kicker value
        	}
    	}
    	return -1; // Error case
*/

    unordered_map<string, int> countMap;
    for(const auto& card : p.wordList){
        string face = card.substr(0, card.length() - 1);
        countMap[face]++;
    }
    for(const auto& pair : countMap){
        if(pair.second == 1){
            return getFaceValue(pair.first);
        }
    }
    return -1;	


}
void createDeck::sortOrder(){
/*
 *
 * CALLED BY printResult() FUNCTION
 * 	-- sorts array result before calling tiebreakers and then printing
 *
 */

	sort(result, result + 6, [](const player &a, const player &b){
		return a.order < b.order;
	});
}

void createDeck::printResult(){
/*
 *
 * PRINTS RESULTS
 * 	-- BEFORE printing though, sorts result array and calls tieBreakers function
 *
 */	
	sortOrder();
	tieBreakers();	

	cout << "--- WINNING HAND ORDER ---" << endl;
	for(const auto &player : result){
		for(const auto &word : player.wordList){
			cout << word << " ";
		}
		cout <<  " - " << player.hand << endl;
	}
	cout << endl;
}

void gameMode::callDeckClass(createDeck& b){
/*
 *
 * METHOD FOR rankHands TO BE CALLED BY GAMEMODE USING TESTARRAY
 *
 */
	b.rankHands(testArray);
}

