FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /source

# Copia los archivos de proyecto y restaura las dependencias primero para aprovechar el caché de capas.
COPY *.sln .
COPY src/*/*.csproj ./
RUN for file in $(ls ./*.csproj); do mkdir -p src/$(echo $file | cut -d . -f 1) && mv $file src/$(echo $file | cut -d . -f 1); done
RUN dotnet restore -r linux-musl-arm

# Copia el resto del código fuente y publica la aplicación para ARM64
COPY src/ ./src/
WORKDIR /source/src/TgTranslator
RUN dotnet publish -c Release -o /app -r linux-musl-arm --self-contained false --no-restore

# La imagen final usa el runtime de ASP.NET para Alpine en ARM64, que es más ligero.
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine-arm32v7 AS final
WORKDIR /app
COPY --from=build /app ./

# Por seguridad, es una buena práctica no ejecutar como root.
RUN adduser --system --group appuser
USER appuser

ENTRYPOINT ["./TgTranslator"]