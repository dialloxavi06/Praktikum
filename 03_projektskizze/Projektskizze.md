% Projektskizze nach DASC-PM

# Projektskizze — Analyse von Scanvorgängen an Selbstbedienungskassen

**Titel des Projekts:** Analyse von Scanvorgängen an Selbstbedienungskassen zur Erkennung nicht gescannter Artikel

**Modul:** 64520 Projektpraktikum Data Science in der Anwendung – SoSe 2026

**Dozent:** Prof. Dr. Christian Beecks

**Betreuer:** Sabine Folz-Weinstein, Max Pernklau

**Hochschule:** FernUniversität in Hagen

**Bearbeitet von:**

- Ben Kröncke – 4150112
- Mamadou Diallo – 2138395
- Ronja Thum – 7316291
- Marius Schneider – 4154142

**Abgabedatum:** 20.04.2026

**Präsentation:** 22.04.2026

## Inhaltsverzeichnis

- Abgleich der Kundenerwartungen mit dem Leistungsumfang
- Projektbeschreibung und Leistungsumfang
- Ausgangslage: Daten und Domäne
	- Verfügbare Datenquellen
	- Datenmodell und Tabellenstruktur
	- Erste Erkenntnisse der Voranalyse
- Projektplan: Teilaufgaben in den einzelnen Phasen
	- Projektauftrag
	- Datenbereitstellung
	- Analyse
	- Nutzbarmachung
	- Ausblick: Nutzung
- Risiken und Einschränkungen
- Offene Punkte

---

## Abgleich der Kundenerwartungen mit dem Leistungsumfang

### Kundenerwartungen und Zielvorstellung

Mit der Einführung von Selbstbedienungskassen wurde festgestellt, dass nicht alle Waren vollständig oder korrekt erfasst werden. Ursachen hierfür können absichtliches Nicht-Scannen, versehentliche Fehler oder technische Probleme sein. Nach vorliegenden empirischen Untersuchungen sind etwa fünf Prozent der Scanvorgänge inkorrekt. Vor diesem Hintergrund besteht das Interesse, auffällige Scanvorgänge gezielter zu identifizieren, um Nachkontrollen effizienter zu steuern.

Aus Kundensicht besteht das Projektziel darin, mit Hilfe von Data-Science-Methoden die Aufdeckungsquote fehlerhafter Scanvorgänge zu erhöhen und gleichzeitig die Anzahl der Kontrollen möglichst gering zu halten. Dadurch sollen wirtschaftliche Schäden reduziert, personelle Ressourcen effizient eingesetzt und das Einkaufserlebnis möglichst wenig durch unnötige Kontrollen beeinträchtigt werden. Erwartet wird eine datengetriebene Unterstützung bei der Erkennung und Priorisierung fehlerhafter Vorgänge als Grundlage für gezielte Nachkontrollen.

Für die Durchführung des Projektes stellt der Kunde Filial- und Produktstammdaten sowie historische Transaktionsdaten mit Ergebnissen aus Stichprobenkontrollen zur Verfügung. Ergänzend soll der Einbezug von Kameradaten betrachtet werden, sofern diese technisch verfügbar, fachlich sinnvoll verknüpfbar und datenschutzrechtlich nutzbar sind. Darüber hinaus besteht die Erwartung, dass die entwickelte Lösung über eine REST-API nutzbar gemacht wird.

Das Projekt wird fachlich durch den Bereich Filialbetrieb geleitet. Zusätzlich sind Produktverantwortliche für die Selbstbedienungskassen sowie Filialleitungen eingebunden. Für fachliche, methodische, technische und regulatorische Fragestellungen werden Vertreter aus den Bereichen Daten, IT sowie Datenschutz und Compliance eingebunden.

## Projektbeschreibung und Leistungsumfang

Ziel ist die Entwicklung, Bewertung und prototypische Bereitstellung eines Klassifikationsmodells zur Erkennung auffälliger Scanvorgänge. Der Modelloutput wird als Risikoscore ausgegeben, der zur Priorisierung auffälliger Vorgänge genutzt werden kann. Ergänzend wird untersucht, welche Schwellenwerte oder Entscheidungsregeln für eine operative Nutzung geeignet sind.

Leistungsumfang (Auszug):

- Datenexploration und -aufbereitung
- Feature-Engineering und Modellentwicklung
- Bewertung des datengetriebenen Ansatzes gegenüber Stichprobenpraktiken
- Prototypische Bereitstellung der Lösung über eine REST-API
- Dokumentation der Ergebnisse und Offenlegung der Grenzen

Eine vollständige Integration in bestehende IT-Systeme ist nicht Teil des Projekts.

## Ausgangslage: Daten und Domäne

### Verfügbare Datenquellen

Es stehen folgende Datenquellen zur Verfügung:

- Vier Parquet-Dateien
- Eine konsolidierte DuckDB-Datenbank (`data.duckdb`)

Die DuckDB-Datenbank fasst die Parquet-Dateien zusammen und erleichtert explorative Analysen sowie komplexe Aggregationen.

### Datenmodell und Tabellenstruktur

Die Daten sind in vier logisch verknüpften Tabellen organisiert. Das Modell ist nicht als klassisches Sternschema aufgebaut, sondern als mehrstufige Struktur:

- `stores` (1) → `transactions` (n) über `store_id`
- `transactions` (1) → `transaction_lines` (n) über `transaction_id`
- `products` (1) → `transaction_lines` (n) über `product_id`

Kurzbeschreibung der Tabellen:

- `products`: Produktstammdaten (Preis, Kategorie, Gewicht, Popularität, scannbar-Flag, ...)
- `stores`: Filialmerkmale (Bundesland, Urbanisierungsgrad, Eröffnungsdatum, Einführung der SB-Kassen)
- `transactions`: Metadaten zu Kaufvorgängen (Start-/Endzeit, Gesamtsumme, Anzahl Positionen, Zahlungsmethode, Feedback, Label)
- `transaction_lines`: Einzelne Artikelpositionen (Preis, Menge/Gewicht, Stornoflag, kamerabasierte Merkmale)

### Erste Erkenntnisse der Voranalyse

1. Datenumfang und Standortabdeckung

Insgesamt umfasst das Filialnetz 50 Standorte; für diese Analyse liegen Transaktionsdaten aus zehn Filialen vor. Die Repräsentativität dieser Stichprobe ist noch zu bewerten.

2. Überblick über Datenmengen

Der Datensatz enthält ca. 1,86 Mio. Transaktionen mit ~20 Mio. Positionen und ~24.000 Produkten. Zeitraum: 07.02.2022–30.12.2023. Einführung der SB-Kassen: 02.02.2022–24.03.2022.

3. Labelverteilung und Annahmen

Nur ~10 % der Transaktionen verfügen über ein gültiges Label (0/1); von diesen sind ~5 % als auffällig (1) markiert. Rund 90 % tragen den Wert `-1` (unbekannter/ungeprüfter Status). Dies führt zu einem stark unausgeglichenen Klassifikationsproblem.

4. Datenqualität

- Ca. 11.000 Artikelzeilen fehlen `product_id` (mögliche fehlerhafte/nicht erkannte Scans)
- Vereinzelt doppelte Kombinationen aus `transaction_id` und `product_id`
- Mögliche domänenspezifische Unterschiede (Filiale, Zeitraum, Kassentyp)

5. Unklare/domänenspezifische Attribute

Folgende Variablen benötigen fachliche Klärung:

- `camera_product_similar`
- `camera_certainty`
- `urbanization`
- `popularity`

## Projektplan: Teilaufgaben in den einzelnen Phasen

Die Projektphasen orientieren sich am DASC-PM: Projektauftrag, Datenbereitstellung, Analyse, Nutzbarmachung und Nutzung. Projektzeitraum: 01.04.2025–15.07.2026.

### Projektauftrag

Aufgabe: Domänenverständnis schaffen, Use Case definieren, Projektziele mit dem Kunden abstimmen. Ergebnis: Projektskizze (Abgabe: 20.04.2026; Präsentation: 22.04.2026).

### Datenbereitstellung

Aufgaben: Daten erfassen, strukturieren, bereinigen und eine analytische Datenquelle erzeugen. Explorative Datenanalyse zur Identifikation relevanter Merkmale. Zeitraum: 22.04.2026–18.05.2026.

### Analyse

Aufgaben: Modellentwicklung (überwachtes Lernen), Evaluation, Methodenauswahl (z. B. logistische Regression, Entscheidungsbäume, Ensemblemethoden), Validierung und Metriken (Precision, Recall, F1, etc.). Zeitraum: 19.05.2026–15.06.2026.

### Nutzbarmachung

Aufgaben: Prototypische Bereitstellung der Lösung (z. B. REST-API), technische Prüfung, Beschreibung der Systemkomponenten. Zeitraum: 15.06.2026–15.07.2026.

## Ausblick: Nutzung

Nach Projektabschluss: Integration und Monitoring des Modells in der Domäne, kontinuierliche Evaluation und Anpassung bei veränderten Bedingungen.

## Risiken und Einschränkungen

- Begrenzte und potenziell verzerrte Datenbasis
- Unsicherheit über Labelqualität und Konsistenz
- Stark unausgeglichene Klassenverteilung
- Unklare Verfügbarkeit und Nutzbarkeit ergänzender Datenquellen (z. B. Kameradaten)
- Anforderungen an Infrastruktur und Performance für einen Echtbetrieb
- Datenschutzrechtliche und organisatorische Einschränkungen

## Offene Punkte

- Fachliche Bedeutung und Ausprägung der Zielvariable klären
- Repräsentativität der Stichprobenkontrollen prüfen
- Detaillierte Struktur und Vollständigkeit der Trainings-/Testdaten klären
- Prüfung der technischen und datenschutzrechtlichen Nutzbarkeit von Kameradaten
- Konkrete Anforderungen an die REST-API (Ein-/Ausgaben, Performance)

Datenbereitstellung
In der Phase der Datenbereitstellung werden die für das Projekt relevanten Daten erfasst,
gespeichert und verwaltet. Dabei klären Data Scientists, Data Engineers und
Domänenexperten, welche Daten in welcher Form vorliegen, wer diese verwaltet, wie der
Zugriff erfolgt und ob die vorliegenden Daten ausreichen oder durch zusätzliche Quellen,
beispielsweise Kameradaten, ergänzt werden müssen. Im Projekt stehen hierzu verschiedene
Datenquellen, unter anderem in Form von DuckDB- oder Parquet-Dateien, zur Verfügung.
Diese müssen hinsichtlich ihrer Struktur, Qualität und Vollständigkeit analysiert und
gegebenenfalls bereinigt werden, um sie für die anschließende Analyse nutzbar zu machen.
Anschließend erfolgt eine explorative Datenanalyse, um ein grundlegendes Verständnis der
Daten zu gewinnen sowie Muster und Auffälligkeiten zu identifizieren. Dabei erstellen Data
Scientists mithilfe von Python erste Kennzahlen und Visualisierungen und untersuchen
insbesondere Zusammenhänge zwischen Transaktionsdauer, Preis, Produktkategorien und
Zahlungsarten. Ziel ist es, typische Verhaltensmuster regulärer Transaktionen von potenziell
auffälligen Vorgängen zu unterscheiden. Ergänzend werden statistische Methoden eingesetzt,
um Ausreißer und ungewöhnliche Kombinationen von Merkmalen zu erkennen.
Auf Basis dieser Erkenntnisse werden relevante Merkmale für die spätere Analyse definiert.
Dazu zählen beispielsweise ungewöhnlich kurze oder lange Transaktionsdauern, auffällige
Preisabweichungen im Vergleich zu typischen Warenkörben, ungewöhnliche
Produktkombinationen oder Abweichungen in der Popularität gescannter Artikel. Die dabei
entstehenden Ergebnisse werden als Artefakte dokumentiert und für die weitere
Projektabstimmung genutzt.
Abschließend wird eine analytische Datenquelle erstellt, welche als Grundlage für die
folgende Analysephase dient. Dabei handelt es sich um einen strukturierten, bereinigten und
für die Modellierung geeigneten Datensatz.
Die Phase der Datenbereitstellung erstreckt sich vom 22.04.2026 bis zum 18.05.2026 und
wird mit der Erstellung der analytischen Datenquelle abgeschlossen. Aufgrund des iterativen
Charakters von Data-Science-Projekten kann es jedoch erforderlich sein, einzelne Schritte
mehrfach zu durchlaufen, bis eine geeignete Datenbasis vorliegt.
Analyse
In der Analysephase werden geeignete datengetriebene Verfahren auf die zuvor erstellte
analytische Datenquelle angewendet. Ziel ist es, ein Modell zu entwickeln, das vorhersagen
kann, ob an Selbstbedienungskassen Artikel nicht gescannt wurden beziehungsweise ob eine
Transaktion als unauffällig oder auffällig einzustufen ist. Da im vorliegenden Projekt bereits
gelabelte Daten in der Tabelle transactions sowie Trainings- und Testdaten zur Verfügung
stehen, handelt es sich um ein überwachtes Lernproblem. Entsprechend werden geeignete
Klassifikationsverfahren ausgewählt und angewendet, beispielsweise logistische Regression,
Entscheidungsbäume oder ensemblebasierte Methoden. Ergänzend können einfache
regelbasierte Ansätze berücksichtigt werden, um leicht erkennbare Auffälligkeiten direkt zu
identifizieren. Die Auswahl des konkreten Ansatzes erfolgt auf Basis der vorangegangenen
Analysen und muss im weiteren Verlauf gründlich evaluiert werden.
Nach der Auswahl des Ansatzes erfolgt die strukturierte Umsetzungsplanung. Dabei werden
die einzelnen Schritte der Datenaufbereitung, Modellentwicklung, Validierung und späteren
Integration festgelegt. Dazu gehören unter anderem die Bereinigung der Daten, die Aufteilung
in Trainings- und Testdaten sowie die Definition geeigneter Bewertungskennzahlen zur
Beurteilung der Modellgüte. Zudem ist zu klären, ob besondere Anforderungen an das System
bestehen, beispielsweise hinsichtlich Robustheit, Skalierbarkeit oder Erklärbarkeit. Je nach
Anwendungsfall sind sowohl Modelle mit binärer Entscheidung als auch score-basierte
Ansätze denkbar, bei denen der Nutzer Schwellenwerte für die Meldungen von
Unregelmäßigkeiten festlegen kann.
In der Umsetzungsphase wird das Modell mit den vorhandenen Transaktionsdaten trainiert
und anschließend anhand von Testdaten evaluiert, um seine praktische Anwendbarkeit zu
überprüfen. Dabei wird insbesondere darauf geachtet, möglichst viele auffällige
Transaktionen korrekt zu identifizieren und gleichzeitig Fehlalarme zu minimieren. Da der
Auftraggeber ein besonderes Augenmerk auf die Vermeidung falsch-positiver Ergebnisse legt,
muss die Wahl geeigneter Metriken entsprechend abgestimmt werden. Neben der
methodischen Bewertung, beispielsweise anhand von Genauigkeit, Precision, Recall oder
F1-Score, erfolgt ergänzend eine fachliche Bewertung der Ergebnisse in Zusammenarbeit mit
Domänenexperten.
Abschließend entsteht ein Analyseergebnis in Form eines trainierten und evaluierten Modells,
das als Artefakt dieser Phase dient. Die Durchführung und Bewertung der Analyse erfolgt
primär durch Data Scientists. Die Phase ist für den Zeitraum vom 19.05.2026 bis zum
15.06.2026 geplant
Nutzbarmachung
In der Phase Nutzbarmachung werden die in der Analyse entwickelten Analysemodelle in
eine Form überführt, in der sie in der Domäne angewendet werden können. Ziel ist es, die
Analyseergebnisse so aufzubereiten, dass sie im praktischen Einsatz nutzbar sind.
Im vorliegenden Projekt kann dies beispielsweise die Implementierung von Funktionen
umfassen, die eine Echtzeitanwendung des Modells an Selbstbedienungskassen ermöglichen,
um nicht gescannte Artikel zu erkennen.
Anschließend erfolgt eine technische, methodische und fachliche Prüfung der entwickelten
Lösung. Es wird überprüft, ob die technischen Voraussetzungen für einen Einsatz,
beispielsweise hinsichtlich Rechenleistung und Systemintegration an den
Selbstbedienungskassen gegeben sind. Zudem wird bewertet, ob das gewählte
Modellverfahren methodisch geeignet ist und die Anforderungen des Anwendungsfalls erfüllt.
Eine fachliche Prüfung erfolgt in Zusammenarbeit mit Domänenexperten, um die praktische
Relevanz der Ergebnisse sicherzustellen. Zusätzlich ist zu klären, wie das Modell im
operativen Einsatz verwendet wird, wie eine effiziente Nutzung sichergestellt werden kann
und in welchen Abständen eine erneute Evaluation erforderlich ist.
Als Ergebnis der Phase entstehen Analyseartefakte in Form eines nutzbaren Modells, welches
über eine REST-API den Auftraggebern zur Verfügung gestellt wird, einer Beschreibung des
zugrundeliegenden Verfahrens, sowie der notwendigen Systemkomponenten für den Einsatz.
Dabei könnten exemplarisch über eine JSON-Datei Informationen für das Ladenpersonal
übermittelt werden. Die Phase beginnt am 15.06.2026 und endet am 15.07.2026.
Ausblick: Nutzung
Die nachfolgend beschriebene Nutzungsphase ist ein Ausblick auf eine mögliche Verwendung
der entwickelten Analyseartefakte nach Abschluss des Projekts.
In der Nutzungsphase werden die entwickelten Analyseartefakte in der Domäne eingesetzt.
Dies bedeutet im vorliegenden Projekt, dass die Modelle an den Selbstbedienungskassen
integriert werden und zur Unterstützung von Echtzeitentscheidungen genutzt werden können.
Beispielsweise können Auffälligkeiten im Scanverhalten erkannt und entsprechende Hinweise
für das Personal, etwa Ladendetektive, bereitgestellt werden.
Während des Einsatzes wird das Modell kontinuierlich überwacht, um Veränderungen in der
Modellleistung frühzeitig zu erkennen. Eine Abnahme der Genauigkeit kann beispielsweise
durch neue Artikel im Sortiment oder verändertes Kundenverhalten entstehen. In solchen
Fällen muss das Modell angepasst oder neu trainiert werden.
Anschließend werden die Erkenntnisse aus Entwicklung und operativem Einsatz systematisch
gesammelt und ausgewertet. Diese dienen als Grundlage für die Weiterentwicklung des
Modells sowie für mögliche zukünftige Projekte. Die Nutzungsphase beginnt nach Abschluss
des Projektes.
Risiken und Einschränkungen
Zum aktuellen Zeitpunkt bestehen mehrere Risiken und Einschränkungen, die den
Projektverlauf sowie die Aussagekraft der Ergebnisse beeinflussen können.
Ein zentrales methodisches Risiko liegt in der begrenzten und potenziell verzerrten
Datenbasis. Verlässliche Zielwerte liegen nur für solche Vorgänge vor, die im Rahmen
historischer Stichprobenkontrollen überprüft wurden. Dadurch kann eine selektive Verzerrung
entstehen. Gleichzeitig stehen bislang nur wenige Tabellen zur Verfügung, sodass sich
Merkmale nur aus einer eingeschränkten Datenbasis ableiten lassen. Betrugsfälle ohne
erkennbare Auffälligkeiten in den Transaktionsdaten können daher möglicherweise nicht
zuverlässig identifiziert werden.
Eng damit verbunden ist die Unsicherheit hinsichtlich der Datenqualität und -konsistenz. Vor
einer vertieften Analyse ist noch nicht abschließend geklärt, wie belastbar, vollständig und
fachlich eindeutig die bereitgestellten Label und Merkmale sind. Insbesondere das in der
Tabelle transactions enthaltene Label ist entscheidend für das Training des Modells.
Fehlerhafte, unvollständige oder uneinheitliche Klassifizierungen können die Modellleistung
erheblich beeinträchtigen und zu falschen Vorhersagen führen.
Ein weiteres Risiko ergibt sich aus der unausgewogenen Klassenverteilung sowie möglichen
Unterschieden zwischen Filialen. Wenn auffällige oder fehlerhafte Vorgänge nur in geringer
Zahl oder nicht repräsentativ im Datensatz enthalten sind, erschwert dies sowohl die
Modellierung als auch die Übertragbarkeit der Ergebnisse.
Zusätzliche Unsicherheiten betreffen die Verfügbarkeit und Nutzbarkeit ergänzender
Datenquellen. Der potenzielle Einbezug von Kameradaten ist derzeit noch ungeklärt – sowohl
in technischer Hinsicht als auch bezüglich fachlicher Verknüpfbarkeit und
datenschutzrechtlicher Zulässigkeit. Generell führt das Fehlen weiterer Kontextinformationen
(zum Beispiel aus Kamerasystemen, Gewichtssensoren oder detaillierten Scanprotokollen)
dazu, dass die Analyse ausschließlich auf aggregierten Transaktionsdaten basiert, was die
Genauigkeit der Erkennung einschränken kann.
Auch in der praktischen Umsetzung ergeben sich Herausforderungen. Die Integration einer
REST-API in bestehende Kassensysteme erfordert eine stabile technische Infrastruktur sowie
ausreichende Performance, um Anfragen in Echtzeit verarbeiten zu können. Verzögerungen
oder Systemausfälle könnten den laufenden Betrieb beeinträchtigen.
Schließlich sind datenschutzrechtliche und organisatorische Aspekte zu berücksichtigen.
Auch wenn keine direkten personenbezogenen Daten verarbeitet werden, kann die Analyse
von Transaktionsmustern sensibel sein und erfordert einen verantwortungsvollen Umgang mit
den Daten.
Offene Punkte
Es bestehen noch offene Punkte, die im weiteren Projektverlauf zu klären sind. Hierzu zählen
insbesondere die genaue fachliche Bedeutung und Ausprägung der Zielvariable sowie die
Frage, wie repräsentativ die vorhandenen Stichprobenkontrollen für den späteren
Anwendungsfall sind.
Ein weiterer Themenblock betrifft die Vollständigkeit und Struktur der bereitgestellten
Trainings- und Testdaten sowie die fachliche Einordnung der vorhandenen Daten. Darüber
hinaus ist zu prüfen, ob Kameradaten in technisch, fachlich und datenschutzrechtlich
sinnvoller Weise einbezogen werden können.
Ebenfalls noch fachlich zu klären ist, zu welchem Zeitpunkt im Prozess die Vorhersage
vorliegen soll, wie der resultierende Risikoscore im operativen Ablauf für Nachkontrollen
genutzt werden kann und anhand welcher Schwellenwerte oder Entscheidungsregeln
kontrollwürdige Vorgänge abgegrenzt beziehungsweise priorisiert werden sollen.
Schließlich ist zu konkretisieren, wie der Umfang der REST-API auszugestalten ist und
welche Ein- und Ausgaben hierfür zugrunde gelegt werden sollen.
