using System;
using System.Threading.Tasks;
using TgTranslator.Interfaces;
using TgTranslator.Models;

namespace TgTranslator.Services.Translation;

public class TranslatePlaceholderService : ITranslator
{
    private const string ImplementMessage = "You have to implement the translation service for yourself!\nUse ITranslator and ILanguageDetector and add your service to DiServices.cs";
    public TranslatePlaceholderService()
    {
        throw new NotImplementedException(ImplementMessage);
    }
    public Task<TranslationResult> TranslateTextAsync(string text, string to)
    {
        throw new NotImplementedException(ImplementMessage);
    }
}