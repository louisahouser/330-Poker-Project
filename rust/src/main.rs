use std::env;

// Module declarations for the poker analyzer components
mod card;    // Card representation and utilities
mod deck;    // Deck operations and hand management
mod game;    // Game modes and file handling
mod player;  // Player hand evaluation and ranking

fn main() {
    // Collect command line arguments into a vector
    let args: Vec<String> = env::args().collect();
    
    if args.len() == 1 {
        // Regular mode - no file input
        // Generates random hands from a shuffled deck
        println!("*** POKER HAND ANALYZER ***\n");
        
        // Create and initialize a new deck
        let mut deck = deck::Deck::new(false);
        
        // Perform deck operations:
        deck.shuffle();           // Randomize card order
        deck.print_shuffled();    // Display shuffled deck
        deck.deal_hands();        // Deal six 5-card hands
        println!();
        deck.print_hands();       // Show the dealt hands
        println!();
        deck.print_remaining();   // Show undealt cards
        deck.print_results();     // Display hand rankings
        
    } else if args.len() == 2 {
        // Test mode - reads hands from input file
        println!(" *** P O K E R   H A N D  A N A L Y Z E R ***\n");
        println!("*** USING TEST DECK ***\n");
        println!("*** File: {}", args[1]);
        
        // Create game instance for test mode
        let mut game = game::GameMode::new(true);
        
        // Read and validate hands from input file
        game.read_file(&args[1]);
        
        // Create empty test deck and populate with file hands
        let mut test_deck = deck::Deck::new_test();
        test_deck.retrieve_deck(&game);
        
        // Evaluate and rank the hands
        game.call_deck_class(&mut test_deck);
        test_deck.print_results();
        
    } else {
        // Invalid number of arguments
        eprintln!("Usage: cargo run [filename]");
    }
}


