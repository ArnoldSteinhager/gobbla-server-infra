# Gobbla Server Infra

Automatyzacja przygotowania i konfiguracji serwera Ubuntu dla projektu Gobbla.

Projekt składa się z zestawu skryptów wykonywanych krok po kroku. Każdy krok odpowiada za konkretny element infrastruktury i zapisuje informacje do raportu instalacyjnego.

Instalator obsługuje:

- wznawianie instalacji,
- śledzenie stanu wykonanych kroków,
- kroki wymagające ręcznej interwencji użytkownika,
- wielokrotne uruchamianie bez ponownego wykonywania zakończonych etapów.

---

# Uruchomienie

## Klonowanie repozytorium

```bash
git clone https://github.com/ArnoldSteinhager/gobbla-server-infra.git
cd gobbla-server-infra
```

## Konfiguracja środowiska

Przed uruchomieniem instalatora należy uzupełnić plik:

```text
.env
```

Przykładowa konfiguracja:

```env
# Instalacja

INSTALL_DIR=/opt/gobbla
DEPLOY_DIR=/opt/gobbla/deploy

# Repozytoria

API_REPO=git@github.com:ArnoldSteinhager/gobbla-api.git
UI_REPO=git@github.com:ArnoldSteinhager/gobbla-ui.git

API_BRANCH=master
UI_BRANCH=master

API_DIR=/opt/gobbla/api
UI_DIR=/opt/gobbla/ui

# Środowisko

ENVIRONMENT=production

# Domena

DOMAIN=uk-gobbla.duckdns.org
EMAIL=gobbla.api@gmail.com

# Docker

MONGO_VERSION=8

# SSH

SSH_USER=arnolds
SSH_KEY_TYPE=ed25519
```

## Nadanie uprawnień wykonywania

```bash
chmod +x install.sh
chmod +x scripts/*.sh
```

## Uruchomienie instalatora

```bash
sudo ./install.sh
```

---

# Struktura projektu

```text
gobbla-server-infra/
├── install.sh
├── .env
├── README.md
├── logs/
│   └── install-report.log
├── state/
│   └── install-state.json
└── scripts/
    ├── 01-system-check.sh
    ├── 02-docker.sh
    ├── 03-directories.sh
    ├── 04-github-ssh.sh
    └── 05-clone-repositories.sh
```

---

# Mechanizm stanu instalacji

Instalator zapisuje stan wykonanych kroków w pliku:

```text
state/install-state.json
```

Przykład:

```json
{
  "01-system-check": "done",
  "02-docker": "done",
  "03-directories": "done",
  "04-github-ssh": "done",
  "05-clone-repositories": "pending"
}
```

Dostępne stany:

| Status          | Opis                                    |
| --------------- | --------------------------------------- |
| pending         | krok nie został jeszcze wykonany        |
| done            | krok zakończony powodzeniem             |
| action-required | wymagana ręczna interwencja użytkownika |

Po ponownym uruchomieniu instalatora wykonanie zostanie wznowione od pierwszego kroku, który nie posiada statusu `done`.

---

# Aktualny stan projektu

## Zaimplementowane kroki

- ✓ 01-system-check.sh
- ✓ 02-docker.sh
- ✓ 03-directories.sh
- ✓ 04-github-ssh.sh
- ✓ 05-clone-repositories.sh

## Planowane kroki

- 06-deploy-files.sh
- 07-firewall.sh
- 08-certbot.sh
- 09-deploy-app.sh
- 10-mongo-rs.sh

---

# Krok 01 - System Check

Cel:

Przygotowanie systemu operacyjnego do dalszej instalacji.

Zakres działania:

- aktualizacja listy pakietów,
- aktualizacja systemu,
- instalacja podstawowych narzędzi systemowych,
- instalacja OpenSSH Server,
- uruchomienie usługi SSH,
- zapis informacji diagnostycznych.

Rezultat:

Gotowy system bazowy.

---

# Krok 02 - Docker

Cel:

Instalacja Docker Engine oraz Docker Compose z oficjalnego repozytorium Docker.

Zakres działania:

- instalacja wymaganych pakietów,
- dodanie repozytorium Docker,
- instalacja Docker Engine,
- instalacja Docker Compose Plugin,
- uruchomienie usługi Docker,
- dodanie użytkownika do grupy docker,
- zapis informacji diagnostycznych.

Rezultat:

Gotowe środowisko Docker.

Po zakończeniu kroku wymagane jest ponowne zalogowanie użytkownika.

Weryfikacja:

```bash
docker --version
docker compose version
docker ps
```

---

# Krok 03 - Directories

Cel:

Przygotowanie struktury katalogów projektu.

Tworzone katalogi:

```text
/opt/gobbla
/opt/gobbla/deploy
/opt/gobbla/scripts
```

Zakres działania:

- utworzenie katalogów,
- ustawienie właściciela,
- zapis informacji diagnostycznych.

Rezultat:

Przygotowana struktura katalogów dla aplikacji i deploymentu.

---

# Krok 04 - GitHub SSH

Cel:

Przygotowanie uwierzytelniania SSH dla GitHub.

Zakres działania:

- generowanie klucza SSH,
- konfiguracja known_hosts,
- weryfikacja połączenia z GitHub,
- obsługa ręcznego dodania klucza do GitHub.

Rezultat:

Serwer posiada dostęp SSH do prywatnych repozytoriów GitHub.

Krok wykorzystuje mechanizm:

```text
action-required
```

w celu zatrzymania instalacji do czasu dodania klucza SSH w GitHub.

---

# Krok 05 - Clone Repositories

Cel:

Pobranie kodu źródłowego aplikacji Gobbla.

Zakres działania:

- weryfikacja połączenia SSH z GitHub,
- klonowanie repozytorium API,
- klonowanie repozytorium UI,
- checkout wymaganych branchy,
- zapis aktualnych commitów do raportu.

Rezultat:

```text
/opt/gobbla
├── api
├── ui
├── deploy
└── scripts
```

Kod aplikacji jest gotowy do dalszych etapów deploymentu.

---

# Raport instalacji

Wszystkie kroki zapisują informacje do pliku:

```text
logs/install-report.log
```

Raport zawiera:

- wykonane kroki,
- informacje diagnostyczne,
- wersje komponentów,
- aktualne commity repozytoriów,
- informacje o błędach,
- komunikaty wymagające ręcznej interwencji użytkownika.
