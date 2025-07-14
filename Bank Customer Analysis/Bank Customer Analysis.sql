#FASE DESCRITTIVA
SHOW DATABASES LIKE '%banca%';
USE banca;
SHOW TABLES;
DESCRIBE cliente;
DESCRIBE conto;
DESCRIBE tipo_conto;
DESCRIBE tipo_transazione;
DESCRIBE transazioni;
SELECT COUNT(*) FROM cliente;
SELECT COUNT(*) FROM conto;
SELECT COUNT(*) FROM tipo_conto;
SELECT COUNT(*) FROM tipo_transazione;
SELECT COUNT(*) FROM transazioni;
SELECT * FROM cliente LIMIT 10;
SELECT * FROM cliente GROUP BY id_cliente, nome, cognome, data_nascita HAVING COUNT(*) > 1;
SELECT * FROM conto LIMIT 10;
SELECT * FROM conto GROUP BY id_conto, id_cliente, id_tipo_conto HAVING COUNT(*) > 1;
SELECT * FROM tipo_conto;
SELECT * FROM tipo_transazione;
SELECT * FROM transazioni LIMIT 10;
SELECT * FROM transazioni GROUP BY data, id_tipo_trans, importo, id_conto HAVING COUNT(*) > 1;

#CREAZIONE TABELLA
CREATE TABLE ID_Cliente(
id_cliente INT PRIMARY KEY,
età INT
);
INSERT INTO ID_Cliente (id_cliente, età)
SELECT id_cliente, TIMESTAMPDIFF(YEAR, data_nascita, CURDATE())
FROM cliente;

#NUMERO TOTALE DI CONTI POSSEDUTI
SET sql_safe_updates = 0;
ALTER TABLE ID_Cliente
ADD COLUMN totale_conti INT DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT cli.id_cliente, 
		COUNT(con.id_conto) AS totale_conti
	FROM cliente cli
	LEFT JOIN conto con
	ON cli.id_cliente = con.id_cliente
	GROUP BY cli.id_cliente
) AS sub ON id.id_cliente = sub.id_cliente
SET id.totale_conti = COALESCE(sub.totale_conti, 0);
SELECT * FROM ID_Cliente;

#NUMERO DI CONTI POSSEDUTI PER TIPOLOGIA
SELECT * FROM tipo_conto;
ALTER TABLE ID_Cliente
ADD COLUMN conto_base INT DEFAULT 0,
ADD COLUMN conto_business INT DEFAULT 0,
ADD COLUMN conto_privati INT DEFAULT 0,
ADD COLUMN conto_famiglie INT DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		SUM(CASE WHEN con.id_tipo_conto = 0 THEN 1 ELSE 0 END) AS conto_base,
		SUM(CASE WHEN con.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS conto_business,
		SUM(CASE WHEN con.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS conto_privati,
		SUM(CASE WHEN con.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS conto_famiglie
	FROM conto con
	GROUP BY con.id_cliente
) AS sub ON id.id_cliente = sub.id_cliente
SET id.conto_base = COALESCE(sub.conto_base, 0),
	id.conto_business = COALESCE(sub.conto_business, 0),
	id.conto_privati = COALESCE(sub.conto_privati, 0),
	id.conto_famiglie = COALESCE(sub.conto_famiglie, 0);
SELECT * FROM ID_Cliente LIMIT 10;

#NUMERO DI TRANSAZIONI IN USCITA
SELECT * FROM tipo_transazione;
SELECT * FROM transazioni LIMIT 10;
ALTER TABLE ID_Cliente
ADD COLUMN tot_transazioni_uscita INT DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		COUNT(*) AS tot_transazioni_uscita
	FROM transazioni trans
    INNER JOIN conto con ON trans.id_conto = con.id_conto
    INNER JOIN tipo_transazione tipotrans ON trans.id_tipo_trans = tipotrans.id_tipo_transazione
    WHERE tipotrans.segno = '-'
    GROUP BY con.id_cliente
) AS sub ON id.id_cliente = sub.id_cliente
SET id.tot_transazioni_uscita = COALESCE(sub.tot_transazioni_uscita, 0);
SELECT * FROM ID_Cliente LIMIT 10;

#NUMERO DI TRANSAZIONI IN ENTRATA
ALTER TABLE ID_Cliente
ADD COLUMN tot_transazioni_entrata INT DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		COUNT(*) AS tot_transazioni_entrata
	FROM transazioni trans
    INNER JOIN conto con ON trans.id_conto = con.id_conto
    INNER JOIN tipo_transazione tipotrans ON trans.id_tipo_trans = tipotrans.id_tipo_transazione
    WHERE tipotrans.segno = '+'
    GROUP BY con.id_cliente
) AS sub ON id.id_cliente = sub.id_cliente
SET id.tot_transazioni_entrata = COALESCE(sub.tot_transazioni_entrata, 0);
SELECT * FROM ID_Cliente LIMIT 10;

#IMPORTO TOTALE TRANSATO IN USCITA
ALTER TABLE ID_Cliente
MODIFY COLUMN tot_importo_uscita DECIMAL(20,14) DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		SUM(trans.importo) AS tot_importo_uscita
	FROM transazioni trans
    INNER JOIN conto con ON trans.id_conto = con.id_conto
    INNER JOIN tipo_transazione tipotrans ON trans.id_tipo_trans = tipotrans.id_tipo_transazione
    WHERE tipotrans.segno = '-'
    GROUP BY con.id_cliente
) AS sub ON id.id_cliente = sub.id_cliente
SET id.tot_importo_uscita = COALESCE(sub.tot_importo_uscita, 0);
SELECT * FROM ID_Cliente LIMIT 10;

#IMPORTO TOTALE TRANSATO IN ENTRATA
ALTER TABLE ID_Cliente
ADD COLUMN tot_importo_entrata DECIMAL(20,14) DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		SUM(trans.importo) AS tot_importo_entrata
	FROM transazioni trans
    INNER JOIN conto con ON trans.id_conto = con.id_conto
    INNER JOIN tipo_transazione tipotrans ON trans.id_tipo_trans = tipotrans.id_tipo_transazione
    WHERE tipotrans.segno = '+'
    GROUP BY con.id_cliente
) AS sub ON id.id_cliente = sub.id_cliente
SET id.tot_importo_entrata = COALESCE(sub.tot_importo_entrata, 0);
SELECT * FROM ID_Cliente LIMIT 10;

#NUMERO DI TRANSAZIONI IN USCITA PER TIPOLOGIA DI CONTO
ALTER TABLE ID_Cliente
MODIFY COLUMN conto_base_uscite INT DEFAULT 0,
MODIFY COLUMN conto_business_uscite INT DEFAULT 0,
MODIFY COLUMN conto_privati_uscite INT DEFAULT 0,
MODIFY COLUMN conto_famiglie_uscite INT DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		SUM(CASE WHEN con.id_tipo_conto = 0 THEN 1 ELSE 0 END) AS conto_base_uscite,
        SUM(CASE WHEN con.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS conto_business_uscite,
        SUM(CASE WHEN con.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS conto_privati_uscite,
        SUM(CASE WHEN con.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS conto_famiglie_uscite
	FROM transazioni trans
    INNER JOIN conto con ON trans.id_conto = con.id_conto
    INNER JOIN tipo_transazione tipotrans ON trans.id_tipo_trans = tipotrans.id_tipo_transazione
    WHERE tipotrans.segno = '-'
    GROUP BY con.id_cliente, con.id_tipo_conto
    ORDER BY con.id_cliente, con.id_tipo_conto
) AS sub ON id.id_cliente = sub.id_cliente
SET id.conto_base_uscite = COALESCE(sub.conto_base_uscite, 0),
	id.conto_business_uscite = COALESCE(sub.conto_business_uscite, 0),
    id.conto_privati_uscite = COALESCE(sub.conto_privati_uscite, 0),
    id.conto_famiglie_uscite = COALESCE(sub.conto_famiglie_uscite, 0);
SELECT * FROM ID_Cliente LIMIT 10;

#NUMERO DI TRANSAZIONI IN ENTRATA PER TIPOLOGIA DI CONTO
ALTER TABLE ID_Cliente
ADD COLUMN conto_base_entrate INT DEFAULT 0,
ADD COLUMN conto_business_entrate INT DEFAULT 0,
ADD COLUMN conto_privati_entrate INT DEFAULT 0,
ADD COLUMN conto_famiglie_entrate INT DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		SUM(CASE WHEN con.id_tipo_conto = 0 THEN 1 ELSE 0 END) AS conto_base_entrate,
        SUM(CASE WHEN con.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS conto_business_entrate,
        SUM(CASE WHEN con.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS conto_privati_entrate,
        SUM(CASE WHEN con.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS conto_famiglie_entrate
	FROM transazioni trans
    INNER JOIN conto con ON trans.id_conto = con.id_conto
    INNER JOIN tipo_transazione tipotrans ON trans.id_tipo_trans = tipotrans.id_tipo_transazione
    WHERE tipotrans.segno = '+'
    GROUP BY con.id_cliente, con.id_tipo_conto
    ORDER BY con.id_cliente, con.id_tipo_conto
) AS sub ON id.id_cliente = sub.id_cliente
SET id.conto_base_entrate = COALESCE(sub.conto_base_entrate, 0),
	id.conto_business_entrate = COALESCE(sub.conto_business_entrate, 0),
    id.conto_privati_entrate = COALESCE(sub.conto_privati_entrate, 0),
    id.conto_famiglie_entrate = COALESCE(sub.conto_famiglie_entrate, 0);
SELECT * FROM ID_Cliente LIMIT 10;

#IMPORTO TOTALE TRANSATO IN USCITA PER TIPOLOGIA DI CONTO
ALTER TABLE ID_Cliente
ADD COLUMN importo_base_uscite DECIMAL(20,14) DEFAULT 0,
ADD COLUMN importo_business_uscite DECIMAL(20,14) DEFAULT 0,
ADD COLUMN importo_privati_uscite DECIMAL(20,14) DEFAULT 0,
ADD COLUMN importo_famiglie_uscite DECIMAL(20,14) DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		SUM(CASE WHEN con.id_tipo_conto = 0 THEN trans.importo ELSE 0 END) AS importo_base_uscite,
        SUM(CASE WHEN con.id_tipo_conto = 1 THEN trans.importo ELSE 0 END) AS importo_business_uscite,
        SUM(CASE WHEN con.id_tipo_conto = 2 THEN trans.importo ELSE 0 END) AS importo_privati_uscite,
        SUM(CASE WHEN con.id_tipo_conto = 3 THEN trans.importo ELSE 0 END) AS importo_famiglie_uscite
	FROM transazioni trans
    INNER JOIN conto con ON trans.id_conto = con.id_conto
    INNER JOIN tipo_transazione tipotrans ON trans.id_tipo_trans = tipotrans.id_tipo_transazione
    WHERE tipotrans.segno = '-'
    GROUP BY con.id_cliente, con.id_tipo_conto
    ORDER BY con.id_cliente, con.id_tipo_conto
) AS sub ON id.id_cliente = sub.id_cliente
SET id.importo_base_uscite = COALESCE(sub.importo_base_uscite, 0),
	id.importo_business_uscite = COALESCE(sub.importo_business_uscite, 0),
    id.importo_privati_uscite = COALESCE(sub.importo_privati_uscite, 0),
    id.importo_famiglie_uscite = COALESCE(sub.importo_famiglie_uscite, 0);
SELECT * FROM ID_Cliente LIMIT 10;

#IMPORTO TOTALE TRANSATO IN ENTRATA PER TIPOLOGIA DI CONTO
ALTER TABLE ID_Cliente
ADD COLUMN importo_base_entrate DECIMAL(20,14) DEFAULT 0,
ADD COLUMN importo_business_entrate DECIMAL(20,14) DEFAULT 0,
ADD COLUMN importo_privati_entrate DECIMAL(20,14) DEFAULT 0,
ADD COLUMN importo_famiglie_entrate DECIMAL(20,14) DEFAULT 0;
UPDATE ID_Cliente id
LEFT JOIN (
	SELECT con.id_cliente,
		SUM(CASE WHEN con.id_tipo_conto = 0 THEN trans.importo ELSE 0 END) AS importo_base_entrate,
        SUM(CASE WHEN con.id_tipo_conto = 1 THEN trans.importo ELSE 0 END) AS importo_business_entrate,
        SUM(CASE WHEN con.id_tipo_conto = 2 THEN trans.importo ELSE 0 END) AS importo_privati_entrate,
        SUM(CASE WHEN con.id_tipo_conto = 3 THEN trans.importo ELSE 0 END) AS importo_famiglie_entrate
	FROM transazioni trans
    INNER JOIN conto con ON trans.id_conto = con.id_conto
    INNER JOIN tipo_transazione tipotrans ON trans.id_tipo_trans = tipotrans.id_tipo_transazione
    WHERE tipotrans.segno = '+'
    GROUP BY con.id_cliente, con.id_tipo_conto
    ORDER BY con.id_cliente, con.id_tipo_conto
) AS sub ON id.id_cliente = sub.id_cliente
SET id.importo_base_entrate = COALESCE(sub.importo_base_entrate, 0),
	id.importo_business_entrate = COALESCE(sub.importo_business_entrate, 0),
    id.importo_privati_entrate = COALESCE(sub.importo_privati_entrate, 0),
    id.importo_famiglie_entrate = COALESCE(sub.importo_famiglie_entrate, 0);
    
SELECT * FROM ID_Cliente;
