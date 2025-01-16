using System;

// The FiveCardStud class serves as the main entry point for the poker hand analyzer program
class FiveCardStud
{
    // The Main method is the entry point of the program
    static void Main(string[] args)
    {
        // If no command-line arguments are provided, run the program in interactive mode
        if (args.Length == 0)
        {
            Console.WriteLine("*** POKER HAND ANALYZER ***\n");
            bool test = false;

            // Create an ordered deck of cards
            CreateDeck deck = new CreateDeck(test);

            // Shuffle the deck
            deck.ShuffleDeck();

            // Display the shuffled deck
            deck.RetrieveCard();

            // Deal six hands from the top of the deck
            deck.DealHands();

            Console.WriteLine();

            // Display the dealt hands
            deck.PrintHands();

            Console.WriteLine();

            // Show the remaining cards in the deck
            deck.RemainingDeck();

            // Print the final results (hand rankings)
            deck.PrintResult();
        }
        // If the number of command-line arguments is not 1, display usage information
        else if (args.Length != 1)
        {
            Console.Error.WriteLine("Usage: mono Program.exe <filename>");
        }
        // If exactly one command-line argument is provided, run the program in test mode
        else
        {
            Console.WriteLine(" *** P O K E R   H A N D  A N A L Y Z E R ***\n");
            Console.WriteLine("*** USING TEST DECK ***\n");

            // Get the filename from the command-line argument
            string filename = args[0];
            Console.WriteLine($"*** File: {filename}");

            // Create a new GameMode object to handle the test scenario
            GameMode mode = new GameMode();
            try
            {
                // Read the test data from the specified file
                mode.ReadFile(filename);
                // Create a new deck for the test scenario
                CreateDeck testDeck = new CreateDeck();
                // Retrieve the test deck data
                testDeck.RetrieveDeck(mode);
                // Process the test deck
                mode.CallDeckClass(testDeck);
                // Print the final results (hand rankings) for the test scenario
                testDeck.PrintResult();
            }
            catch (Exception e)
            {
                // If an error occurs during file processing, display error information
                Console.Error.WriteLine($"Error processing file: {e.Message}");
                Console.Error.WriteLine(e.StackTrace);
            }
        }
    }
}
