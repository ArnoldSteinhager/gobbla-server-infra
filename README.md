# Gobbla Server Infra

Automatyzacja przygotowania i konfiguracji serwera dla projektu Gobbla.

Projekt składa się z zestawu skryptów uruchamianych krok po kroku. Każdy krok odpowiada za konkretny element infrastruktury i zapisuje informacje do raportu instalacyjnego.

## Polecenia startowe

Klonowanie repozytorium:

```bash
git clone https://github.com/ArnoldSteinhager/gobbla-server-infra.git
cd gobbla-server-infra
```

Nadanie uprawnień wykonywania:

```bash
chmod +x install.sh
chmod +x scripts/*.sh
```

Uruchomienie instalatora:

```bash
sudo ./install.sh
```

## Struktura projektu

```text
gobbla-server-infra/
├── install.sh
├── .env
├── logs/
├── state/
├── scripts/
└── README.md
```

- install.sh - główny instalator uruchamiający kolejne kroki.
- .env - konfiguracja środowiska.
- logs - raporty i logi instalacji.
- state - pliki stanu wykorzystywane przez instalator.
- scripts - skrypty realizujące poszczególne etapy instalacji.

## Krok 01 - System Check

Cel:
Przygotowanie systemu operacyjnego do dalszej instalacji infrastruktury.

Wykonywane operacje:

1. Weryfikacja uruchomienia skryptu z uprawnieniami administratora.
2. Aktualizacja listy pakietów systemowych.
3. Aktualizacja zainstalowanych pakietów.
4. Instalacja wymaganych narzędzi systemowych:
   - git
   - curl
   - wget
   - jq
   - ca-certificates
   - gnupg

5. Weryfikacja dostępności interpretera Python.
6. Zapis informacji o pamięci RAM do raportu.
7. Zapis informacji o przestrzeni dyskowej do raportu.
8. Zapis listy usług w stanie FAILED do raportu.
9. Utworzenie wpisu w raporcie potwierdzającego zakończenie kroku.

Rezultat:
System przygotowany do instalacji kolejnych komponentów infrastruktury.

## Krok 02 - Instalacja Docker

Skrypt `02-docker.sh` instaluje najnowszą wersję Docker Engine oraz Docker Compose z oficjalnego repozytorium Docker.

Zakres działania:

- instalacja wymaganych pakietów systemowych,
- dodanie oficjalnego repozytorium Docker,
- instalacja Docker Engine,
- instalacja Docker Compose Plugin,
- włączenie automatycznego startu usługi Docker,
- uruchomienie usługi Docker,
- dodanie użytkownika instalacyjnego do grupy `docker`,
- zapis informacji diagnostycznych do raportu instalacji.

Po zakończeniu instalacji wymagane jest ponowne zalogowanie użytkownika, aby aktywować członkostwo w grupie `docker`.

Weryfikacja działania:

```bash
docker --version
docker compose version
docker ps
```
