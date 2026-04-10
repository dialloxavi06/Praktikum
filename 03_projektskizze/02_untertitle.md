# Ausgangslage: Daten und Domäne

## 1. Domäne (Kurzfassung)

Im Lebensmitteleinzelhandel werden immer häufiger Self-Checkout-Kassen eingesetzt. Dabei scannen Kundinnen und Kunden ihre Produkte selbst, ohne dass direkt Personal eingreift. Das macht den Einkauf schneller und bequemer, bringt aber auch Probleme mit sich: Manche Artikel werden falsch oder gar nicht gescannt – entweder aus Versehen oder absichtlich.

Dadurch entsteht ein Zielkonflikt. Einerseits möchte man möglichst viele Fehler und Betrugsfälle erkennen. Andererseits sollen die Kundinnen und Kunden nicht durch zu viele Kontrollen gestört werden. Ziel des Projekts ist es deshalb, mithilfe von Daten gezielt zu entscheiden, welche Transaktionen überprüft werden sollten, um die Kontrollen effizienter zu machen.

---

## 2. Daten — wichtige Erkenntnisse

### 2.1 Verfügbare Tabellen und Formate

Für die Analyse stehen mehrere Tabellen zur Verfügung, die unterschiedliche Aspekte der Daten abdecken:

- `products`: Informationen zu Produkten (z. B. Preis, Kategorie, Gewicht)  
- `stores`: Informationen zu den Filialen  
- `transactions`: beschreibt einzelne Einkäufe (z. B. Gesamtbetrag, Anzahl Produkte, Zeit, Label)  
- `transaction_lines`: einzelne Positionen innerhalb einer Transaktion  

Die Daten liegen als Parquet-Dateien vor und wurden im Notebook mit DuckDB analysiert.

---

### 2.2 Kennzahlen aus der Voranalyse

Die erste Analyse zeigt folgende Größenordnungen:

- Gesamtanzahl Transaktionen: 1.864.116  
- Gesamtanzahl `transaction_lines`: 20.092.938  
- Anzahl Produkte: 23.896  
- Anzahl Filialen: 50  

Zusätzlich sind einige Auffälligkeiten in den Daten zu sehen:

- Fehlende `product_id` in `transaction_lines`: 11.453 (~0,06 %)  
- Duplikate für (`transaction_id`, `product_id`) treten auf (mehrfache Positionseinträge)  
- Labelverteilung (`transactions.label`):  
  - `1` (Betrug): 7.726 (≈ 0,41 %)  
  - `0` (kein Betrug): 178.359 (≈ 9,57 %)  
  - `-1` (unbekannt): 1.678.031 (≈ 90,02 %)  

Diese Verteilung zeigt ein starkes Klassenungleichgewicht, da Betrugsfälle nur einen sehr kleinen Anteil ausmachen.

---

### 2.3 Hauptrisiken und erste Überlegungen

Bei der Arbeit mit den Daten sind einige Herausforderungen zu beachten:

- **Ungleich verteilte Labels:**  
  Betrug kommt selten vor. Ein Modell könnte daher dazu tendieren, fast nur normale Fälle vorherzusagen.  
  → Deshalb sollten geeignete Bewertungsmetriken gewählt werden (z. B. Precision oder Recall).

- **Fehlende `product_id`:**  
  Ohne Produktinformationen fehlen wichtige Details.  
  → Es muss geprüft werden, ob diese Werte ersetzt, markiert oder entfernt werden.

- **Duplikate:**  
  Mehrfache Einträge können aggregierte Werte verfälschen.  
  → Vor der weiteren Analyse sollten diese sinnvoll zusammengefasst werden.

- **Zeitliche und filialspezifische Unterschiede:**  
  Daten können sich je nach Filiale oder Zeitraum unterscheiden.  
  → Das sollte bei der späteren Analyse berücksichtigt werden.

- **Kameradaten:**  
  Zusätzliche Informationen sind vorhanden, aber deren Qualität ist noch unklar.  
  → Nutzung erst nach Prüfung sinnvoll.

---

### 2.4 Vorgehensweise (erste Planung)

Für die nächsten Schritte planen wir ein einfaches und schrittweises Vorgehen:

1. **Erste Datenprüfung**  
   - Überblick über Datenmengen und Struktur  
   - Auffälligkeiten identifizieren (fehlende Werte, Duplikate)

2. **Datenbereinigung**  
   - Umgang mit fehlenden `product_id` klären  
   - Duplikate bereinigen oder zusammenfassen  

3. **Aggregation auf Transaktionsebene**  
   - Bildung einfacher Kennzahlen wie:  
     - Anzahl Produkte  
     - Gesamtbetrag  
     - Durchschnittspreis  

4. **Erste Feature-Ideen**  
   - Zeitliche Merkmale (z. B. Tageszeit, Wochentag)  
   - Filialbezogene Merkmale  
   - Einfache Verhaltensindikatoren (z. B. stornierte Produkte)

5. **Vorbereitung der späteren Analyse**  
   - Aufteilung der Daten nach Zeit (ältere Daten vs. neuere Daten)  
   - Auswahl geeigneter Bewertungsmetriken  

---

### Erste, konkrete To-Dos

- Analyse der 11.453 Zeilen ohne `product_id` (z. B. nach Filiale oder Zeitraum)  
- Bestimmung der Anzahl betroffener Transaktionen durch Duplikate  
- Aufbau einer ersten aggregierten Tabelle auf Transaktionsebene  
- Erste einfache Kennzahlen pro Filiale berechnen  

---

## 3. Problemeskizze

Ziel des Projekts ist es, ein datengetriebenes Modell zu entwickeln, das dabei hilft zu entscheiden, welche Transaktionen an Self-Checkout-Kassen kontrolliert werden sollten.

Für jede Transaktion soll geschätzt werden, wie wahrscheinlich ein fehlerhafter oder betrügerischer Scanvorgang ist. Auf dieser Basis können gezielt nur die auffälligsten Transaktionen überprüft werden.

Dabei sollen zwei Ziele gleichzeitig erreicht werden:

- möglichst viele Betrugsfälle erkennen  
- gleichzeitig die Anzahl der Kontrollen gering halten  

Aus technischer Sicht handelt es sich um ein Klassifikationsproblem mit stark unausgeglichenen Klassen.
