import sys

from deckOfCards import Globals
from deckOfCards import GameMode
from deckOfCards import PlayerWrapper
from deckOfCards import CreateCard
from deckOfCards import Player
from deckOfCards import CreateDeck


class FiveCardStud:

    @staticmethod
    def main(args):
        if len(args) == 0:
            print("*** POKER HAND ANALYZER ***\n")

            # Set test flag to False for creating ordered deck
            test = False

            # Create an ordered deck of cards
            deck = CreateDeck(test)

            # Shuffle the deck
            deck.shuffle_deck()

            # Display shuffled deck
            deck.retrieve_card()

            # Deal the six hands from the top of the deck
            deck.deal_hands()

            print()

            # Print dealt hands
            deck.print_hands()

            print()

            # Show what remains in the deck
            deck.remaining_deck()

            # Print the final result after analyzing hands
            deck.print_result()

        elif len(args) != 1:
            # Handle invalid argument value
            print("Usage: python poker_hand_analyzer.py <filename>", file=sys.stderr)

        else:
            # Handle the case when a test deck is provided
            print(" *** P O K E R   H A N D  A N A L Y Z E R ***\n")
            print("*** USING TEST DECK ***\n")

            filename = args[0]
            print(f"*** File: {filename}")

            # Create an instance of gameMode to read from the file
            mode = GameMode()
            mode.read_file(filename)

            # Create a test deck and retrieve the deck from the mode
            test_deck = CreateDeck()
            test_deck.retrieve_deck(mode)

            # Call the deck class through the game mode
            mode.call_deck_class(test_deck)

            # Print the final results
            test_deck.print_result()

if __name__ == "__main__":
    FiveCardStud.main(sys.argv[1:])

