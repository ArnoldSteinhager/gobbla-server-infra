# Gobbla Server Infra

## Cel projektu

Gobbla Server Infra to zestaw skryptów automatyzujących przygotowanie i konfigurację serwera dla aplikacji Gobbla.

Projekt powstał na podstawie rzeczywistego procesu wdrażania środowiska produkcyjnego i ma umożliwić odtworzenie kompletnej infrastruktury na nowym serwerze Ubuntu przy możliwie minimalnej liczbie ręcznych operacji.

Główne założenia:

- automatyzacja instalacji infrastruktury,
- możliwość wielokrotnego uruchamiania skryptów,
- podział instalacji na małe, niezależne kroki,
- raportowanie wykonanych operacji,
- możliwość wznowienia instalacji po błędzie,
- centralna konfiguracja w pliku `.env`,
- dokumentacja tworzona równolegle z rozwojem projektu.

## Struktura projektu

```text
gobbla-server-infra/

.env
.env.example

install.sh

scripts/
├── 01-system-check.sh
├── 02-docker.sh
├── ...

templates/

state/
└── install-state.json

logs/
└── install-report.log

README.md
```

## Sposób działania

Każdy etap instalacji realizowany jest przez osobny skrypt znajdujący się w katalogu `scripts`.

Główny skrypt `install.sh` odpowiada za:

- uruchamianie kroków we właściwej kolejności,
- kontrolę błędów,
- zapis raportu instalacji,
- śledzenie stanu wykonanych kroków.

## Aktualny zakres

Projekt jest w trakcie budowy. Dokumentacja odzwierciedla wyłącznie funkcjonalności, które zostały rzeczywiście zaimplementowane i przetestowane.
