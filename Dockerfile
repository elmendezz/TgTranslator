FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /source

# 1. Copia el archivo de solución y la carpeta 'src' completa.
# Esto asegura que todas las dependencias entre proyectos se resuelvan y aprovecha el cache de Docker.
COPY *.sln .
COPY src/*.csproj ./src/
COPY TgTranslator.LanguageDetector/src/*.csproj ./TgTranslator.LanguageDetector/src/

# 2. Restaura las dependencias para toda la solución.
RUN dotnet restore -r linux-musl-x64

# 3. Copia el resto del código fuente de ambos proyectos.
# Esto asegura que todos los archivos necesarios para la compilación estén presentes.
COPY src/ ./src/
COPY TgTranslator.LanguageDetector/ ./TgTranslator.LanguageDetector/

# 4. Publica el proyecto principal.
# La bandera --no-restore se usa porque ya hemos restaurado todo en el paso anterior.
RUN dotnet publish src/TgTranslator.csproj -c Release -o /app -r linux-musl-x64 --no-restore

# La imagen final usa el runtime de ASP.NET para Alpine, que es más ligero.
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS final
WORKDIR /app
COPY --from=build /app ./

# (Opcional, pero recomendado) Crea un usuario no-root para mayor seguridad.
RUN adduser -S -g appuser appuser
USER appuser

ENTRYPOINT ["dotnet", "TgTranslator.dll"]