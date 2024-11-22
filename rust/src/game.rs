use std::fs::File;                    // For file operations
use std::io::{BufRead, BufReader};    // For reading file contents
use std::process;                     // For program termination
use crate::deck::Deck;                // Import Deck struct

// GameMode struct for handling test deck operations
#[derive(Debug)]
pub struct GameMode {
    pub entries: Vec<Vec<String>>,    // 2D vector to store cards from file (6 hands x 5 cards)
    pub test_array: Vec<String>,      // Array to store formatted hands
    pub dup_array: Vec<String>,       // Array to track duplicate cards
}

impl GameMode {
    // Constructor for GameMode
    pub fn new(_test: bool) -> Self {
        GameMode {
            entries: vec![vec![String::new(); 5]; 6],  // Initialize 6 hands of 5 cards each
            test_array: vec![String::new(); 6],        // Space for 6 formatted hands
            dup_array: Vec::new(),                     // Empty vector for duplicate tracking
        }
    }

    // Reads and validates cards from input file
    pub fn read_file(&mut self, filename: &str) {
        // Open file with error handling
        let file = match File::open(filename) {
            Ok(file) => file,
            Err(_) => {
                eprintln!("ERROR! COULD NOT OPEN FILE: {}", filename);
                process::exit(1);
            }
        };

        let reader = BufReader::new(file);

        // Read up to 6 lines (hands)
        for (row_index, line) in reader.lines().enumerate() {
            if row_index >= 6 {
                break;
            }

            if let Ok(line) = line {
                // Split line into cards
                let tokens: Vec<&str> = line.split(',').collect();
                
                // Process up to 5 cards per hand
                for (col_index, token) in tokens.iter().enumerate() {
                    if col_index >= 5 {
                        break;
                    }

                    let parsed_line = token.to_string();

                    // Check for duplicate cards
                    if self.dup_array.contains(&parsed_line) {
                        eprintln!("*** ERROR - DUPLICATE CARD FOUND IN DECK ***\n*** DUPLICATE: {} ***", parsed_line.trim());
                        process::exit(1);
                    }

                    // Validate suit is uppercase
                    if parsed_line.is_empty() || !parsed_line.chars().last().unwrap_or(' ').is_uppercase() {
                        eprintln!("*** ERROR - SUITS MUST BE UPPERCASE ***\n*** INVALID SUIT: {} ***", parsed_line.trim());
                        process::exit(1);
                    }

                    // Validate card format
                    let is_ten = parsed_line.starts_with("10");
                    // Non-10 cards must be 3 characters (space + face + suit)
                    if !is_ten && parsed_line.len() == 2 {
                        eprintln!("*** ERROR - CARDS MUST BE 3 CHARACTERS LONG ***\n*** INVALID CARD LENGTH: {} ***", parsed_line.trim());
                        process::exit(1);
                    }

                    // Store valid card
                    self.dup_array.push(parsed_line.clone());
                    self.entries[row_index][col_index] = parsed_line;
                }
            }
        }

        // Print all hands from file
        for i in 0..6 {
            for j in 0..5 {
                if j == 4 {
                    println!("{}", self.entries[i][j]);
                } else {
                    print!("{},", self.entries[i][j]);
                }
            }
        }

        self.set_test_deck();
    }

    // Formats hands for poker analysis
    pub fn set_test_deck(&mut self) {
        // Process each hand
        for i in 0..6 {
            // Remove spaces and join cards with spaces
            let line: Vec<String> = self.entries[i]
                .iter()
                .map(|s| s.replace(" ", ""))
                .collect();
            self.test_array[i] = line.join(" ");
        }

        // Print formatted hands
        println!("\n*** Here are the six hands... ");
        for hand in &self.test_array {
            println!("{}", hand);
        }
    }

    // Passes hands to Deck for ranking
    pub fn call_deck_class(&self, deck: &mut Deck) {
        deck.rank_hands(&self.test_array);
    }
}

