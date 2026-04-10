**Titel & Team**

- **Projekt:** Self-Checkout — Erkennung fehlerhafter / betrügerischer Scans
- **Team:** Mamadou Diallo, Ben Luca Kröncke, Marius Schneider, Ronja Thum
- **Betreuung (Uni):** Sabine Folz-Weinstein, Prof. Dr. Christian Beecks
- **Auftraggeber:** Einzelhandelskette (Kursbetreuung)

**Kurzfassung**: Ziel ist ein datengetriebenes System zur Priorisierung verdächtiger Self-Checkout-Transaktionen, sodass Nachkontrollen effizient erfolgen und Kosten sowie Kundenbelastung minimiert werden.

**Kontext & Abgleich mit Auftraggeber**

- Ausgangslage: Self-Checkout im Lebensmitteleinzelhandel; fehlerhafte Scans (~5% laut Kickoff).
- Erwartetes Ergebnis vom Auftraggeber: Modell/Code + Datenexploration + Interpretation + Empfehlungen.
- Technische Bereitstellung: Parquet-Dateien, REST-API; Zugang wurde angekündigt (siehe Kickoff-Text).

**Ausgangslage: Daten und Domäne**

- Quellen: `products`, `stores`, `transactions`, `transaction_lines` (Parquet / DuckDB / ggf. REST API).
- Beobachtete Kennzahlen (Voranalysen):
  - ~1.86 Mio. Transaktionen
  - ~20.09 Mio. transaction_lines
  - ~23.9k Produkte
  - 50 Filialen
  - 11.453 transaction_lines ohne `product_id`
  - Duplikate von (`transaction_id`, `product_id`) vorhanden
  - Labelverteilung (`fraud_flag`): `1` ≈ 7.726, `0` ≈ 178.359, `-1` ≈ 1.678.031 (stark unausgewogen)

**Problemstellung & Ziele**

- Problem: Nicht alle Artikel werden korrekt erfasst (Absicht, Versehen, Technik).
- Business-Ziel: Maximale Erkennung fehlerhafter Scans bei minimaler Kontroll-/Kostenquote.
- Wissenschaftlich/technisch: Erarbeitung einer robusten Pipeline, Evaluation auf realistischen Kontrollraten.

**Vorgehen / Methoden (High-Level)**

- Datenaufbau & Qualitätssicherung: Ursachen fehlender `product_id` klären; Duplikate prüfen/aggregieren.
- Feature-Engineering: Warenkorb-Aggregate, zeitliche & filialspezifische Features, Produktkategorien, kamerabasierte Indikatoren (falls nutzbar).
- Modellierung: Probabilistische Klassifizierung / Rangierung (z. B. XGBoost/LightGBM, Calibrated Scores) oder Anomaly-Detection; Umgang mit Klassenungleichgewicht (Sampling, Gewichtung, AUPRC-Optimierung).
- Evaluation: Precision@k, Recall bei gegebener Kontrollrate, AUPRC, Kostenmatrix-basiertes Scoring.

**Detaillierter Plan & Meilensteine**

- Bis 20./22.04.2026: Einreichen der Projektskizze (DASC‑PM).
- Laufende Phasen (DASC‑PM): Daten, Analyse, Modellierung, Evaluation, Interpretation.
- Finale Abgabe / Präsentation: ca. 15.07.2026.

**Risiken, Annahmen & Einschränkungen**

- Risiko: sehr unbalancierte Labels → Bias bei klassischen Metriken.
- Annahme: Kameradaten sind ergänzend und nicht vollständig zuverlässig.
- Einschränkung: Fehlende `product_id`-Zeilen müssen entschieden werden (Imputation vs. Ausschluss).

**Aufgaben, Verantwortlichkeiten & Aufwandsschätzung**

- Datenbereinigung & EDA (Team: alle) — 1–2 Wochen
- Feature-Pipeline & Aggregation (Team: Person A/B) — 2 Wochen
- Modelltraining & Hyperparameter (Team: Person C) — 2 Wochen
- Evaluation, Interpretation, Report & Präsentation (Team: alle) — 2 Wochen

**Offene Fragen an den Auftraggeber**

- Welches Kostenmodell/Constraint gilt für eine Kontrolle (z. B. max. Kontrollen pro 1.000 Transaktionen)?
- Sind Kameradaten vollständig und in welchem Format werden sie geliefert?
- Detail zu Labelherkunft: Wie sind `-1` (unbekannt) entstanden — verwerfen oder semi-supervised nutzen?

**Anhänge / Referenzen**

- Kickoff-Notizen: [01_admin/ppra_ss26_kickoff.txt](01_admin/ppra_ss26_kickoff.txt)
- Voranalyse-SQL: [05_analyse/analyse.sql](05_analyse/analyse.sql)
- Notebook mit Lade-Snippets: [main.ipynb](main.ipynb)

---

Diese Projektskizze ist ein Startdokument — ich kann sie gern weiter ausformulieren, auf Französisch übersetzen oder als PDF/Word exportieren.
