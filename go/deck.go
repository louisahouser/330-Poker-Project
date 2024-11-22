package main

import (

	"fmt"
	"math/rand"
	"sort"
	"strings"
	"time"

)

////////////// CARD CLASS

// card represents a single card
type Card struct {
	Face string
	Suit string
}

// string returns the string rep of a card
func (c Card) String() string {
	return c.Face + c.Suit
}

// deck reps a deck of cards and game state
type Deck struct {

	cards		[][]Card
	dealtHands	[]string
	results		[]*Player
	isTest		bool

}

type HandType int

// global consts
const (

	HighCard HandType = iota + 1
	Pair
	TwoPair
	ThreeOfAKind
	Straight
	Flush
	FullHouse
	FourOfAKind
	StraightFlush
	RoyalStraightFlush

)

func (h HandType) String() string {

	switch h {

	case HighCard:
		return "High Card"
	case Pair:
		return "Pair"
	case TwoPair:
		return "Two Pair"
	case ThreeOfAKind:
		return "Three of a Kind"
	case Straight:
		return "Straight"
	case Flush:
		return "Flush"
	case FullHouse:
		return "Full House"
	case FourOfAKind:
		return "Four of a Kind"
	case StraightFlush:
		return "Straight Flush"
	case RoyalStraightFlush:
		return "Royal Straight Flush"
	default:
		return "Unknown"

	}

}

/////////////////// PLAYER CLASS

// player class that reps a player's hand and its eval
type Player struct {

	hand		string
	wordList	[]string
	order		int
	handType	HandType
	suitCount	map[string]int
	rankCount	map[int]int

}


// new player instance
func NewPlayer(hand string) *Player {

	p := &Player{

		hand:		hand,
		suitCount:	make(map[string]int),
		rankCount:	make(map[int]int),

	}
	p.convertHand()
	return p

}

// convert hand to card counts
func (p *Player) convertHand() {

	p.wordList = strings.Fields(p.hand)

	for _, word := range p.wordList {

		faceStr := word[:len(word)-1]
		suitChar := word[len(word)-1:]

		p.suitCount[suitChar]++
		faceVal := faceToValue(faceStr)
		p.rankCount[faceVal]++

	}

	p.evaluateHand()

}

// evaluate which hand
func (p *Player) evaluateHand() {

	if p.isFlush() && p.isStraight() && p.isRoyal() {

		p.handType = RoyalStraightFlush
		p.order = 1

	}else if p.isFlush() && p.isStraight() {

		p.handType = StraightFlush
		p.order = 2

	}else if p.isFourOfAKind(){

		p.handType = FourOfAKind
		p.order = 3

	}else if p.isFullHouse() {

		p.handType = FullHouse
		p.order = 4

	}else if p.isFlush() {

		p.handType = Flush
		p.order = 5

	}else if p.isStraight() {

		p.handType = Straight
		p.order = 6

	}else if p.isThreeOfAKind() {

		p.handType = ThreeOfAKind
		p.order = 7

	}else if p.isTwoPair() {

		p.handType = TwoPair
		p.order = 8

	}else if p.isPair() {

		p.handType = Pair
		p.order = 9

	}else {

		p.handType = HighCard
		p.order = 10

	}

}

/////////// HELPER FUNCS
func (p *Player) isFlush() bool {

	for _, count := range p.suitCount {

		if count == 5 {

			return true

		}

	}

	return false

}

func (p *Player) isStraight() bool {

	var ranks []int
	for rank := range p.rankCount {

		ranks = append(ranks, rank)

	}
	sort.Ints(ranks)

	//check for low ace straight
	if len(ranks) == 5 && ranks[4] == 14 && ranks[0] == 2 && ranks[1] == 3 && ranks[2] == 4 && ranks[3] == 5 {

		return true

	}

	// check for reg straight
	if len(ranks) != 5 {

		return false

	}
	for i := 1; i < len(ranks); i++ {

		if ranks[i] != ranks[i-1]+1 {

			return false

		}

	}

	return true

}

func (p *Player) isRoyal() bool {

	required := []int{10, 11, 12, 13, 14}
	for _, rank := range required {

		if p.rankCount[rank] == 0 {

			return false

		}

	}

	return true

}

func (p *Player) isFourOfAKind() bool {

	for _, count := range p.rankCount {

		if count == 4 {

			return true

		}

	}

	return false

}


func (p *Player) isFullHouse() bool {

	hasThree := false
	hasPair := false
	for _, count := range p.rankCount {

		if count == 3 {

			hasThree = true

		} else if count == 2 {

			hasPair = true

		}

	}

	return hasThree && hasPair

}

func (p *Player) isThreeOfAKind() bool {

	for _, count := range p.rankCount {

		if count == 3 {

			return true

		}

	}


	return false
}

func (p *Player) isTwoPair() bool {

	pairCount := 0
	for _, count := range p.rankCount {

		if count == 2 {

			pairCount++

		}

	}

	return pairCount == 2

}

func (p *Player) isPair() bool {

	for _, count := range p.rankCount {

		if count == 2 {

			return true

		}

	}

	return false

}


//////////////////// DECK CLASS

// returns highest value of card not in a pair
func (p *Player) GetHighCard() int {

	highCard := -1
	for rank, count := range p.rankCount {

		if count == 1 && rank > highCard {

			highCard = rank

		}

	}

	return highCard

}

// returns highest card value 
func (p *Player) GetKicker() int {

	kicker := -1
	for rank, count := range p.rankCount {

		if count == 1 && rank > kicker {

			kicker = rank

		}

	}

	return kicker

}

// returns ranks of the two pairs
func (p *Player) GetTwoPairRanks() []int {

	var pairs []int
	for rank, count := range p.rankCount {

		if count == 2 {

			pairs = append(pairs, rank)

		}

	}

	sort.Sort(sort.Reverse(sort.IntSlice(pairs)))
	return pairs

}

// returns rank of 3 or 4 of a kind
func (p *Player) GetSetRank() int {

	for rank, count := range p.rankCount {

		if count >= 3 {

			return rank

		}

	}

	return -1

}

// create new deck
func NewDeck(isTest bool) *Deck {

	d := &Deck{

		cards:		make([][]Card, 4),
		dealtHands:	make([]string, 6),
		results:	make([]*Player, 6),
		isTest:		isTest,

	}

	if !isTest {

		suits := []string{"D", "C", "H", "S"}
		faces := []string{"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}

		for i := range d.cards {

			d.cards[i] = make([]Card, 13)
			for j := range d.cards[i] {

				d.cards[i][j] = Card{Face: faces[j], Suit: suits[i]}

			}

		}

	}

	return d

}

// shuffle deck!
func (d *Deck) Shuffle() {

	rand.Seed(time.Now().UnixNano())

	// flatten the deck b4 shuffling
	flat := make([]Card, 52)
	idx := 0
	for i := range d.cards{

		for j := range d.cards[i] {

			flat[idx] = d.cards[i][j]
			idx++

		}

	}

	// rand
	for i := len(flat) - 1; i > 0; i-- {

		j := rand.Intn(i + 1)
		flat[i], flat[j] = flat[j], flat[i]

	}

	// restore
	idx = 0
	for i := range d.cards {

		for j := range d.cards[i] {

			d.cards[i][j] = flat[idx]
			idx++

		}

	}


}

// prints the shuffled deck
func (d *Deck) PrintDeck() {

	fmt.Println("*** Shuffled 52 card deck: ")
	for i := range d.cards {

		for j := range d.cards[i] {

			fmt.Printf("%s ", d.cards[i][j])

		}

		fmt.Println()

	}

}

// deal hands
func (d *Deck) DealHands() {

	hands := make([]string, 6)
	count := 0

	for i := range d.cards {

		for j := range d.cards[i] {

			if count < 30 {

				handIndex := count % 6
				hands[handIndex] += fmt.Sprintf("%s ", d.cards[i][j])
				count++

			}

		}

	}

	d.dealtHands = hands
}

// rank hands
func (d *Deck) RankHands(hands []string) {

	for i, hand := range hands {

		d.results[i] = NewPlayer(hand)

	}

	d.tieBreakers()

}

// bleh tiebreakers function
func (d *Deck) tieBreakers() {

	sort.Slice(d.results, func(i, j int) bool {

		if d.results[i].order != d.results[j].order {

			return d.results[i].order < d.results[j].order

		}

		// resoolve ties based on hand type
		switch d.results[i].handType {

		case RoyalStraightFlush:
			return false
		case StraightFlush, Straight, Flush:
			return d.results[i].GetHighCard() > d.results[j].GetHighCard()
		case FourOfAKind:
			if rankI, rankJ := d.results[i].GetSetRank(), d.results[j].GetSetRank(); rankI != rankJ {

				return rankI > rankJ

			}
			return d.results[i].GetKicker() > d.results[j].GetKicker()
		case FullHouse, ThreeOfAKind:
			return d.results[i].GetSetRank() > d.results[j].GetSetRank()
		case TwoPair:
			pairsI := d.results[i].GetTwoPairRanks()
			pairsJ := d.results[j].GetTwoPairRanks()
			if pairsI[0] != pairsJ[0] {

				return pairsI[0] > pairsJ[0]

			}
			if pairsI[1] != pairsJ[1] {

				return pairsI[1] > pairsJ[1]

			}
			return d.results[i].GetKicker() > d.results[j].GetKicker()
		case Pair:
			if rankI, rankJ := d.results[i].GetSetRank(), d.results[j].GetSetRank(); rankI != rankJ {

				return rankI > rankJ

			}
			return d.results[i].GetKicker() > d.results[j].GetKicker()
		case HighCard:
			return d.results[i].GetHighCard() > d.results[j].GetHighCard()
		}

		return false
	})

}

// prints 6 habds
func (d *Deck) PrintHands() {

	fmt.Println("*** Here are the six hands...")
	for _, hand := range d.dealtHands {

		fmt.Println(hand)

	}

}

// prints remaining cards
func (d *Deck) PrintRemainingCards() {

	fmt.Println("*** Here is what remains in the deck...")
	count := 0
	for i := range d.cards {

		for j := range d.cards[i] {

			if count >= 30 {

				fmt.Printf("%s ", d.cards[i][j])

			}
			count++

		}

	}

	fmt.Println()
}

// print final results
func (d *Deck) PrintResults() {

	fmt.Println("\n--- WINNING HAND ORDER ---")
	for _, player := range d.results {

		fmt.Printf("%s - %s\n", strings.Join(player.wordList, " "), player.handType)

	}

	fmt.Println()
}

// convert face to value
func faceToValue(face string) int {

	switch face {

	case "J":
		return 11
	case "Q":
		return 12
	case "K":
		return 13
	case "A":
		return 14
	default:
		val := 0
		fmt.Sscanf(face, "%d", &val)
		return val

	}

}

// retrieve deck from gamemode
func (d *Deck) RetrieveDeck(mode interface{ GetTestArray() []string })  {

	d.dealtHands = mode.GetTestArray()

}
