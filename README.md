# Gobbla Server Infra

Automatyzacja przygotowania i konfiguracji serwera dla projektu Gobbla.

Projekt składa się z zestawu skryptów wykonywanych krok po kroku. Każdy krok odpowiada za konkretny element infrastruktury i zapisuje informacje do raportu instalacyjnego.

## Uruchomienie

### Klonowanie repozytorium

```bash
git clone https://github.com/ArnoldSteinhager/gobbla-server-infra.git
cd gobbla-server-infra
```

### Konfiguracja środowiska

Przed uruchomieniem instalatora należy uzupełnić plik:

```text
.env
```

Minimalnie wymagane zmienne:

```env
INSTALL_DIR=/opt/gobbla
SSH_USER=arnolds
```

### Nadanie uprawnień wykonywania

```bash
chmod +x install.sh
chmod +x scripts/*.sh
chmod +x state/*.json
```

### Uruchomienie instalatora

```bash
sudo ./install.sh
```

## Struktura projektu

```text
gobbla-server-infra/
├── install.sh
├── .env
├── README.md
├── logs/
├── state/
└── scripts/
    ├── 01-system-check.sh
    ├── 02-docker.sh
    └── 03-directories.sh
```

## Aktualny stan projektu

Zaimplementowane kroki:

- ✓ 01-system-check.sh
- ✓ 02-docker.sh
- ✓ 03-directories.sh

Planowane kroki:

- 04-github-ssh.sh
- 05-clone-repositories.sh
- 06-deploy-files.sh
- 07-firewall.sh
- 08-certbot.sh
- 09-deploy-app.sh
- 10-mongo-rs.sh

---

## Krok 01 - System Check

Cel:

Przygotowanie systemu operacyjnego do dalszej instalacji infrastruktury.

Zakres działania:

- aktualizacja listy pakietów,
- aktualizacja systemu,
- instalacja podstawowych narzędzi systemowych,
- instalacja OpenSSH Server,
- uruchomienie i włączenie usługi SSH,
- zapis informacji diagnostycznych do raportu.

Rezultat:

System przygotowany do dalszej instalacji.

---

## Krok 02 - Docker

Cel:

Instalacja Docker Engine oraz Docker Compose z oficjalnego repozytorium Docker.

Zakres działania:

- instalacja wymaganych pakietów,
- dodanie oficjalnego repozytorium Docker,
- instalacja Docker Engine,
- instalacja Docker Compose Plugin,
- uruchomienie usługi Docker,
- dodanie użytkownika do grupy docker,
- zapis informacji diagnostycznych do raportu.

Rezultat:

Gotowe środowisko Docker.

Po zakończeniu instalacji wymagane jest ponowne zalogowanie użytkownika, aby aktywować członkostwo w grupie docker.

Weryfikacja:

```bash
docker --version
docker compose version
docker ps
```

---

## Krok 03 - Directories

Cel:

Przygotowanie podstawowej struktury katalogów projektu Gobbla.

Wymagane zmienne:

```env
INSTALL_DIR
SSH_USER
```

Tworzone katalogi:

```text
/opt/gobbla
/opt/gobbla/deploy
/opt/gobbla/scripts
```

Zakres działania:

- utworzenie katalogów projektu,
- nadanie właściciela zgodnie ze zmienną SSH_USER,
- zapis informacji diagnostycznych do raportu.

Rezultat:

Przygotowana struktura katalogów dla kolejnych etapów instalacji.

---

## Raport instalacji

Wszystkie kroki zapisują informacje do pliku:

```text
logs/install-report.log
```

Raport zawiera:

- wykonane kroki,
- informacje diagnostyczne,
- wersje komponentów,
- ewentualne błędy.
