FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY Repro.csproj Program.cs ./
RUN dotnet publish -c Release -r linux-x64 --self-contained -o /app

# RHEL 8 userland (glibc 2.28). RHEL 8 is a supported OS for .NET 10.
FROM registry.access.redhat.com/ubi8/ubi-minimal
RUN microdnf install -y libstdc++ && microdnf clean all
COPY --from=build /app /app
CMD ["sh", "-c", "ldd --version | head -1 && /app/Repro"]
