using System;
using System.Collections.Generic;
using System.Linq;

// The CreateDeck class manages the creation, shuffling, and dealing of a deck of cards,
// as well as evaluating and ranking poker hands
public class CreateDeck
{
    // Array to store the evaluated and ranked hands
    public Player[] Result { get; private set; }
    // Strings to potentially store individual cards (usage not clear in this snippet)
    public string C1, C2, C3, C4, C5, C6;
    // 2D array to represent the deck of cards
    public CreateCard[,] DeckArray { get; private set; }
    // Array to store the dealt hands as strings
    public string[] DeltCards { get; private set; }
    // Number of rows and columns in the DeckArray
    public int Rows { get; private set; }
    public int Cols { get; private set; }

    // Default constructor initializing the deck and related data structures
    public CreateDeck()
    {
        Result = new Player[6];
        DeckArray = new CreateCard[4, 13];
        DeltCards = new string[6];
        Rows = DeckArray.GetLength(0);
        Cols = DeckArray.GetLength(1);
    }

    // Constructor for test scenarios, initializing a full deck
    public CreateDeck(bool test) : this()
    {
        string[] suits = { "D", "C", "H", "S" };
        string[] faces = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" };

        for (int i = 0; i < 4; i++)
        {
            for (int j = 0; j < 13; j++)
            {
                DeckArray[i, j] = new CreateCard(suits[i], faces[j]);
            }
        }
    }

    // Retrieves a predefined set of cards from a game mode
    public void RetrieveDeck(GameMode mode)
    {
        Array.Copy(mode.TestArray, DeltCards, 6);
    }

    // Displays the current state of the deck
    public void RetrieveCard()
    {
        Console.WriteLine("*** Shuffled 52 card deck: ");
        for (int k = 0; k < Rows; k++)
        {
            for (int m = 0; m < Cols; m++)
            {
                Console.Write($"{DeckArray[k, m].Face}{DeckArray[k, m].Suit}  ");
            }
            Console.WriteLine();
        }
    }

    // Shuffles the deck using the Fisher-Yates algorithm
    public void ShuffleDeck()
    {
        List<CreateCard> flatDeck = new List<CreateCard>();
        for (int i = 0; i < Rows; i++)
        {
            for (int j = 0; j < Cols; j++)
            {
                flatDeck.Add(DeckArray[i, j]);
            }
        }
        Random rng = new Random();
        int n = flatDeck.Count;
        while (n > 1)
        {
            n--;
            int k = rng.Next(n + 1);
            CreateCard value = flatDeck[k];
            flatDeck[k] = flatDeck[n];
            flatDeck[n] = value;
        }
        int index = 0;
        for (int i = 0; i < Rows; i++)
        {
            for (int j = 0; j < Cols; j++)
            {
                DeckArray[i, j] = flatDeck[index++];
            }
        }
    }

    // Displays the dealt hands
    public void PrintHands()
    {
        Console.WriteLine("*** Here are the six hands...");
        foreach (string hand in DeltCards)
        {
            Console.WriteLine(hand);
        }
    }

    // Deals six hands of five cards each
    public void DealHands()
    {
        string[] hands = new string[6];
        int handIndex = 0;
        string currentHand = "";
        int cardCount = 0;

        for (int i = 0; i < Rows; i++)
        {
            for (int j = 0; j < Cols; j++)
            {
                if (cardCount >= 30) break;
                currentHand += $"{DeckArray[i, j].Face}{DeckArray[i, j].Suit} ";
                cardCount++;
                if (cardCount % 5 == 0)
                {
                    hands[handIndex] = currentHand.Trim();
                    handIndex++;
                    currentHand = "";
                }
            }
            if (cardCount >= 30) break;
        }

        Array.Copy(hands, DeltCards, 6);
    }

    // Displays the remaining cards in the deck after dealing
    public void RemainingDeck()
    {
        Console.WriteLine("*** Here is what remains in the deck... ");
        int count = 0;
        for (int k = 0; k < Rows; k++)
        {
            for (int m = 0; m < Cols; m++)
            {
                if (count >= 30)
                {
                    Console.Write($"{DeckArray[k, m].Suit}{DeckArray[k, m].Face}  ");
                }
                else
                {
                    count++;
                }
            }
        }
        Console.WriteLine();

        RankHands(DeltCards);
    }

    // Evaluates and ranks the dealt hands
    public void RankHands(string[] arr)
    {
        for (int i = 0; i < 6; i++)
        {
            Player currentCard = new Player();
            currentCard.ConvertHand(arr[i]);
            currentCard.SetFinalScores();
            Result[i] = currentCard;
        }
        Console.WriteLine();
    }

    // Swaps two Player objects
    public void Swap(Player a, Player b)
    {
        Player temp = new Player(a.Hand, new List<string>(a.WordList), a.Order);
        a.Hand = b.Hand;
        a.WordList = new List<string>(b.WordList);
        a.Order = b.Order;
        b.Hand = temp.Hand;
        b.WordList = new List<string>(temp.WordList);
        b.Order = temp.Order;
    }

    // Resolves ties between hands of the same rank
    public void TieBreakers()
    {
        for (int i = 0; i < 6; i++)
        {
            for (int j = i + 1; j < 6; j++)
            {
                if (Result[i].Order == Result[j].Order)
                {
                    if (Result[i].Hand == "Straight Flush" || 
                        Result[i].Hand == "Flush" || 
                        Result[i].Hand == "Royal Straight Flush")
                    {
                        char suitI = Result[i].WordList.Last().Last();
                        char suitJ = Result[j].WordList.Last().Last();
                        
                        if (RankSuits(suitI) < RankSuits(suitJ))
                        {
                            Swap(Result[i], Result[j]);
                        }
                        else if (RankSuits(suitI) == RankSuits(suitJ))
                        {
                            if (GetHighCard(Result[i]) < GetHighCard(Result[j]))
                            {
                                Swap(Result[i], Result[j]);
                            }
                        }
                    }
                    else if (Result[i].Hand == "Straight")
                    {
                        if (GetHighCard(Result[i]) < GetHighCard(Result[j]))
                        {
                            Swap(Result[i], Result[j]);
                        }
                    }
                    else if (Result[i].Hand == "Two Pair")
                    {
                        char suitI = GetHighCardNI2P(Result[i]);
                        char suitJ = GetHighCardNI2P(Result[j]);

                        if (RankSuits(suitI) < RankSuits(suitJ))
                        {
                            Swap(Result[i], Result[j]);
                        }
                        else if (RankSuits(suitI) == RankSuits(suitJ))
                        {
                            if (suitI < suitJ)
                            {
                                Swap(Result[i], Result[j]);
                            }
                        }
                    }
                    else if (Result[i].Hand == "Pair")
                    {
                        char suitI = GetHighCardNIP(Result[i]);
                        char suitJ = GetHighCardNIP(Result[j]);

                        if (RankSuits(suitI) < RankSuits(suitJ))
                        {
                            Swap(Result[i], Result[j]);
                        }
                        else if (RankSuits(suitI) == RankSuits(suitJ))
                        {
                            if (suitI < suitJ)
                            {
                                Swap(Result[i], Result[j]);
                            }
                        }
                    }
                    else if (Result[i].Hand == "High Card")
                    {
                        char highCardI = GetHighCard(Result[i]);
                        char highCardJ = GetHighCard(Result[j]);

                        if (RankSuits(highCardI) < RankSuits(highCardJ))
                        {
                            Swap(Result[i], Result[j]);
                        }
                        else if (RankSuits(highCardI) == RankSuits(highCardJ))
                        {
                            if (highCardI < highCardJ)
                            {
                                Swap(Result[i], Result[j]);
                            }
                        }
                    }
                    else if (Result[i].Hand == "Three of a Kind")
                    {
                        int rankI = GetTOAKRank(Result[i]);
                        int rankJ = GetTOAKRank(Result[j]);

                        if (rankI < rankJ)
                        {
                            Swap(Result[i], Result[j]);
                        }
                        else if (rankI == rankJ)
                        {
                            List<int> kickersI = GetKickers(Result[i]);
                            List<int> kickersJ = GetKickers(Result[j]);

                            kickersI.Sort((a, b) => b.CompareTo(a));
                            kickersJ.Sort((a, b) => b.CompareTo(a));

                            for (int k = 0; k < kickersI.Count; k++)
                            {
                                if (kickersI[k] < kickersJ[k])
                                {
                                    Swap(Result[i], Result[j]);
                                    break;
                                }
                                else if (kickersI[k] > kickersJ[k])
                                {
                                    break;
                                }
                            }

                            if (kickersI.SequenceEqual(kickersJ))
                            {
                                char suitI = GetHighCardSuit(Result[i]);
                                char suitJ = GetHighCardSuit(Result[j]);

                                if (RankSuits(suitI) < RankSuits(suitJ))
                                {
                                    Swap(Result[i], Result[j]);
                                }
                            }
                        }
                    }
                    else if (Result[i].Hand == "Four of a Kind")
                    {
                        int rankI = GetFOAKRank(Result[i]);
                        int rankJ = GetFOAKRank(Result[j]);

                        if (rankI < rankJ)
                        {
                            Swap(Result[i], Result[j]);
                        }
                        else if (rankI == rankJ)
                        {
                            int kickerI = GetKicker(Result[i]);
                            int kickerJ = GetKicker(Result[j]);
                            if (kickerI < kickerJ)
                            {
                                Swap(Result[i], Result[j]);
                            }
                        }
                    }
                    else if (Result[i].Hand == "Full House")
                    {
                        int rankI = GetTOAKRank(Result[i]);
                        int rankJ = GetTOAKRank(Result[j]);

                        if (rankI < rankJ)
                        {
                            Swap(Result[i], Result[j]);
                        }
                        else if (rankI == rankJ)
                        {
                            List<int> kickersI = GetKickers(Result[i]);
                            List<int> kickersJ = GetKickers(Result[j]);

                            for (int k = 0; k < kickersI.Count; k++)
                            {
                                if (kickersI[k] < kickersJ[k])
                                {
                                    Swap(Result[i], Result[j]);
                                    break;
                                }
                                else if (kickersI[k] > kickersJ[k])
                                {
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Assigns a numeric rank to suits for comparison
    private int RankSuits(char suit)
    {
        switch (suit)
        {
            case 'D': return 1;
            case 'C': return 2;
            case 'H': return 3;
            case 'S': return 4;
            default: return 0;
        }
    }

    // Gets the suit of the highest card in a hand that isn't part of a set
    public char GetHighCardSuit(Player p)
    {
        int highCard = -1;
        char highSuit = ' ';
        Dictionary<string, int> countMap = new Dictionary<string, int>();

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            char suit = card[card.Length - 1];

            if (countMap[face] == 1)
            {
                int faceValue = GetFaceValue(face);
                if (faceValue > highCard)
                {
                    highCard = faceValue;
                    highSuit = suit;
                }
            }
        }

        return highSuit;
    }

// Gets a list of kicker card values for tie-breaking
    public List<int> GetKickers(Player p)
    {
        Dictionary<string, int> countMap = new Dictionary<string, int>();
        List<int> kickers = new List<int>();

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (countMap[face] == 1)
            {
                kickers.Add(GetFaceValue(face));
            }
        }

        return kickers;
    }

    // Gets the suit of the highest card in a two pair hand
    public char GetHighCardNI2P(Player p)
    {
        int highCard = -1;
        char highSuit = ' ';
        Dictionary<string, int> countMap = new Dictionary<string, int>();

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            char suit = card[card.Length - 1];
            if (countMap[face] == 2)
            {
                int faceValue = GetFaceValue(face);
                if (faceValue > highCard)
                {
                    highCard = faceValue;
                    highSuit = suit;
                }
            }
        }
        return highSuit;
    }

    // Gets the suit of the highest card in a one pair hand
    public char GetHighCardNIP(Player p)
    {
        int highCard = -1;
        char highSuit = ' ';
        Dictionary<string, int> countMap = new Dictionary<string, int>();

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            char suit = card[card.Length - 1];
            if (countMap[face] == 1)
            {
                int faceValue = GetFaceValue(face);
                if (faceValue > highCard)
                {
                    highCard = faceValue;
                    highSuit = suit;
                }
            }
        }

        return highSuit;
    }

    // Gets the suit of the highest card in a hand
    public char GetHighCard(Player p)
    {
        Dictionary<string, int> countMap = new Dictionary<string, int>();
        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }

        int highCard = -1;
        char highSuit = ' ';
        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (countMap[face] == 1)
            {
                int faceValue = GetFaceValue(face);
                if (faceValue > highCard)
                {
                    highCard = faceValue;
                    highSuit = card[card.Length - 1];
                }
            }
        }
        return highSuit;
    }

    // Gets the rank of the three of a kind in a hand
    public int GetTOAKRank(Player p)
    {
        Dictionary<string, int> countMap = new Dictionary<string, int>();
        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }

        foreach (var entry in countMap)
        {
            if (entry.Value == 3)
            {
                return GetFaceValue(entry.Key);
            }
        }

        return -1;
    }

    // Gets the rank of the four of a kind in a hand
    public int GetFOAKRank(Player p)
    {
        Dictionary<string, int> countMap = new Dictionary<string, int>();

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }

        foreach (var entry in countMap)
        {
            if (entry.Value == 4)
            {
                return GetFaceValue(entry.Key);
            }
        }

        return -1;
    }

    // Gets the ranks of the two pairs in a two pair hand
    public List<int> GetTwoPairRanks(Player p)
    {
        List<int> ranks = new List<int>();
        Dictionary<string, int> countMap = new Dictionary<string, int>();

        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }

        foreach (var entry in countMap)
        {
            if (entry.Value == 2)
            {
                ranks.Add(GetFaceValue(entry.Key));
            }
        }

        ranks.Sort((a, b) => b.CompareTo(a));
        return ranks;
    }

    // Gets the rank of the kicker in a hand
    public int GetKicker(Player p)
    {
        Dictionary<string, int> countMap = new Dictionary<string, int>();
        foreach (string card in p.WordList)
        {
            string face = card.Substring(0, card.Length - 1);
            if (!countMap.ContainsKey(face))
                countMap[face] = 0;
            countMap[face]++;
        }
        foreach (var entry in countMap)
        {
            if (entry.Value == 1)
            {
                return GetFaceValue(entry.Key);
            }
        }
        return -1;
    }

    // Converts face cards to their numeric values
    private int GetFaceValue(string faceString)
    {
        switch (faceString)
        {
            case "J": return 11;
            case "Q": return 12;
            case "K": return 13;
            case "A": return 14;
            default: return int.Parse(faceString);
        }
    }

    // Sorts the hands based on their rank
    public void SortOrder()
    {
        Array.Sort(Result, (a, b) => a.Order.CompareTo(b.Order));
    }

    // Prints the final ranking of hands
    public void PrintResult()
    {
        SortOrder();
        TieBreakers();

        Console.WriteLine("--- WINNING HAND ORDER ---");
        foreach (Player player in Result)
        {
            Console.Write(string.Join(" ", player.WordList));
            Console.WriteLine($" - {player.Hand}");
        }
        Console.WriteLine();
    }
}
