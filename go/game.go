package main

import (

	"bufio"
	"fmt"
	"os"
	"strings"
	"unicode"

)

// gamemode handles test mode functionality
type GameMode struct {

	entries		[][]string	// 6 hands, 5 cards 
	testArray	[]string	// 6 hands as strings
	dupArray	map[string]bool

}

// new game mode
func NewGameMode() *GameMode {

	return &GameMode{

		entries:	make([][]string, 6),
		testArray:	make([]string, 6),
		dupArray:	make(map[string]bool),

	}

}

// read and validate test deck
func (g *GameMode) ReadFile(filename string) error {

	file, err := os.Open(filename)
	if err != nil {

		fmt.Fprintf(os.Stderr, "ERROR! COULD NOT OPEN FILE:  %s\n", filename)
		os.Exit(1)

	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	rowIndex := 0

	// print hands read
	for i := range g.entries {

		for j := range g.entries[i] {

			if j == 4 {

				fmt.Println(g.entries[i][j])

			}else {

				fmt.Print(g.entries[i][j], ",")

			}

		}

	}

	for scanner.Scan() && rowIndex < 6 {

		line := scanner.Text()
		cards := strings.Split(line, ",")

		if len(cards) != 5 {

			fmt.Fprintf(os.Stderr, "*** ERROR - EACH HAND MUST HAVE 5 CARDS ***\n")
			os.Exit(1)

		}

		g.entries[rowIndex] = make([]string, 5)

		for colIndex, card := range cards {

			card = strings.TrimRightFunc(card, unicode.IsSpace)

			// check for duplicates
			if g.dupArray[card] {

				fmt.Fprintf(os.Stderr, "*** ERROR - DUPLICATE CARD FOUND IN DECK ***\n*** DUPLICATE: %s ***\n", card)
				os.Exit(1)

			}

			// check for uppercase suits
			if len(card) == 0 || !isUpperSuit(card) {

				fmt.Fprintf(os.Stderr, "*** ERROR - SUITS MUST BE UPPERCASE ***\nINVALID SUIT: %s\n", card)
				os.Exit(1)

			}

			// check card length 
			if !isValidSpacing(card) {

				fmt.Fprintf(os.Stderr, "*** ERROR - CARDS MUST BE 3 CHARACTERS LONG ***\nINVALID CARD LENGTH: %s\n", card)
				os.Exit(1)

			}

			// validate the face value
			if !isValidFace(card[:len(card)-1]) {

				fmt.Fprintf(os.Stderr, "*** ERROR - INVALID CARD FACE VALUE ***\nINVALID CARD: %s\n", card)
				os.Exit(1)

			}

			// validate the suit
			if !isValidSuit(card[len(card)-1:]) {

				fmt.Fprintf(os.Stderr, "*** ERROR - INVALID CARD SUIT ***\nINVALID CARD: %s\n", card)
				os.Exit(1)

			}

			g.dupArray[card] = true
			g.entries[rowIndex][colIndex] = card

		}

		rowIndex++

	}

	if rowIndex < 6 {

		fmt.Fprintf(os.Stderr, "*** ERROR - FILE MUST CONTAIN 6 HANDS ***\n")
		os.Exit(1)

	}

	if err := scanner.Err(); err != nil {

		fmt.Fprintf(os.Stderr, "*** ERROR READING FILE: %v ***\n", err)
		os.Exit(1)

	}


	g.setTestDeck()
	return nil

}


//////////////// HELPER FUNCTIONS

// check if proper spacing
func isValidSpacing(card string) bool {

	// check for 10
	if strings.HasPrefix(card, "10") {
		return len(card) == 3
	}

	// all other cards
	if len(card) != 3 {
		return false
	}

	return card[0] == ' '

}

// check if suit is uppercase
func isUpperSuit(card string) bool {

	suit := card[len(card)-1:]
	return suit == strings.ToUpper(suit)

}

// check if suit is valid
func isValidFace(face string) bool {

	face = strings.TrimSpace(face)

	validFaces := map[string]bool{

		"A": true, "2": true, "3": true, "4": true, "5": true,
		"6": true, "7": true, "8": true, "9": true, "10": true,
		"J": true, "Q": true, "K": true,

	}

	return validFaces[face]
}

// check if valid suit
func isValidSuit(suit string) bool {

	validSuits := map[string]bool{

		"H": true,
		"D": true,
		"C": true,
		"S": true,

	}

	return validSuits[suit]
}

// prepare test deck
func (g *GameMode) setTestDeck() {

	for i := range g.entries {

		handCards := make([]string, 5)
		for j, card := range g.entries[i] {

			if strings.HasPrefix(card, "10") {
				handCards[j] = card
			} else {
				handCards[j] = card[1:]
			}

		}

		g.testArray[i] = strings.Join(handCards, " ")

	}

	fmt.Println("\n*** Here are the six hands... ")
	for _, hand := range g.testArray {

		fmt.Println(hand)

	}

}

// returns test array of hands
func (g *GameMode) GetTestArray() []string {

	return g.testArray

}

// process test deck
func (g *GameMode) CallDeckClass(d *Deck) {

	d.RankHands(g.testArray)

}


