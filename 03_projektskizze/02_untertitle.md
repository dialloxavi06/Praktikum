# Ausgangslage: Daten und Domäne

## 1. Domäne

### 1.1 Kontext

Das Projekt beschäftigt sich mit dem Einsatz von Self-Checkout-Kassen im Lebensmitteleinzelhandel.  
Kundinnen und Kunden scannen ihre Produkte eigenständig, ohne direkte Kontrolle durch das Personal.

### 1.2 Problembeschreibung

Im Kontext von Self-Checkout-Kassen im Lebensmitteleinzelhandel tritt das Problem auf, dass nicht alle Waren von den Kundinnen und Kunden korrekt erfasst werden.

Die Ursachen hierfür sind vielfältig und reichen von absichtlichem Betrug über unbeabsichtigte Fehler bis hin zu technischen Problemen. Empirische Untersuchungen zeigen, dass etwa 5 % der Scanvorgänge inkorrekt sind.

Um diesen Verlusten entgegenzuwirken, sollen gezielte Nachkontrollen bei verdächtigen Transaktionen durchgeführt werden. Dabei besteht die Herausforderung darin, die Anzahl der Kontrollen möglichst gering zu halten, um zusätzliche Kosten sowie negative Auswirkungen auf die Kundenzufriedenheit zu vermeiden, während gleichzeitig möglichst viele fehlerhafte Scans erkannt werden sollen.

### 1.3 Ziel des Projekts

Ziel des Projekts ist es, ein datengetriebenes System zu entwickeln, das verdächtige Transaktionen identifizieren kann.  
Auf dieser Grundlage sollen gezielte Kontrollen durchgeführt werden, um fehlerhafte oder betrügerische Scans zu erkennen.

### 1.4 Wirtschaftliche und praktische Herausforderungen

Eine zentrale Herausforderung besteht darin, ein Gleichgewicht zwischen zwei gegensätzlichen Zielen zu finden:

- Einerseits sollen möglichst viele fehlerhafte Scans erkannt werden.  
- Andererseits sollen unnötige Kontrollen vermieden werden, um Kosten zu reduzieren und die Kundenzufriedenheit nicht zu beeinträchtigen.  

Darüber hinaus müssen sowohl wirtschaftliche als auch praktische Rahmenbedingungen der Domäne berücksichtigt werden, da diese alle Phasen des Projekts beeinflussen.

## 2. Daten

### 2.1 Verfügbare Datenquellen

Für das Projekt stehen verschiedene Datenquellen zur Verfügung, die zur Analyse von Scanvorgängen an Self-Checkout-Kassen genutzt werden können.

Eine zentrale Datenquelle bilden Transaktionsdaten aus dem Einzelhandel, die Informationen über gescannte Produkte und den Ablauf einzelner Kaufvorgänge enthalten. Ergänzend dazu liegen Ergebnisse aus Stichprobenkontrollen vor, anhand derer festgestellt wurde, ob Scanvorgänge korrekt oder fehlerhaft waren. Diese Daten dienen insbesondere als Grundlage für das Training von Modellen.

Darüber hinaus können Kameradaten zur Verfügung stehen, die zusätzliche Informationen über das Verhalten der Kundinnen und Kunden während des Scanvorgangs liefern können.

Die Trainingsdaten stammen aus Stichprobenkontrollen in verschiedenen Filialen aus den Jahren 2022 und 2023, während separate Testdaten aus den Jahren 2024 und 2025 bereitgestellt werden, um die Generalisierungsfähigkeit der entwickelten Modelle zu überprüfen.

Die Bereitstellung und Nutzung der Daten erfolgt voraussichtlich über eine REST-API, wodurch eine standardisierte und flexible Anbindung an die entwickelten Analyseverfahren ermöglicht wird.

### 2.2 Mögliche Datenstruktur

Die bereitgestellten Daten lassen sich in mehrere miteinander verknüpfte Tabellen unterteilen, die unterschiedliche Aspekte des Einkaufsprozesses abbilden.

Die Tabelle „products“ enthält Informationen zu einzelnen Produkten, wie beispielsweise Preis, Kategorie, Gewicht sowie weitere produktspezifische Eigenschaften.

Die Tabelle „stores“ beschreibt die Filialen, in denen die Transaktionen stattfinden, und umfasst unter anderem Standortinformationen sowie den Zeitpunkt der Einführung von Self-Checkout-Kassen.

Die Tabelle „transactions“ bildet die einzelnen Kaufvorgänge ab. Sie enthält Informationen wie den Gesamtbetrag, die Anzahl der gescannten Positionen sowie Zeitstempel für Beginn und Ende der Transaktion. Zudem ist ein Label enthalten, das angibt, ob eine Transaktion auffällig oder fehlerhaft ist.

Die Tabelle „transaction_lines“ stellt die detaillierteste Ebene dar und enthält Informationen zu einzelnen gescannten Produkten innerhalb einer Transaktion. Dazu gehören unter anderem Zeitstempel, verkaufte Menge, Preis sowie Hinweise aus Kameradaten.

Die verschiedenen Tabellen können über Schlüsselattribute miteinander verknüpft werden, insbesondere über „transaction_id“, „product_id“ und „store_id“. Dadurch ist es möglich, den gesamten Ablauf eines Einkaufs von der Filiale über die Transaktion bis hin zu einzelnen Produkten nachzuvollziehen.

### 2.3 Erwartete Datenprobleme

Im Rahmen der Datenanalyse sind verschiedene Herausforderungen zu erwarten.

Ein zentrales Problem ist die mögliche Unausgewogenheit der Daten, da fehlerhafte oder betrügerische Transaktionen im Vergleich zu normalen Transaktionen nur einen kleinen Anteil ausmachen.

Zudem können die Daten unvollständig oder verrauscht sein, beispielsweise durch fehlende Werte oder ungenaue Kamerainformationen.

Ein weiteres Problem besteht in der Komplexität der Datenstruktur, da mehrere Tabellen miteinander verknüpft werden müssen, um aussagekräftige Analysen durchführen zu können.

Darüber hinaus kann das Verhalten der Kundinnen und Kunden stark variieren, was die Erkennung von Mustern zusätzlich erschwert.

Schließlich ist auch zu berücksichtigen, dass bestimmte Variablen, wie beispielsweise Kameradaten, Unsicherheiten enthalten können, die sich auf die Qualität der Analyse auswirken.

### 2.4 Trainings- und Testdaten
