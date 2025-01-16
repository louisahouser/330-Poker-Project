import csv
import sys
import random
from collections import defaultdict
from typing import List
from collections import Counter

# Helper function to convert face cards to numerical values
def face_to_value(face):
    if face == "J":
        return 11
    elif face == "Q":
        return 12
    elif face == "K":
        return 13
    elif face == "A":
        return 14
    else:
        return int(face)

# Helper function to assign numerical ranks to suits
def rank_suits(suit):
    if suit == 'D':
        return 1
    elif suit == 'C':
        return 2
    elif suit == 'H':
        return 3
    elif suit == 'S':
        return 4
    else:
        return 0

# Global class to keep track of poker hand types
class Globals:
    RSF = False      # Royal Straight Flush
    SF = False       # Straight Flush
    FOAK = False     # Four of a Kind
    FH = False       # Full House
    FLUSH = False    # Flush
    STRAIGHT = False # Straight
    TOAK = False     # Three of a Kind
    TP = False       # Two Pair
    PAIR = False     # Pair
    HC = False       # High Card

# Class to manage game modes (test mode or regular mode)
class GameMode:
    def __init__(self, test=False):
        self.test = test
        self.entries = [["" for _ in range(5)] for _ in range(6)]  # 6 hands, 5 cards each
        self.test_array = [""] * 6
        self.dup_array = []

    # Read card data from a file for test mode
    def read_file(self, filename):
        entry_count = 0
        try:
            with open(filename, 'r') as input_file:
                reader = csv.reader(input_file)
                for row_index, row in enumerate(reader):
                    if row_index >= 6:
                        break
                    for col_index, token in enumerate(row):
                        parsed_line = token.strip()
                        # Check for duplicate cards
                        if parsed_line in self.dup_array:
                            print(f"*** ERROR - DUPLICATE CARD FOUND IN DECK ***\n*** DUPLICATE: {parsed_line} ***", file=sys.stderr)
                            sys.exit(1)
                        
                        # Check for uppercase suits
                        if len(parsed_line) == 0 or not parsed_line[-1].isupper():
                            print(f"*** ERROR - SUITS MUST BE UPPERCASE ***\nINVALID SUIT: {parsed_line}", file=sys.stderr)
                            sys.exit(1)

                        self.dup_array.append(parsed_line)
                        self.entries[row_index][col_index] = parsed_line

                        # Check for valid card length
                        if len(parsed_line) == 1 or len(parsed_line) > 3:
                            print(f"*** ERROR - CARDS MUST BE 3 CHARACTERS LONG ***\nINVALID CARD LENGTH: {parsed_line}", file=sys.stderr)
                            sys.exit(1)

                        if col_index >= 4:
                            break
        except IOError:
            print(f"ERROR! COULD NOT OPEN FILE: {filename}", file=sys.stderr)
            sys.exit(1)

        # Print the hands read from the file
        for i in range(6):
            for j in range(5):
                if j == 4:
                    print(self.entries[i][j])
                else:
                    print(self.entries[i][j], end=',')
            print()

        self.set_test_deck()

    # Set up the test deck from the file data
    def set_test_deck(self):
        for i in range(6):
            line = []
            for j in range(5):
                temp = self.entries[i][j].replace(" ", "")
                self.entries[i][j] = temp
                line.append(temp)
            self.test_array[i] = " ".join(line)

        print("\n*** Here are the six hands... ")
        for hand in self.test_array:
            print(hand)

    # Call the deck class to rank the hands
    def call_deck_class(self, deck):
        deck.rank_hands(self.test_array)

# Wrapper class for Player objects
class PlayerWrapper:
    def __init__(self, p):
        self.p = p

# Class to represent a single card
class CreateCard:
    def __init__(self, suit="", face=""):
        self.suit = suit
        self.face = face

    def __str__(self):
        return f"{self.face}{self.suit}"  # Returns face and suit together, like "AH" for Ace of Hearts

# Class to represent a player and their hand
class Player:
    def __init__(self, hand="", word_list=None, order=0):
        if word_list is None:
            word_list = []
        self.hand = hand
        self.word_list = word_list
        self.order = order
        self.suit_count = defaultdict(int)
        self.rank_count = defaultdict(int)
        self.convert_hand(hand)

    def get_order(self):
        return self.order

    def get_hand(self):
        return self.hand

    def get_word_list(self):
        return self.word_list

    # Convert a string representation of a hand into card objects
    def convert_hand(self, cards):
        globals().update({key: False for key in ['RSF', 'SF', 'FOAK', 'FH', 'FLUSH', 'STRAIGHT', 'TOAK', 'TP', 'PAIR', 'HC']})

        card_array = cards.split()
        for word in card_array:
            self.word_list.append(word)

            face_string = word[:-1]
            suit_char = word[-1]

            self.suit_count[suit_char] += 1
            face_val = face_to_value(face_string)

            self.rank_count[face_val] += 1

        self.evaluate_hand()

    # Evaluate the hand to determine its type
    def evaluate_hand(self):
        if self.is_flush() and self.is_straight() and self.is_royal():
            Globals.RSF = True
        elif self.is_flush() and self.is_straight():
            Globals.SF = True
        elif self.is_flush():
            Globals.FLUSH = True
        elif self.is_straight():
            Globals.STRAIGHT = True

        self.find_pairs()

    # Check if the hand is a flush
    def is_flush(self):
        return any(count == 5 for count in self.suit_count.values())

    # Check if the hand is a straight
    def is_straight(self):
        rankings = sorted(self.rank_count.keys())
        for i in range(1, len(rankings)):
            if rankings[i] != rankings[i - 1] + 1:
                if rankings == [2, 3, 4, 5, 14]:  # Special case for Ace-low straight
                    return True
                return False
        return True

    # Check if the hand is a royal flush
    def is_royal(self):
        return all(self.rank_count.get(val, 0) > 0 for val in [10, 11, 12, 13, 14])

    # Find pairs, three of a kind, and four of a kind in the hand
    def find_pairs(self):
        pair_count = 0
        toak_count = 0
        foak_count = 0

        for rank in self.rank_count.values():
            if rank == 4:
                Globals.FOAK = True
            elif rank == 3:
                Globals.TOAK = True
            elif rank == 2:
                pair_count += 1

        if pair_count == 2:
            Globals.TP = True
        elif pair_count == 1:
            Globals.PAIR = True

        if Globals.TOAK and Globals.PAIR:
            Globals.FH = True
        elif not Globals.PAIR and not Globals.TOAK and not Globals.FOAK:
            Globals.HC = True

    # Set the final hand type and order based on evaluation
    def set_final_scores(self):
        if Globals.RSF:
            self.hand = "Royal Straight Flush"
            self.order = 1
            Globals.RSF = False
        elif Globals.SF:
            self.hand = "Straight Flush"
            self.order = 2
            Globals.SF = False
        elif Globals.FOAK:
            self.hand = "Four of a Kind"
            self.order = 3
            Globals.FOAK = False
        elif Globals.FH:
            self.hand = "Full House"
            self.order = 4
            Globals.FH = False
        elif Globals.FLUSH:
            self.hand = "Flush"
            self.order = 5
            Globals.FLUSH = False
        elif Globals.STRAIGHT:
            self.hand = "Straight"
            self.order = 6
            Globals.STRAIGHT = False
        elif Globals.TOAK:
            self.hand = "Three of a Kind"
            self.order = 7
            Globals.TOAK = False
        elif Globals.TP:
            self.hand = "Two Pair"
            self.order = 8
            Globals.TP = False
        elif Globals.PAIR:
            self.hand = "Pair"
            self.order = 9
            Globals.PAIR = False
        else:
            self.hand = "High Card"
            self.order = 10

# Class to create and manage the deck of cards
class CreateDeck:
    def __init__(self, test=False):
        self.rows = 4
        self.cols = 13
        self.deck_array = [[None for _ in range(self.cols)] for _ in range(self.rows)]  # 4 suits, 13 cards each
        self.delt_cards = [""] * 6  # Holds hands dealt
        self.result = [None] * 6
        self.c1 = self.c2 = self.c3 = self.c4 = self.c5 = self.c6 = ""  # Hands

        self.suits = ["D", "C", "H", "S"]  # Diamonds, Clubs, Hearts, Spades
        self.faces = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

        if not test:
            for i in range(self.rows):
                for j in range(self.cols):
                    self.deck_array[i][j] = CreateCard(self.suits[i], self.faces[j])

    # Retrieve the deck from the game mode (for test mode)
    def retrieve_deck(self, mode):
        for i in range(6):
            self.delt_cards[i] = mode.test_array[i]

    # Print the shuffled deck
    def retrieve_card(self):
        print("*** Shuffled 52 card deck: ")
        for k in range(self.rows):
            for m in range(self.cols):
                card = f"{self.deck_array[k][m].face}{self.deck_array[k][m].suit}"
                print(card, end=" ")
            print()

    # Shuffle the deck
    def shuffle_deck(self):
        flat_deck = [self.deck_array[i][j] for i in range(self.rows) for j in range(self.cols)]
        random.shuffle(flat_deck)

        loc = 0
        for k in range(self.rows):
            for m in range(self.cols):
                self.deck_array[k][m] = flat_deck[loc]
                loc += 1

    # Deal hands from the deck
    def deal_hands(self):
        hands = [""] * 6  # Create a list for six hands
        count = 0

        # Loop through the deck to deal 6 cards for each of the 6 hands
        for i in range(self.rows):
            for j in range(self.cols):
                if count < 30:  # Deal exactly 30 cards (5 cards per hand)
                    hand_index = count % 6  # Determines which hand to add the card to
                    hands[hand_index] += f"{self.deck_array[i][j].face}{self.deck_array[i][j].suit} "
                    count += 1

        self.delt_cards = hands  # Assign the dealt hands to delt_cards

    # Print the dealt hands
    def print_hands(self):
        print("*** Here are the six hands...")
        for delt_card in self.delt_cards:
            print(delt_card)

    # Print the remaining cards in the deck
    def remaining_deck(self):
        print("*** Here is what remains in the deck... ")
        card = ""
        count = 0
        for k in range(self.rows):
            for m in range(self.cols):
                if count < 30:
                    count += 1
                else:
                    card = f"{self.deck_array[k][m].suit}{self.deck_array[k][m].face}"
                    print(card, end=" ")

        print()
        self.rank_hands(self.delt_cards)

    # Rank the hands
    def rank_hands(self, arr):
        for i in range(6):
            demo = []
            current_card = Player(arr[i], demo, 0)
            current_card.set_final_scores()
            self.result[i] = current_card

    # Swap two players (used in sorting)
    def swap(self, a, b):
        temp_player = b.p
        b.p = a.p
        a.p = temp_player

    # Resolve ties between hands of the same type
    def tie_breakers(self):
        for i in range(6):
            for j in range(i + 1, 6):
                if(self.result[i].get_order() == self.result[j].get_order()):
                    # STRAIGHT FLUSH, ROYAL STRAIGHT FLUSH, FLUSH
                    if self.result[i].hand in ["Straight Flush", "Flush", "Royal Straight Flush"]:
                        if self.get_high_card(self.result[i]) < self.get_high_card(self.result[j]):
                            self.result[i], self.result[j] = self.result[j], self.result[i]

                    # STRAIGHT
                    elif self.result[i].hand == "Straight":
                        if self.get_high_card(self.result[i]) < self.get_high_card(self.result[j]):
                            self.result[i], self.result[j] = self.result[j], self.result[i]

                    # TWO PAIR
                    elif self.result[i].hand == "Two Pair":
                        ranks_i = self.get_two_pair_ranks(self.result[i])
                        ranks_j = self.get_two_pair_ranks(self.result[j])
                        
                        if ranks_i < ranks_j:  # Compare the two pair ranks
                            self.result[i], self.result[j] = self.result[j], self.result[i]
                        elif ranks_i == ranks_j:  # If pairs are equal, compare kicker
                            suit_i = self.get_kicker_suit(self.result[i])
                            suit_j = self.get_kicker_suit(self.result[j])
                            if face_to_value(suit_i) < face_to_value(suit_j):
                                self.result[i], self.result[j] = self.result[j], self.result[i] 

                    # PAIR
                    elif self.result[i].hand == "Pair":
                        rank_i = self.get_toak_rank(self.result[i])
                        rank_j = self.get_toak_rank(self.result[j])
                        suit_i = self.get_high_card_nip(self.result[i])
                        suit_j = self.get_high_card_nip(self.result[j])

                        if rank_suits(suit_i) < rank_suits(suit_j):  # Compare the rank of the pair
                            self.result[i], self.result[j] = self.result[j], self.result[i]
                        elif rank_suits(suit_i) == rank_suits(suit_j):  # If the pair rank is the same, compare kickers
                            if suit_i < suit_j:
                                self.result[i], self.result[j] = self.result[j], self.result[i]

                    # HIGH CARD
                    elif self.result[i].hand == "High Card":
                        if self.get_high_card(self.result[i]) < self.get_high_card(self.result[j]):
                            self.result[i], self.result[j] = self.result[j], self.result[i]
                        elif self.get_high_card(self.result[i]) == self.get_high_card(self.result[j]):
                            # Compare kicker cards
                            if self.get_kicker(self.result[i]) < self.get_kicker(self.result[j]):
                                self.result[i], self.result[j] = self.result[j], self.result[i]

                    # THREE OF A KIND
                    elif self.result[i].hand == "Three of a Kind":
                        rank_i = self.get_toak_rank(self.result[i])
                        rank_j = self.get_toak_rank(self.result[j])
                        
                        if rank_i < rank_j:  # Compare the three of a kind rank
                            self.result[i], self.result[j] = self.result[j], self.result[i]
                        elif rank_i == rank_j:  # If rank is the same, compare kickers
                            kicker_i = self.get_kicker(self.result[i])
                            kicker_j = self.get_kicker(self.result[j])
                            if kicker_i < kicker_j:
                                self.result[i], self.result[j] = self.result[j], self.result[i]

                    # FOUR OF A KIND
                    elif self.result[i].hand == "Four of a Kind":
                        rank_i = self.get_foak_rank(self.result[i])
                        rank_j = self.get_foak_rank(self.result[j])
                        
                        if rank_i < rank_j:
                            self.result[i], self.result[j] = self.result[j], self.result[i]
                        elif rank_i == rank_j:
                            kicker_i = self.get_kicker(self.result[i])
                            kicker_j = self.get_kicker(self.result[j])
                            if kicker_i < kicker_j:
                                self.result[i], self.result[j] = self.result[j], self.result[i]

                    # FULL HOUSE
                    elif self.result[i].hand == "Full House":
                        rank_i = self.get_toak_rank(self.result[i])
                        rank_j = self.get_toak_rank(self.result[j])
                        
                        if rank_i < rank_j:
                            self.result[i], self.result[j] = self.result[j], self.result[i]

    # Get the suit of the kicker card in a two pair hand
    def get_kicker_suit(self, p):
        count_map = Counter(card[:-1] for card in p.word_list)
        for card in p.word_list:
            if count_map[card[:-1]] == 1:
                return card[-1]
        return ' '  # This should never happen in a valid two pair hand

    # Get the suit of the highest card that's not part of a pair or set
    def get_high_card_suit(self, p):
        high_card = -1
        high_suit = ' '
        count_map = Counter(card[:-1] for card in p.word_list)
        for card in p.word_list:
            face = card[:-1]
            suit = card[-1]
            if count_map[face] == 1:
                face_value = face_to_value(face)
                if face_value > high_card:
                    high_card = face_value
                    high_suit = suit
        return high_suit

    # Get a list of kicker card values
    def get_kickers(self, p) -> List[int]:
        count_map = Counter(card[:-1] for card in p.word_list)
        return [face_to_value(card[:-1]) for card in p.word_list if count_map[card[:-1]] == 1]

    # Get the suit of the highest card not in a pair (NIP = Not In Pair)
    def get_high_card_nip(self, p):
        high_card = -1
        high_suit = ' '
        count_map = Counter(card[:-1] for card in p.word_list)
        for card in p.word_list:
            face = card[:-1]
            suit = card[-1]
            if count_map[face] == 1:
                face_value = face_to_value(face)
                if face_value > high_card:
                    high_card = face_value
                    high_suit = suit
        return high_suit

    # Get the value of the highest card in the hand
    def get_high_card(self, p) -> int:
        count_map = Counter(card[:-1] for card in p.word_list)
        return max((face_to_value(card[:-1]) for card in p.word_list if count_map[card[:-1]] == 1), default=-1)

    # Get the rank of the three of a kind
    def get_toak_rank(self, p) -> int:
        count_map = Counter(card[:-1] for card in p.word_list)
        for face, count in count_map.items():
            if count == 3:
                return face_to_value(face)
        return -1

    # Get the rank of the four of a kind
    def get_foak_rank(self, p) -> int:
        count_map = Counter(card[:-1] for card in p.word_list)
        for face, count in count_map.items():
            if count == 4:
                return face_to_value(face)
        return -1

    # Get the ranks of the two pairs in descending order
    def get_two_pair_ranks(self, p):
        count_map = Counter(card[:-1] for card in p.word_list)
        return sorted([face_to_value(face) for face, count in count_map.items() if count == 2], reverse=True)

    # Get the value of the kicker card (highest card not in a pair or set)
    def get_kicker(self, p) -> int:
        count_map = Counter(card[:-1] for card in p.word_list)
        for pair in count_map.items():
            if pair[1] == 1:
                return face_to_value(pair[0])
        return -1

    # Sort the hands based on their ranking order
    def sort_order(self):
        self.result.sort(key=lambda player: player.get_order())

    # Print the final result of hand rankings
    def print_result(self):
        self.sort_order()
        self.tie_breakers()
        print()
        print("--- WINNING HAND ORDER ---")
        for player in self.result:
            print(" ".join(player.word_list), "-", player.hand)
        print()
