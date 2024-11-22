
////////////////// CARD CLASS

// Derive Debug for printing, Clone for copying, and PartialEq for comparison
#[derive(Debug, Clone, PartialEq)]
pub struct Card {
    // Represents the suit of the card (D, C, H, S)
    pub suit: char,
    // Represents the face value of the card (A, 2-10, J, Q, K)
    pub face: String,
}

impl Card {
    // Constructor to create a new Card instance
    pub fn new(suit: char, face: String) -> Self {
        Card { suit, face }
    }

    // Converts card to string representation (e.g., "AS" for Ace of Spades)
    pub fn to_string(&self) -> String {
        format!("{}{}", self.face, self.suit)
    }

    // Converts face value to numeric value for comparison
    // Ace = 14, King = 13, Queen = 12, Jack = 11, Others = their numeric value
    pub fn face_to_value(face: &str) -> u8 {
        match face {
            "A" => 14,
            "K" => 13,
            "Q" => 12,
            "J" => 11,
            _ => face.parse().unwrap_or(0),  // Convert numeric strings to u8, default to 0 if invalid
        }
    }

    // Assigns numeric ranks to suits for comparison (D=1, C=2, H=3, S=4)
    // Used for breaking ties when hands are otherwise equal
    pub fn rank_suits(suit: char) -> u8 {
        match suit {
            'D' => 1,  // Diamonds
            'C' => 2,  // Clubs
            'H' => 3,  // Hearts
            'S' => 4,  // Spades
            _ => 0,    // Invalid suit defaults to 0
        }
    }
}

