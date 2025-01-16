/**
 * The FiveCardStud class serves as the main entry point for the Poker Hand Analyzer program.
 * It handles both normal gameplay and test mode operations.
 */
public class FiveCardStud {
    /**
     * The main method that runs the Poker Hand Analyzer.
     * It handles two modes of operation:
     * 1. Normal mode: Shuffles a deck, deals hands, and analyzes them.
     * 2. Test mode: Reads hands from a file and analyzes them.
     * 
     * @param args Command line arguments. If provided, should be a single filename for test mode.
     */
    public static void main(String[] args) {
        if (args.length == 0) {
            // Normal mode operation
            System.out.println("*** POKER HAND ANALYZER ***\n");
            boolean test = false;

            // Create an ordered deck of cards
            CreateDeck deck = new CreateDeck(test);

            // Shuffle the deck
            deck.shuffleDeck();

            // Display the shuffled deck
            deck.retrieveCard();

            // Deal six hands from the top of the deck
            deck.dealHands();

            System.out.println();

            // Print the dealt hands
            deck.printHands();

            System.out.println();

            // Show the remaining cards in the deck
            deck.remainingDeck();

            // Analyze and print the results
            deck.printResult();
        } else if (args.length != 1) {
            // Incorrect usage of command line arguments
            System.err.println("Usage: java FiveCardStud <filename>");
        } else {
            // Test mode operation
            System.out.println(" *** P O K E R   H A N D  A N A L Y Z E R ***\n");
            System.out.println("*** USING TEST DECK ***\n");

            String filename = args[0];
            System.out.println("*** File: " + filename);

            GameMode mode = new GameMode();
            try {
                // Read test hands from the specified file
                mode.readFile(filename);
                
                // Create a test deck and retrieve hands from the GameMode
                CreateDeck testDeck = new CreateDeck();
                testDeck.retrieveDeck(mode);
                
                // Process the test deck
                mode.callDeckClass(testDeck);
                
                // Analyze and print the results
                testDeck.printResult();
            } catch (Exception e) {
                // Handle any errors that occur during file processing
                System.err.println("Error processing file: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
}
