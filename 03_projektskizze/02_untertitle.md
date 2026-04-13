# Ausgangslage: Daten

---

## Verfügbare Datenquellen

Die Daten wurden in zwei Formaten bereitgestellt:

Vier Parquet-Dateien
Eine konsolidierte DuckDB-Datenbank (data.duckdb)

Beide Formate enthalten identische Tabellen.
Die DuckDB-Datei fasst die Parquet-Dateien lediglich zu einer integrierten, performanten Datenbank zusammen.
Das Projektteam kann frei entscheiden, welches Format für die weitere Analyse verwendet wird.
Enthaltene Tabellen

products – Produktinformationen (Preis, Kategorie, Gewicht usw.)
stores – Filialinformationen
transactions – vollständige Transaktionen inkl. Label
transaction_lines – gescannte Artikelpositionen

---

## Kennzahlen aus der Voranalyse

Im Rahmen einer ersten strukturellen Durchsicht der bereitgestellten Daten ergaben sich folgende zentrale Beobachtungen:

### 1. Datenumfang und Standortabdeckung

Insgesamt stehen Daten aus 50 Filialen zur Verfügung.
Da unklar ist, wie viele Filialen die Einzelhandelskette insgesamt betreibt, ist die Repräsentativität der Daten derzeit nicht eindeutig bewertbar.
→ Dies wird im Austausch mit Domänenexpertinnen und -experten weiter geklärt.

### 2. Überblick über Datenmengen

Transaktionen: ca. 1,86 Mio.
Scanpositionen (transaction_lines): ca. 20 Mio.
Produkte: ca. 24.000

### 3. Labelverteilung und aktuelle Annahme der Zielgröße

Da keine offizielle Dokumentation zu den Labels vorliegt, wurde ihre Bedeutung anhand der Datenverteilung interpretiert.

Nur ca. 10 % aller Transaktionen besitzen ein aussagekräftiges Label (0 oder 1).
Davon sind rund 5 % als auffällig (1) gekennzeichnet.
Etwa 90 % der Transaktionen tragen das Label –1 (unbekannt / nicht geprüft).

Arbeitsannahme (wird später validiert):

1 → bestätigte Auffälligkeit / fehlerhafter Scan
0 → geprüfte und unauffällige Transaktion
–1 → unbekannter oder nicht geprüfter Status

Diese Verteilung weist auf ein extrem unausgeglichenes Klassifikationsproblem hin.

### 4. Datenqualität

Fehlende Werte: ca. 11.000 Positionen ohne product_id
Duplikate: vereinzelt doppelte (transaction_id, product_id)‑Kombinationen
Mögliche Filial- oder Zeitabhängigkeit: Unterschiede zwischen Standorten oder Zeiträumen müssen untersucht werden.

### 5. Unklare bzw. domänenspezifische Attribute

Einige Felder sind inhaltlich nicht eindeutig interpretierbar und erfordern Rücksprache mit Domänenexpertinnen und -experten:

camera_product_similar
camera_certainty
urbanization
popularity

Diese Variablen können potenziell für die spätere Modellierung relevant sein, ihre Bedeutung muss jedoch zunächst eindeutig geklärt werden.

---

## Aufbereitungsschritte

Die Phase der Datenbereitstellung umfasst:

Strukturelle Prüfung der Tabellen (Parquet oder DuckDB)
Bereinigung

fehlende Werte
Duplikate
inkonsistente Einträge

Zusammenführung zu einer konsistenten analytischen Datenbasis
Erste Aggregationen, z. B.:

Artikelanzahl pro Transaktion
Gesamtsumme
zeitliche Merkmale

Dokumentation aller Annahmen und Bereinigungsschritte

Ergebnis: ein bereinigter, strukturierter und modellierungsfähiger Datensatz für die Analysephase.