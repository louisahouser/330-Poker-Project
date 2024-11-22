module DeckOfCards

using Random

### helper functions --------------------------------------

function face_to_value(face::AbstractString)
    # Converts card face values to numerical values for comparison
	if face == "J"
	
		return 11

	elseif face == "Q"

		return 12

	elseif face == "K"

		return 13

	elseif face == "A"

		return 14

	else

		return parse(Int, face)

	end

end

function rank_suits(suit::Char)
    # Assigns numerical rankings to suits (Diamond=1, Club=2, Heart=3, Spade=4)
	if suit == 'D'

		return 1

	elseif suit == 'C'

		return 2

	elseif suit == 'H'

		return 3

	elseif suit == 'S'

		return 4

	else 

		return 0

	end

end

### GLOBAL VARS -------------------------------------------

mutable struct Globals
    # Struct to track different poker hand types
	RSF::Bool     # Royal Straight Flush
	SF::Bool      # Straight Flush
	FOAK::Bool    # Four of a Kind
	FH::Bool      # Full House
	FLUSH::Bool   # Flush
	STRAIGHT::Bool # Straight
	TOAK::Bool    # Three of a Kind
	TP::Bool      # Two Pair
	PAIR::Bool    # Single Pair
	HC::Bool      # High Card
end

# initialize struct from above
Globals() = Globals(false, false, false, false, false, false, false, false, false, false)

### GAMEMODE CLASS ----------------------------------------

mutable struct GameMode
    # Struct to manage game state and validation
	test::Bool                # Flag for test mode
	entries::Matrix{String}   # Storage for card entries
	test_array::Vector{String} # Array for test hands
	dup_array::Vector{String} # Tracks duplicate cards

end

# constructor
function GameMode(test::Bool=false)

	# 6 hands, 5 cards each
	entries = fill("", (6, 5))
	test_array = fill("", 6)
	dup_array = String[]
	GameMode(test, entries, test_array, dup_array)

end

# read file method
function read_file!(mode::GameMode, filename::String)
    # Reads and validates poker hands from input file
	try
		lines = readlines(filename)
		for (row_index, line) in enumerate(lines[1:min(6, length(lines))])

			tokens = split(rstrip(line), ',')

			for (col_index, token) in enumerate(tokens[1:min(5, length(tokens))])
				og_token = token
				parsed_token = strip(token)

				#check for dupes
				if parsed_token in mode.dup_array

					println("*** ERROR - DUPLICATE CARD FOUND IN DECK ***\n")
					println("*** DUPLICATE: $parsed_token ***\n")
					exit(1)

				end

				# check for upupercase suits
				if isempty(parsed_token) || !isuppercase(parsed_token[end])

					println("*** ERROR - SUITS MUST BE UPPERCASE ***\n")
					println("*** INVALID SUIT: $parsed_token ***\n")				
					exit(1)

				end

				push!(mode.dup_array, parsed_token)
				mode.entries[row_index, col_index] = parsed_token

				# cheeck for valid card length
				if length(og_token) == 2 || length(og_token) > 3

					println("*** ERROR - CARDS MUST BE 3 CHARACTERS LONG ***\n")
					println("*** INVALID CARD LENGTH: $og_token ***\n")
					exit(1)
	
				end

			end

		end


		# print hands read from file
		for i in 1:6

			for j in 1:5

				print(mode.entries[i, j])
				if j != 5

					print(",")
	
				end

			end
			println()

		end

		set_test_deck!(mode)

	catch e

		if isa(e, SystemError)

			error("ERROR! COULD NOT OPEN FILE: $filename")

		else

			rethrow(e)

		end

	end

end

# set up test deck
function set_test_deck!(mode::GameMode)

	# go through test deck and add it to the test_array
	for i in 1:6

		line = String[]
		for j in 1:5

			temp = replace(mode.entries[i, j], " " => "")
			mode.entries[i, j] = temp
			push!(line, temp)

		end
		mode.test_array[i] = join(line, " ")

	end

	# print 6 hands
	println("\n*** Here are the six hands... ")
	for hand in mode.test_array

		println(hand)

	end

end

### CARD CLASS --------------------------------------------------

struct Card
    # Basic card structure with suit and face value
	suit::Char
	face::String

end

# convert string 
Base.string(card::Card) = string(card.face, card.suit)
Base.show(io::IO, card::Card) = print(io, string(card))

### PLAYER CLASS -----------------------------------------------

mutable struct Player
    # Struct to track player's hand and statistics
	hand::String                   # Text description of hand type
	word_list::Vector{String}      # List of cards in hand
	order::Int                     # Ranking order of hand
	suit_count::Dict{Char, Int}    # Count of each suit in hand
	rank_count::Dict{Int, Int}     # Count of each rank in hand

end

# constructor
function Player(hand::String="", word_list::Vector{String}=String[], order::Int=0)
    # Creates new player instance and initializes hand if provided
	player = Player(hand, word_list, order, Dict{Char, Int}(), Dict{Int, Int}())
	if !isempty(hand)

		convert_hand!(player,hand)

	end
	return player

end

function convert_hand!(player::Player, cards::String)
    # Processes raw card strings into structured hand data
	#reset all globals to false
	global_Vars = Globals()
	
	card_array = split(cards)
	empty!(player.word_list)
	append!(player.word_list, card_array)
	
	empty!(player.suit_count)
	empty!(player.rank_count)

	for word in card_array

		word = String(word)

		# get face and suit separately
		face_string = word[1:end-1]
		suit_char = word[end]

		# update struct values for the hand
		player.suit_count[suit_char] = get(player.suit_count, suit_char, 0) + 1
		face_val = face_to_value(face_string)
		player.rank_count[face_val] = get(player.rank_count, face_val, 0) + 1
		
	end

	evaluate_hand!(player, global_Vars)

end

function evaluate_hand!(player::Player, globals::Globals)
    # Evaluates the type of poker hand and sets appropriate flags
	## RSF
	if is_flush(player) && is_straight(player) && is_royal(player)

		globals.RSF = true
	## SF
	elseif is_flush(player) && is_straight(player)

		globals.SF = true
	## FLUSH
	elseif is_flush(player)

		globals.FLUSH = true
	## STRAIGHT
	elseif is_straight(player)

		globals.STRAIGHT = true

	end

	find_pairs!(player, globals)
	set_final_scores!(player, globals)
end

### helper functions for identifying hands --------------------------------
function is_flush(player::Player)
    # Checks if all cards are of the same suit
	any(count == 5 for count in values(player.suit_count))

end

function is_straight(player::Player)
    # Verifies if cards form a sequential straight, handling ace-low straight case
	rankings = sort(collect(keys(player.rank_count)))

	# check for low ace straight
	if rankings == [2, 3, 4, 5, 14]
		return true
	end

	#check normal straight
	for i in 2:length(rankings)

		if rankings[i] != rankings[i-1] + 1

			return false

		end

	end

	return true

end

function is_royal(player::Player)
    # Checks if hand contains 10 through Ace of the same suit
	all(get(player.rank_count, val, 0) > 0 for val in [10, 11, 12, 13, 14])

end

function find_pairs!(player::Player, globals::Globals)
    # Identifies and flags all pair-based hands (pairs, three of a kind, four of a kind, full house)
	pair_count = 0

	for rank_count in values(player.rank_count)

		if rank_count == 4

			globals.FOAK = true		

		elseif rank_count == 3

			globals.TOAK = true

		elseif rank_count == 2

			pair_count += 1

		end	

	end

	if pair_count == 2

		globals.TP = true

	elseif pair_count == 1

		globals.PAIR = true

	end

	if globals.TOAK && globals.PAIR 

		globals.FH = true

	elseif !globals.PAIR && !globals.TOAK && !globals.FOAK

		globals.HC = true

	end

end

function set_final_scores!(player::Player, globals::Globals)
    # Assigns final hand type and ranking based on evaluated flags
	if globals.RSF 

		player.hand = "Royal Straight Flush"
		player.order = 1

	elseif globals.SF

		player.hand = "Straight Flush"
		player.order = 2

	elseif globals.FOAK

		player.hand = "Four of a Kind"
		player.order = 3

	elseif globals.FH

		player.hand = "Full House"
		player.order = 4

	elseif globals.FLUSH

		player.hand = "Flush"
		player.order = 5

	elseif globals.STRAIGHT

		player.hand = "Straight"
		player.order = 6

	elseif globals.TOAK

		player.hand = "Three of a Kind"
		player.order = 7

	elseif globals.TP

		player.hand = "Two Pair"
		player.order = 8

	elseif globals.PAIR

		player.hand = "Pair"
		player.order = 9

	else

		player.hand = "High Card"
		player.order = 10

	end

end

### DECK CLASSSSSS ----------------------------------------------------

mutable struct Deck
    # Main deck structure containing all game state
	rows::Int                      # Number of rows in deck matrix
	cols::Int                      # Number of columns in deck matrix
	deck_array::Matrix{Card}       # Matrix storing all cards
	dealt_cards::Vector{String}    # Currently dealt hands
	result::Vector{Player}         # Player results after hand evaluation
	suits::Vector{Char}           # Available card suits
	faces::Vector{String}         # Available card faces

end

# constructor
function CreateDeck(test::Bool=false)
    # Initializes a new deck, either for testing or standard play
	rows = 4
	cols = 13
	deck_array = Matrix{Card}(undef, rows, cols)
	dealt_cards = fill("", 6)
	result = Vector{Player}(undef, 6)
	suits = ['D', 'C', 'H', 'S']
	faces = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

	deck = Deck(rows, cols, deck_array, dealt_cards, result, suits, faces)

	if !test

		for i in 1:rows, j in 1:cols

			deck.deck_array[i,j] = Card(suits[i], faces[j])

		end

	end

	return deck

end

### HELPER FUNCTIONS FOR TIEBREAKERS -----------------------------------------

function get_kicker_suit(p::Player)::Char
    # Returns the suit of the kicker card in pairs-based hands
	count_map = Dict{String,Int}()
	for card in p.word_list

		face = card[1:end-1]

	end

	for card in p.word_list

		if count_map[card[1:end-1]] == 1

			return card[end]

		end

	end

	return ' '

end

function get_high_card_suit(p::Player)::Char
    # Determines the suit of the highest single card in the hand
	high_card = -1
	high_suit = ' '
	count_map = Dict{String,Int}()

	for card in p.word_list

		face = card[1:end-1]
		count_map[face] = get(count_map, face, 0) + 1

	end

	for card in p.word_list

		if count_map[card[1:end-1]] == 1

			face_val = face_to_value(card[1:end-1])
			if face_val > high_card

				high_card = face_val
				high_suit = card[end]

			end

		end

	end
	return high_suit

end 

function get_kickers(p::Player)::Vector{Int}
    # Returns array of kicker card values sorted by rank
	count_map = Dict{String,Int}()
	for card in p.word_list

		face = card[1:end-1]
		count_map[face] = get(count_map, face, 0) + 1

	end

	return [face_to_value(card[1:end-1]) for card in p.word_list if count_map[card[1:end-1]] == 1]
end

function get_high_card(p::Player)::Int
    # Returns the value of the highest single card in the hand
	count_map = Dict{String,Int}()
	for card in p.word_list

		face = card[1:end-1]
		count_map[face] = get(count_map, face, 0) + 1

	end

	max_val = -1
	for card in p.word_list

		if count_map[card[1:end-1]] == 1

			val = face_to_value(card[1:end-1])
			max_val = max(max_val, val)

		end

	end
	return max_val

end

function get_toak_rank(p::Player)::Int
    # Returns the rank of the three matching cards in a three-of-a-kind
	for (face, count) in p.rank_count

		if count == 3

			return face

		end

	end
	return -1

end

function get_foak_rank(p::Player)::Int
    # Returns the rank of the four matching cards in a four-of-a-kind
	for (face, count) in p.rank_count

		if count == 4

			return face

		end

	end
	return -1
end

function get_two_pair_ranks(p::Player)::Vector{Int}
    # Returns array of the two pair values in descending order
	pairs = Int[]
	for (face, count) in p.rank_count

		if count == 2

			push!(pairs, face)

		end

	end

	sort!(pairs, rev=true)
	return pairs

end

function get_kicker(p::Player)::Int
    # Returns the value of the single kicker card in a hand
	for (face, count) in p.rank_count

		if count == 1

			return face

		end

	end
	return -1
end

### TIEBREAKER! ----------------------------------------------------
function tie_breakers!(deck::Deck)
    # Resolves ties between hands of the same type using various criteria
	for i in 1:6

		for j in (i+1):6

			if deck.result[i].order == deck.result[j].order

				if deck.result[i].hand in ["Straight Flush", "Flush", "Royal Straight Flush"]
                    # For flush-based hands, compare high cards
					if get_high_card(deck.result[i]) < get_high_card(deck.result[j])

						deck.result[i], deck.result[j] = deck.result[j], deck.result[i]

					end

				elseif deck.result[i].hand == "Straight"
                    # For straights, compare highest card
					if get_high_card(deck.result[i]) < get_high_card(deck.result[j])

						deck.result[i], deck.result[j] = deck.result[j], deck.result[i]
					end	
				
				elseif deck.result[i].hand == "Two Pair"
                    # For two pair, compare high pairs then kicker
					ranks_i = get_two_pair_ranks(deck.result[i])
					ranks_j = get_two_pair_ranks(deck.result[j])

					if ranks_i < ranks_j
				
						deck.result[i], deck.result[j] = deck.result[j], deck.result[i]	

					elseif ranks_i == ranks_j
						
						suit_i = get_kicker_suit(deck.result[i])
						suit_j = get_kicker_suit(deck.result[j])
	
						if rank_suits(suit_i) < rank_suits(suit_j)

							deck.result[i], deck.result[j] = deck.result[j], deck.result[i]

						end

					end

				elseif deck.result[i].hand == "Pair"
                    # For pairs, compare pair value then kickers in order
					ranks_i = get_two_pair_ranks(deck.result[i])
					ranks_j = get_two_pair_ranks(deck.result[j])

					if ranks_i < ranks_j
				
						deck.result[i], deck.result[j] = deck.result[j], deck.result[i]	

					elseif ranks_i == ranks_j
						
						kickers_i = get_kickers(deck.result[i])
						kickers_j = get_kickers(deck.result[j])
						sort!(kickers_i, rev=true)
						sort!(kickers_j, rev=true)
	
						for (ki, kj) in zip(kickers_i, kickers_j)

							if ki < kj

								deck.result[i], deck.result[j] = deck.result[j], deck.result[i]
								break

							elseif ki > kj
							
								break
							end

						end

					end

				elseif deck.result[i].hand == "High Card"
                    # For high card hands, compare each card in descending order
					card_i = sort!([face_to_value(card[1:end-1]) for card in deck.result[i].word_list], rev=true)

					card_j = sort!([face_to_value(card[1:end-1]) for card in deck.result[j].word_list], rev=true)

					for (ci, cj) in zip(card_i, card_j)

						if ci < cj

							deck.result[i], deck.result[j] = deck.result[j], deck.result[i]
						
						elseif ci > cj

							break

						end

					end

				elseif deck.result[i].hand == "Three of a Kind"
                    # For three of a kind, compare triplet value then kicker
					rank_i = get_toak_rank(deck.result[i])
					rank_j = get_toak_rank(deck.result[j])

					if rank_i < rank_j

						deck.result[i], deck.result[j] = deck.result[j], deck.result[i]

					elseif rank_i == rank_j

						kickers_i = get_kickers(deck.result[i])
						kickers_j = get_kickers(deck.result[j])
						sort!(kickers_i, rev=true)
						sort!(kickers_j, rev=true)

						if kickers_i[1] < kickers_j[1]

								deck.result[i], deck.result[j] = deck.result[j], deck.result[i]

						end
					end
					
				elseif deck.result[i].hand == "Four of a Kind"
                    # For four of a kind, compare quad value then kicker
					rank_i = get_foak_rank(deck.result[i])
					rank_j = get_foak_rank(deck.result[j])

					if rank_i < rank_j

						deck.result[i], deck.result[j] = deck.result[j], deck.result[i]

					elseif rank_i == rank_j

						if get_kicker(deck.result[i]) < get_kicker(deck.result[j])

							deck.result[i], deck.result[j] = deck.result[j], deck.result[i]
							
						end

					end

				elseif deck.result[i].hand == "Full House"
                    # For full house, compare triplet then pair value
					rank_i = get_toak_rank(deck.result[i])
					rank_j = get_toak_rank(deck.result[i])

					if rank_i < rank_j

						deck.result[i], deck.result[j] = deck.result[j], deck.result[i]

					elseif rank_i == rank_j

						pair_i  = get_pair_rank(deck.result[i])
						pair_j = get_pair_rank(deck.result[j])

						if pair_i[1] < pair_j[1]

							deck.result[i], deck.result[j] = deck.result[j], deck.result[i]

						end
					end

				end			
	
			end

		end

	end

end

### helper func for gettting pair rank
function get_pair_rank(p::Player)::Int
    # Returns the value of a pair in the hand
	for (face, count) in p.rank_count

		if count == 3

			return face

		end

	end
	return -1
end

### other deck methods ------------------------------------------------------
function retrieve_deck!(deck::Deck, mode::GameMode)
    # Copies test hands from GameMode to Deck structure
	deck.dealt_cards = copy(mode.test_array)

end

function retrieve_card(deck::Deck)
    # Displays the current state of all cards in the deck
	println("*** Shuffled 52 card deck: ")
	for i in 1:deck.rows

		for j in 1:deck.cols

			card = deck.deck_array[i, j]
			print("$(card.face)$(card.suit) ")

		end
		println()

	end

end

function shuffle_deck!(deck::Deck)
    # Randomly shuffles all cards in the deck
	flat_deck = vec(deck.deck_array)
	shuffle!(flat_deck)
	deck.deck_array = reshape(flat_deck, deck.rows, deck.cols)

end

function deal_hands!(deck::Deck)
    # Deals 5 cards to each of 6 players from the deck
	hands = fill("", 6)
	count = 0

	for i in 1:deck.rows, j in 1:deck.cols

		if count < 30

			hand_index = (count % 6) + 1
			hands[hand_index] *= "$(deck.deck_array[i,j].face)$(deck.deck_array[i,j].suit) "
			count += 1

		end

	end

	deck.dealt_cards = hands

end

function print_hands(deck::Deck)
    # Displays all currently dealt hands
	println("*** Here are the six hands...")
	for hand in deck.dealt_cards

		println(hand)

	end

end

function remaining_deck(deck::Deck)
    # Shows cards still in deck after dealing and evaluates hands
	println("*** Here is what remains in the deck... ")
	count = 0

	for i in 1:deck.rows, j in 1:deck.cols

		if count < 30

			count += 1

		else	

			card = deck.deck_array[i,j]
			print("$(card.suit)$(card.face) ")

		end

	end
	println()
	rank_hands!(deck, deck.dealt_cards)

end

function rank_hands!(deck::Deck, arr::Vector{String})
    # Creates Player objects for each hand and evaluates them
	for i in 1:6

		player = Player(arr[i], String[], 0)
		deck.result[i] = player

	end

end

function sort_order!(deck::Deck)
    # Sorts hands by their poker rank
	sort!(deck.result, by = p -> p.order)

end

function print_result(deck::Deck)
    # Displays final hand rankings after sorting and breaking ties
	sort_order!(deck)
	tie_breakers!(deck)

	println("\n--- WINNING HAND ORDER ---")
	for player in deck.result

		println(join(player.word_list, " "), " - ", player.hand)

	end
	println()

end

export Globals, GameMode, Card, Player, CreateDeck, read_file!, set_test_deck!, print_result, rank_hands!, retrieve_deck!, retrieve_card, shuffle_deck!, deal_hands!, print_hands, remaining_deck

end 
