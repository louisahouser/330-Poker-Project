public class CreateCard
{
    public string Suit { get; set; }
    public string Face { get; set; }

    // Default constructor
    public CreateCard()
    {
    }

    // Parameterized constructor
    public CreateCard(string suit, string face)
    {
        Suit = suit;
        Face = face;
    }
}
