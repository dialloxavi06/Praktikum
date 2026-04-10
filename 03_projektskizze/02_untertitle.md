# Ausgangslage: Daten und Domäne

## 1. Domäne (Kurzfassung)

Im Lebensmitteleinzelhandel werden immer häufiger Self-Checkout-Kassen eingesetzt. Dabei scannen Kundinnen und Kunden ihre Produkte selbst, ohne dass direkt Personal eingreift. Das macht den Einkauf zwar schneller und bequemer, bringt aber auch ein Problem mit sich: Es kommt vor, dass Artikel falsch oder gar nicht gescannt werden – entweder aus Versehen oder absichtlich.

Dadurch entsteht ein Zielkonflikt. Auf der einen Seite möchte man möglichst viele dieser Fehler oder Betrugsfälle erkennen. Auf der anderen Seite sollen die Kundinnen und Kunden aber nicht durch zu viele Kontrollen gestört werden. Ziel des Projekts ist es deshalb, mithilfe von Daten gezielt zu entscheiden, welche Transaktionen überprüft werden sollten, um die Kontrollen effizienter zu machen.

## 2. Daten — wichtige Erkenntnisse

### 2.1 Verfügbare Tabellen und Formate

Für die Analyse stehen mehrere Tabellen zur Verfügung, die unterschiedliche Aspekte der Daten abdecken:

- `products`: enthält Informationen zu den Produkten, z. B. Preis, Kategorie oder Gewicht.
- `stores`: enthält Informationen zu den Filialen.
- `transactions`: beschreibt die einzelnen Einkäufe (z. B. Gesamtbetrag, Anzahl der Produkte, Zeitpunkt, Label).
- `transaction_lines`: enthält die einzelnen Positionen innerhalb einer Transaktion.

Die Daten werden als Parquet-Dateien bereitgestellt und im Notebook/analytisch über DuckDB betrachtet.

### 2.2 Kennzahlen aus der Voranalyse

In der ersten Analyse konnten einige wichtige Kennzahlen festgestellt werden:

- ca. 1,86 Millionen Transaktionen
- ca. 20 Millionen einzelne Positionen (transaction_lines).
- rund 23.900 Produkte.
- Daten aus 50 Filialen.

Außerdem sind ein paar Probleme in den Daten aufgefallen:

- Es gibt über 11.000 Einträge ohne product_id.
- Manche Kombinationen aus transaction_id und product_id kommen mehrfach vor.
- Die Labels sind sehr ungleich verteilt:

    . nur ca. 7.700 Betrugsfälle (1)
    . ca. 178.000 normale Fälle (0)
    . sehr viele unbekannte Fäalle(-1)
Das zeigt, dass wir ein starkes Klassenungleichgewicht haben, was später beim Modell wichtig wird.

### 2.3 Hauptrisiken und Datenvorbereitung

Bei der Arbeit mit den Daten sind mehrere Herausforderungen zu beachten:

- Klassenungleichgewicht: Betrug kommt relativ selten vor, deshalb müssen passende Metriken gewählt werden (z. B. Recall oder Precision).
- Fehlende `product_id`: Hier muss geprüft werden, warum diese fehlen und ob man sie ersetzen oder entfernen sollte.
- Duplikate: Mehrfache Einträge müssen sinnvoll zusammengefasst werden
- Zeitliche und filialspezifische Unterschiede: Daten können sich je nach Zeitraum oder Filiale unterscheiden.
- Kameradaten: Diese könnten zusätzliche Informationen liefern, müssen aber erst auf Qualität geprüft werden.

### 2.4 Vorgehensweise für Vorbereitung, Training und Evaluation

Für die weitere Arbeit planen wir folgendes Vorgehen:

- Datenbereinigung: fehlerhafte oder unvollständige Daten behandeln (z. B. fehlende IDs oder Duplikate)

- Aggregation: statt einzelner Zeilen werden Merkmale auf Transaktionsebene gebildet (z. B. Gesamtpreis, Anzahl Produkte)

- Feature Engineering: zusätzliche Merkmale erstellen, z. B. Zeit, Filiale oder Produktkategorien

- Umgang mit Labels:
    1 = Betrug
    0 = kein Betrug
    -1 = unbekannt (wird entweder entfernt oder separat genutzt)

- Validierung: Aufteilung der Daten nach Zeit (Training auf älteren Daten, Test auf neueren Daten), um realistische Ergebnisse zu bekommen.

- Evaluation: Bewertung mit geeigneten Metriken wie Recall, Precision@k oder AUPRC, je nach Ziel.

# Risiken und Einschränkungen, getroffene Annahmen:
