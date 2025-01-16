/**
 * The CreateCard class represents a single playing card in a deck.
 * It stores the suit and face value of the card.
 */
public class CreateCard {
    /** The suit of the card (e.g., "H" for Hearts, "S" for Spades) */
    public String suit;
    
    /** The face value of the card (e.g., "A" for Ace, "K" for King, "7" for Seven) */
    public String face;

    /**
     * Default constructor.
     * Creates an empty card with no suit or face value assigned.
     */
    public CreateCard() {
    }

    /**
     * Parameterized constructor.
     * Creates a card with the specified suit and face value.
     *
     * @param i The suit of the card
     * @param j The face value of the card
     */
    public CreateCard(String i, String j) {
        this.suit = i;
        this.face = j;
    }
}
