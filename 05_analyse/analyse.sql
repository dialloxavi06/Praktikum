-- 1. Vérifier le volume des données
SELECT COUNT(*) AS total_transactions FROM transactions;
┌────────────────────┐
│ total_transactions │
│       int64        │
├────────────────────┤
│      1864116       │
│   (1.86 million)   │

SELECT COUNT(*) AS total_products FROM products;

┌────────────────┐
│ total_products │
│     int64      │
├────────────────┤
│          23896 │
└────────────────┘
SELECT COUNT(*) AS total_transaction_lines FROM transaction_lines;
┌─────────────────────────┐
│ total_transaction_lines │
│          int64          │
├─────────────────────────┤
│        20092938         │
│     (20.09 million)     │
└─────────────────────────┘
SELECT COUNT(*) AS total_stores FROM stores;
┌──────────────┐
│ total_stores │
│    int64     │
├──────────────┤
│           50 │
└──────────────┘

-- 2. Vérifier les valeurs manquantes dans transaction_lines
 SELECT 
        COUNT(*) AS total,
        COUNT(product_id) AS product_id_not_null
    FROM transaction_lines;

    ┌─────────────────┬─────────────────────┐
│      total      │ product_id_not_null │
│      int64      │        int64        │
├─────────────────┼─────────────────────┤
│    20092938     │      20081485       │
│ (20.09 million) │   (20.08 million)   │
└─────────────────┴─────────────────────┘
-- il ya ici 20.09 - 20.08 = 11453 lignes avec des product_id null, ce qui est un problème pour l'analyse des produits achetés

-- 3. Vérifier les doublons(doublons et achats multiples du même produit dans une même transaction)
SELECT transaction_id, product_id, COUNT(*) 
FROM transaction_lines
GROUP BY transaction_id, product_id
HAVING COUNT(*) > 1
LIMIT 10;

┌──────────────────────────────────────┬──────────────────────────────────────┬──────────────┐
│            transaction_id            │              product_id              │ count_star() │
│                 uuid                 │                 uuid                 │    int64     │
├──────────────────────────────────────┼──────────────────────────────────────┼──────────────┤
│ 8dd6f7a9-3dbf-42de-96ae-c270c4e567e4 │ 441d16a7-cf67-46d1-9205-d530cebd5c26 │            2 │
│ 75af9dc8-009d-4fb5-8849-408eaf9a6281 │ 78b22ace-e60e-46f7-abb2-6cfa52880679 │            2 │
│ 27f547fa-ebe0-4083-b83c-5abdf3fead88 │ 42a31106-7674-494f-9c30-ba3601b02677 │            2 │
│ 0ec2f5be-faad-4529-bf9e-5968caa2e5c9 │ 182a527f-7632-47ce-b057-bb9c77583d82 │            2 │
│ a00d1fc1-1126-4d11-af57-0c45666f9ef5 │ 88c4316e-0f04-458f-8d3e-e2ffa877f678 │            2 │
│ a4b78be5-5b6e-4143-86c3-f0f76fbb1514 │ 73626631-5de7-4f87-b82f-4dca0462da65 │            2 │
│ 8bc227f5-0ceb-4c2f-82bf-267a3bedc491 │ 18e94cd0-8531-43de-ac62-5528bb25e3d2 │            2 │
│ 60eb5388-fed4-4672-ac0a-f8eebf599ece │ d58950a7-8056-4f7d-802b-ebedce617534 │            2 │
│ 384d06bf-8c0b-4b03-806d-fb03dc8178c0 │ ce562764-d96c-47a8-b26c-cf872157375b │            2 │

└──────────────────────────────────────┴──────────────────────────────────────┴──────────────┘


-- 4. Distribution simple (important 🔥) comparaisons entre lignes vs transactions
SELECT COUNT(*) 
FROM transaction_lines;

┌─────────────────┐
│  count_star()   │
│      int64      │
├─────────────────┤
│    20092938     │
│ (20.09 million) │
└─────────────────┘
--et 
SELECT COUNT(DISTINCT transaction_id) 
FROM transaction_lines;

┌────────────────────────────────┐
│ count(DISTINCT transaction_id) │
│             int64              │
├────────────────────────────────┤
│            1864084             │
│         (1.86 million)         │
└────────────────────────────────┘

-- 5. Vérifier les relations (cohérence des données)D SELECT COUNT(*)
       FROM transaction_lines tl
       LEFT JOIN products p ON tl.product_id = p.id
       WHERE p.id IS NULL;
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│        11453 │
└──────────────┘
-- 6. Déséquilibre des données

SELECT label, COUNT(*) 
FROM transactions
GROUP BY label
ORDER BY COUNT(*) DESC;

│ label │ count_star() │
│ int64 │    int64     │
├───────┼──────────────┤
│    -1 │      1678031 │
│     0 │       178359 │
│     1 │         7726 │
└───────┴──────────────┘
--🟦 Umgang mit Labels
1 = Betrug
0 = kein Betrug
-1 = unbekannt