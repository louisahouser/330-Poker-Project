module FiveCardStud
    # Main module for running the Five Card Stud poker game

using ..DeckOfCards

function main(args::Vector{String}=ARGS)
    # Entry point for the poker game, handles both test and regular modes

   try
	if isempty(args)
        # Standard mode - creates and plays with a full deck
		println("*** POKER HAND ANALYZER ***\n")

		# set test flag to false
		test = false

		# create an ordered deck
		deck = CreateDeck(test)

		#shuffle
		shuffle_deck!(deck)

		#print deck
		retrieve_card(deck)

		# deal hands
		deal_hands!(deck)

		println()

		#print hands
		print_hands(deck)

		println()

		# show remaining deck
		remaining_deck(deck)

		#print final results
		print_result(deck)
	
	elseif length(args) != 1
        # Validates correct command line usage
		erro("Usage: julia FiveCardStud.jl <filename>")

	else
        # Test mode - reads hands from input file
		### TEST DECK ------------------------------------------
		println(" *** P O K E R   H A N D   A N A L Y Z E R ***\n")
		println("*** USING TEST DECK ***\n")

		filename = args[1]
		println("*** File: $filename\n")

		#create gamemode instance
		mode = GameMode()
		read_file!(mode, filename)

		# create test deck & retrieve
		test_deck = CreateDeck(true)
		retrieve_deck!(test_deck, mode)

		rank_hands!(test_deck, test_deck.dealt_cards)

		# print final result
		print_result(test_deck)

	end

    catch e
	println()
	println(e.msg)
	exit(1)
    end

end

if abspath(PROGRAM_FILE) == @__FILE__
    # Runs main function if script is executed directly
	main(ARGS)

end

end

