#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/playwright/dotnet:v1.40.0-jammy AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["DockerTestProject.csproj", "."]
RUN dotnet restore "./DockerTestProject.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "DockerTestProject.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DockerTestProject.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DockerTestProject.dll", "/usr/bin/xvfb-run -a $@"]