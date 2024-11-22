
use rand::seq::SliceRandom;  // For shuffling functionality
use rand::thread_rng;        // For random number generation
use crate::card::Card;       // Card struct import
use crate::player::Player;   // Player struct import
use crate::game::GameMode;   // GameMode struct import

// Represents a deck of 52 playing cards arranged in a 2D array (4x13)
pub struct Deck {
    deck_array: Vec<Vec<Card>>,   // 2D vector storing cards (4 suits x 13 faces)
    dealt_cards: Vec<String>,     // Stores the six hands that are dealt
    result: Vec<Player>,          // Stores player results for ranking
    rows: usize,                  // Number of rows (4 for suits)
    cols: usize,                  // Number of columns (13 for faces)
}

impl Deck {
    // Creates a new deck instance. If test=true, creates empty deck for testing
    pub fn new(test: bool) -> Self {
        let rows = 4;
        let cols = 13;
        let suits = vec!['D', 'C', 'H', 'S'];
        let faces = vec!["A", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];

        // Initialize empty deck array
        let mut deck_array = vec![vec![Card::new(' ', String::new()); cols]; rows];

        // If not in test mode, populate deck with cards
        if !test {
            for i in 0..rows {
                for j in 0..cols {
                    deck_array[i][j] = Card::new(
                        suits[i],
                        faces[j].to_string()
                    );
                }
            }
        }

        Deck {
            deck_array,
            dealt_cards: vec![String::new(); 6],  // Space for 6 hands
            result: Vec::new(),
            rows,
            cols,
        }
    }

    // Creates a new empty test deck
    pub fn new_test() -> Self {
        Self::new(true)
    }

    // Shuffles the deck using random number generation
    pub fn shuffle(&mut self) {
        let mut rng = thread_rng();
        // Convert 2D array to 1D for shuffling
        let mut flat_deck: Vec<Card> = self.deck_array
            .iter()
            .flat_map(|row| row.iter().cloned())
            .collect();

        flat_deck.shuffle(&mut rng);

        // Convert back to 2D array
        let mut loc = 0;
        for i in 0..self.rows {
            for j in 0..self.cols {
                self.deck_array[i][j] = flat_deck[loc].clone();
                loc += 1;
            }
        }
    }

    // Prints the entire shuffled deck
    pub fn print_shuffled(&self) {
        println!("*** Shuffled 52 card deck: ");
        for row in &self.deck_array {
            for card in row {
                print!("{} ", card.to_string());
            }
            println!();
        }
    }

    // Deals six hands of 5 cards each from the deck
    pub fn deal_hands(&mut self) {
        let mut hands = vec![String::new(); 6];
        let mut count = 0;

        'outer: for i in 0..self.rows {
            for j in 0..self.cols {
                if count < 30 {  // Deal 30 cards total (6 hands * 5 cards)
                    let hand_index = count % 6;
                    hands[hand_index].push_str(&self.deck_array[i][j].to_string());
                    hands[hand_index].push(' ');
                    count += 1;
                }else {
                    break 'outer;
                }
            }
        }

        self.dealt_cards = hands;
    }

    // Prints all six dealt hands
    pub fn print_hands(&self) {
        println!("*** Here are the six hands...");
        for hand in &self.dealt_cards {
            println!("{}", hand);
        }
    }

    // Prints the remaining cards in the deck after dealing
    pub fn print_remaining(&mut self) {
        println!("*** Here is what remains in the deck... ");
        let mut count = 0;

        for row in &self.deck_array {
            for card in row {
                if count >= 30 {  // Print only cards after the first 30 dealt
                    print!("{} ", card.to_string());
                }
                count += 1;
            }
        }

        println!();

        // Rank the hands after showing remaining cards
        let dealt_copy: Vec<String> = self.dealt_cards.iter().cloned().collect();
        self.rank_hands(&dealt_copy);
    }

    // Ranks all hands by poker hand value
    pub fn rank_hands(&mut self, hands: &[String]) {
        self.result.clear();
        for hand in hands {
            if !hand.is_empty() {
                let mut player = Player::new(hand.clone());
                player.set_final_scores();
                self.result.push(player);
            }
        }
    }

    // For test mode: retrieves test deck from GameMode
    pub fn retrieve_deck(&mut self, mode: &GameMode) {
        self.dealt_cards = mode.test_array.clone();
    }

    // Prints final results after ranking all hands
    pub fn print_results(&mut self) {
        self.sort_order();
        self.tie_breakers();
        println!();
        println!("--- WINNING HAND ORDER ---");
        for player in &self.result {
            println!("{} - {}", player.word_list.join(" "), player.hand);
        }
        println!();
    }

    // Sorts hands by their poker hand ranking
    fn sort_order(&mut self) {
        self.result.sort_by_key(|player| player.order);
    }

    // Applies tie-breaker rules based on hand type
    fn tie_breakers(&mut self) {
        for i in 0..self.result.len() {
            for j in (i + 1)..self.result.len() {
                if self.result[i].order == self.result[j].order {
                    match self.result[i].hand.as_str() {
                        "Straight Flush" | "Flush" | "Royal Straight Flush" => {
                            self.compare_high_cards(i, j);
                        } "Straight" => {
                            self.compare_high_cards(i, j);
                        } "Two Pair" => {
                            self.compare_two_pairs(i, j);
                        } "Pair" => {
                            self.compare_pairs(i, j);
                        } "High Card" => {
                            self.compare_high_cards_and_kicker(i, j);
                        } "Three of a Kind" => {
                            self.compare_three_of_kind(i, j);
                        } "Four of a Kind" => {
                            self.compare_four_of_kind(i, j);
                        } "Full House" => {
                            self.compare_full_house(i, j);
                        }
                        _ => {}
                    }
                }
            }
        }
    }

    //////////// Tie-breaker helper functions

    // Compares hands based on highest card value
    fn compare_high_cards(&mut self, i: usize, j: usize) {
        let high_i = self.result[i].get_high_card();
        let high_j = self.result[j].get_high_card();

        if high_i < high_j {
            self.result.swap(i, j);
        }
    }
    
    // Compares hands based on high card and kicker
    fn compare_high_cards_and_kicker(&mut self, i: usize, j: usize) {
        let high_i = self.result[i].get_high_card();
        let high_j = self.result[j].get_high_card();

        if high_i < high_j {
            self.result.swap(i, j);
        }else if high_i == high_j {
            let kicker_i = self.result[i].get_kicker();
            let kicker_j = self.result[j].get_kicker();
            if kicker_i < kicker_j {
                self.result.swap(i, j);
            }
        }
    }

    // Compares pairs based on suit ranking
    fn compare_pairs(&mut self, i: usize, j: usize) {
        let rank_i = Card::rank_suits(self.result[i].get_high_card_suit());
        let rank_j = Card::rank_suits(self.result[j].get_high_card_suit());
        let suit_i = self.result[i].get_high_card_suit();
        let suit_j = self.result[j].get_high_card_suit();

        if rank_i < rank_j {
            self.result.swap(i, j);
        } else if rank_i == rank_j && suit_i < suit_j {
            self.result.swap(i, j);
        }
    }

    // Compares two pair hands
    fn compare_two_pairs(&mut self, i: usize, j: usize) {
        let ranks_i = self.result[i].get_to_pair_ranks();
        let ranks_j = self.result[j].get_to_pair_ranks();
        
        if ranks_i < ranks_j {
            self.result.swap(i, j);
        } else if ranks_i == ranks_j {
            let suit_i = self.result[i].get_kicker_suit();
            let suit_j = self.result[j].get_kicker_suit();
            if Card::face_to_value(&suit_i.to_string()) < Card::face_to_value(&suit_j.to_string()) {
                self.result.swap(i, j);
            }
        }
    }

    // Compares three of a kind hands
    fn compare_three_of_kind(&mut self, i: usize, j: usize) {
        let rank_i = self.result[i].get_toak_rank();
        let rank_j = self.result[j].get_toak_rank();
        
        if rank_i < rank_j {
            self.result.swap(i, j);
        } else if rank_i == rank_j {
            let kicker_i = self.result[i].get_kicker();
            let kicker_j = self.result[j].get_kicker();
            if kicker_i < kicker_j {
                self.result.swap(i, j);
            }
        }
    }

    // Compares four of a kind hands
    fn compare_four_of_kind(&mut self, i: usize, j: usize) {
        let rank_i = self.result[i].get_foak_rank();
        let rank_j = self.result[j].get_foak_rank();
        
        if rank_i < rank_j {
            self.result.swap(i, j);
        } else if rank_i == rank_j {
            let kicker_i = self.result[i].get_kicker();
            let kicker_j = self.result[j].get_kicker();
            if kicker_i < kicker_j {
                self.result.swap(i, j);
            }
        }
    }

    // Compares full house hands based on three of a kind value
    fn compare_full_house(&mut self, i: usize, j: usize) {
        let rank_i = self.result[i].get_toak_rank();
        let rank_j = self.result[j].get_toak_rank();
        
        if rank_i < rank_j {
            self.result.swap(i, j);
        }
    }
}


