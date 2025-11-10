using System.Threading.Tasks;
using GoogleTranslateFreeApi;
using TgTranslator.Interfaces;
using TgTranslator.Models;

namespace TgTranslator.Services.Translation;

public class GoogleTranslator : ITranslator, ILanguageDetector
{
    private readonly GoogleTranslateFreeApi.GoogleTranslator _translator = new();

    public async Task<string> DetectLanguageAsync(string text)
    {
        var translationResult = await _translator.TranslateAsync(text, Language.Auto, Language.English);
        return translationResult.LanguageDetections[0].Language.ISO639;
    }

    public async Task<TranslationResult> TranslateTextAsync(string text, string targetLanguage)
    {
        var result = await _translator.TranslateAsync(text, Language.Auto, targetLanguage);
        return new TranslationResult { text = result.MergedTranslation, source_lang = result.LanguageDetections[0].Language.ISO639 };
    }
}
