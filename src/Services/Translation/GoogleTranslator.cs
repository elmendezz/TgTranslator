using System.Threading.Tasks;
using GoogleTranslateFreeApi;
using TgTranslator.Interfaces;

namespace TgTranslator.Services.Translation;

public class GoogleTranslator : ITranslator
{
    private readonly GoogleTranslateFreeApi.GoogleTranslator _translator = new();

    public async Task<Interfaces.TranslationResult> TranslateTextAsync(string text, string targetLanguage)
    {
        // En la v1.1.1, el idioma de origen se detecta automáticamente y viene en la propiedad 'Language'
        var from = Language.Auto;
        var to = GoogleTranslateFreeApi.Language.GetLanguage(targetLanguage);
        
        var result = await _translator.TranslateAsync(text, from, to);
        
        return new Interfaces.TranslationResult(
            Text: result.MergedTranslation,
            DetectedLanguage: result.Language.ISO639
        );
    }
}
