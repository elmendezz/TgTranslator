FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /source

# 1. Copia los archivos de proyecto (.sln y .csproj)
# Asumimos que el .csproj está en la carpeta 'src'
COPY *.sln .
COPY src/TgTranslator.csproj ./src/

# 2. Restaura las dependencias. Esto aprovecha el caché de Docker.
RUN dotnet restore -r linux-musl-x64

# 3. Copia el resto del código fuente y publica la aplicación
COPY src/ ./src/
RUN dotnet publish src/TgTranslator.csproj -c Release -o /app -r linux-musl-x64 --no-restore

# La imagen final usa el runtime de ASP.NET para Alpine, que es más ligero.
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final
WORKDIR /app
COPY --from=build /app ./

# Instala la librería nativa de SQLite y crea un directorio para la base de datos
RUN apk add --no-cache sqlite-libs && \
    mkdir /app/data

# Crea un usuario no-root y le da permisos sobre el directorio de datos
RUN adduser --system --group appuser
RUN chown -R appuser:appuser /app/data
USER appuser

ENTRYPOINT ["./TgTranslator"]