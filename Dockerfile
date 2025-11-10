FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /source

# 1. Copia los archivos de proyecto (.sln y .csproj)
COPY *.sln .
COPY src/TgTranslator.csproj ./src/

# 2. Restaura las dependencias. Esto crea una capa de caché eficiente.
RUN dotnet restore -r linux-musl-x64

# 3. Copia todo el resto del código fuente
COPY . .

# 4. Publica la aplicación. Se usa el comando restore implícito de publish.
WORKDIR "/source/src"
RUN dotnet publish -c Release -o /app -r linux-musl-x64

# La imagen final usa el runtime de ASP.NET para Alpine, que es más ligero.
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS final
WORKDIR /app
COPY --from=build /app ./

# (Opcional, pero recomendado) Crea un usuario no-root para mayor seguridad
RUN adduser -S -g appuser appuser
USER appuser

ENTRYPOINT ["./TgTranslator"]