package main

import (

	"fmt"
	"os"
	"path/filepath"

)

func main() {

	if len(os.Args) == 1 {
		fmt.Println("*** POKER HAND ANALYZER ***\n")

		// create and shuffle new deck
		d := NewDeck(false)
		d.Shuffle()

		// display shuffled deck
		d.PrintDeck()

		// deal hands and show results
		d.DealHands()
		fmt.Println()
		d.PrintHands()
		fmt.Println()
		d.PrintRemainingCards()

		d.RankHands(d.dealtHands)
		d.PrintResults()

	} else if len(os.Args) != 2 {

		fmt.Fprintf(os.Stderr, "Usage: go run main.go <filename>\n")
		os.Exit(1)

	} else {

		fmt.Println("*** P O K E R   H A N D   A N A L Y Z E R ***\n")
		fmt.Println("*** USING TEST DECK ***\n")

		filename := os.Args[1]
		fmt.Printf("*** File: %s\n", filepath.Base(filename))

		// create game mode and read test deck
		mode := NewGameMode()
		mode.ReadFile(filename)

		// create test deck and process hands
		testDeck := NewDeck(true)
		testDeck.RetrieveDeck(mode)
		mode.CallDeckClass(testDeck)
		testDeck.PrintResults()

	}

}
