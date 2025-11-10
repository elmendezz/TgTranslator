FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /source

# 1. Copia el archivo de solución
COPY *.sln .

# 2. Crea la estructura de carpetas esperada por el .sln y copia el .csproj
# El .sln espera el .csproj en 'src/TgTranslator/TgTranslator.csproj'
# y en el host, el .csproj está en 'src/TgTranslator.csproj'
RUN mkdir -p src/TgTranslator/
COPY src/TgTranslator.csproj ./src/TgTranslator/

# 3. Copia el resto del código fuente del proyecto a la ubicación esperada
COPY src/ ./src/TgTranslator/

# 4. Restaura las dependencias. Ahora el .sln debería encontrar el .csproj.
RUN dotnet restore -r linux-musl-x64

# 5. Publica la aplicación
RUN dotnet publish src/TgTranslator/TgTranslator.csproj -c Release -o /app -r linux-musl-x64 --no-restore

# La imagen final usa el runtime de ASP.NET para Alpine, que es más ligero.
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS final
WORKDIR /app
COPY --from=build /app ./

# Instala la librería nativa de SQLite y crea un directorio para la base de datos
RUN apk add --no-cache sqlite-libs && \
    mkdir /app/data

# Crea un usuario no-root para mayor seguridad y le da permisos sobre el directorio de datos
RUN adduser --system --group appuser
RUN chown -R appuser:appuser /app/data
USER appuser

ENTRYPOINT ["./TgTranslator"]