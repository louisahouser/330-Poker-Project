module PokerGame

include("DeckOfCards.jl")
include("FiveCardStud.jl")

export main

if abspath(PROGRAM_FILE) == @__FILE__

	FiveCardStud.main()

end

end
