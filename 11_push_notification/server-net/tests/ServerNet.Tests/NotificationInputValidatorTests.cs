namespace ServerNet.Tests;

public class NotificationInputValidatorTests
{
    private readonly NotificationInputValidator _validator = new();

    [Fact]
    public void AcceptsValidTitleAndBodyLengths()
    {
        var titleException = Record.Exception(() => _validator.ValidateTitle("Hello"));
        var bodyException = Record.Exception(() => _validator.ValidateBody("Short body"));

        Assert.Null(titleException);
        Assert.Null(bodyException);
    }

    [Fact]
    public void RejectsEmptyTitle()
    {
        Assert.Throws<InputValidationException>(() => _validator.ValidateTitle("   "));
    }

    [Fact]
    public void RejectsTitleLongerThan30Characters()
    {
        Assert.Throws<InputValidationException>(() => _validator.ValidateTitle(new string('a', 31)));
    }

    [Fact]
    public void RejectsBodyLongerThan100Characters()
    {
        Assert.Throws<InputValidationException>(() => _validator.ValidateBody(new string('b', 101)));
    }
}
