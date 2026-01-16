CREATE DATABASE library_realisation;
USE library_realisation;

-- =====================
-- TABLE RAYON
-- =====================
CREATE TABLE rayon (
    rayon_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    CONSTRAINT unq_nom_rayon CHECK (nom IN ('Littérature','Science','Histoire','Art','Informatique','Philosophie','Biologie','Mathématiques','Géographie','Musique'))
);

-- =====================
-- TABLE AUTEUR
-- =====================
CREATE TABLE auteur (
    auteur_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL
);

-- =====================
-- TABLE LECTEUR
-- =====================
CREATE TABLE lecteur (
    lecteur_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    tel VARCHAR(15) NOT NULL UNIQUE,
    cin VARCHAR(8) NOT NULL UNIQUE,
    CONSTRAINT check_phone_number CHECK(CHAR_LENGTH(tel) >= 10) 
);

-- =====================
-- TABLE OUVRAGE
-- =====================
CREATE TABLE ouvrage (
    ouvrage_id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    annee_publication YEAR NOT NULL,
    rayon_id INT NOT NULL,
    FOREIGN KEY (rayon_id) REFERENCES rayon(rayon_id),
    CONSTRAINT unq_ouvrage UNIQUE (ouvrage_id,annee_publication),
    CONSTRAINT validation_date_pub CHECK  (annee_publication >=1900 AND annee_publication <= YEAR(CURRENT_DATE()))
);

-- =====================
-- TABLE ASSOCIATION OUVRAGE / AUTEUR
-- =====================
CREATE TABLE ouvrage_auteur (
    ouvrage_id INT,
    auteur_id INT,
    PRIMARY KEY (ouvrage_id, auteur_id),
    FOREIGN KEY (ouvrage_id) REFERENCES ouvrage(ouvrage_id),
    FOREIGN KEY (auteur_id) REFERENCES auteur(auteur_id),
    CONSTRAINT unq_ouvrage_auteur UNIQUE (ouvrage_id,auteur_id)
    
);

-- =====================
-- TABLE EMPRUNT
-- =====================
CREATE TABLE emprunt (
    emprunt_id INT AUTO_INCREMENT PRIMARY KEY,
    date_emprunt DATE NOT NULL DEFAULT CURRENT_DATE,
    date_retour_prevue DATE NOT NULL,
    date_retour_effective DATE NULL,
    lecteur_id INT NOT NULL,
    ouvrage_id INT NOT NULL,
    FOREIGN KEY (lecteur_id) REFERENCES lecteur(lecteur_id),
    FOREIGN KEY (ouvrage_id) REFERENCES ouvrage(ouvrage_id),
    CONSTRAINT check_date_emprunt CHECK (date_emprunt <= CURRENT_DATE()),
    CONSTRAINT check_date_retour_effective CHECK ( DATEDIFF(date_retour_prevue, date_emprunt) <= 30)
);

-- =====================
-- TABLE PERSONNEL
-- =====================
CREATE TABLE personnel (
    personnel_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cin VARCHAR(8) NOT NULL UNIQUE,
    tel VARCHAR(15) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    chef_id INT NULL,
    FOREIGN KEY (chef_id) REFERENCES personnel(personnel_id)
);

-- trigger de emprunt de plus de 3 livre----------------------------------------
DELIMITER $$
CREATE TRIGGER plus_3lecteur_empruntee
BEFORE INSERT ON emprunt
FOR EACH ROW
BEGIN 
DECLARE number_emprunt INT;
-- pour calculer le nombre demprunt en cour

SELECT COUNT(*)
INTO number_emprunt
FROM emprunt
WHERE lecteur.lecteur_id = NEW.lecteur_id
AND emprunt.date_retour_effective IS NULL;
-- check condition

IF number_emprunt>=3 THEN 
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT ='you have already 3 loaned books ';
END IF;
END$$

DELIMITER ;




-- interdire l’emprunt d’un ouvrage déjà emprunté et non retourné


DELIMITER $$
CREATE TRIGGER check_returned_book
BEFORE INSERT ON emprunt
FOR EACH ROW
BEGIN
IF EXISTS(
SELECT 1 FROM emprunt
WHERE ouvrage_id=NEW.ouvrage_id
AND emprunt.date_retour_effective IS NULL	
)
THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='the book is not allowed to loan due to no return status!!!';
END IF;
    
END$$

DELIMITER ;



-- vérifier lors de la mise à jour que la date de retour effective est supérieure ou égale à la date d’emprunt


DELIMITER $$
CREATE TRIGGER verifie_date_retour
AFTER UPDATE ON emprunt
FOR EACH ROW
BEGIN
IF NEW.date_retour_effective<NEW.date_emprunt THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT=' la date de retour effective ne dois pas etre moins de la date d emprunt ';
END IF;
END$$

DELIMITER ;


--interdire la suppression d’un ouvrage qui est actuellement emprunté


DELIMITER $$
CREATE TRIGGER verifing_before_deleting
BEFORE DELETE ON emprunt
FOR EACH ROW
BEGIN 

IF old.date_retour_effective is null	

THEN 
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='the book is already loaned!!! you cant delete it ';
END IF;
END$$


DELIMITER ;


--bloquer la suppression d’un ouvrage lié à un historique d’emprunts

DELIMITER $$

CREATE TRIGGER block_delete_ouvrage
BEFORE DELETE ON ouvrage
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM emprunt
        WHERE ouvrage_id = OLD.ouvrage_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de supprimer cet ouvrage : il est lié à un historique d’emprunts';
    END IF;
END$$

DELIMITER ;


---Top 5 des ouvrages les plus empruntés

SELECT ouvrage_id,COUNT(*) AS nb_emprunt
FROM emprunt
GROUP BY ouvrage_id;

--Liste des lecteurs « fidèles » (ayant effectué plus de 3 emprunts)


SELECT lecteur_id,COUNT(*) AS nb_emprunt
FROM emprunt
GROUP BY lecteur_id
HAVING nb_emprunt>3;

--Rayons populaires classés par nombre d’emprunts


SELECT rayon_id  ,COUNT(*) AS nb_rayon_parbook
FROM emprunt
JOIN ouvrage ON ouvrage.ouvrage_id=emprunt.ouvrage_id

GROUP BY rayon_id;

-- Durée moyenne d’emprunt des ouvrages retournés


SELECT AVG(DATEDIFF(date_retour_effective,date_emprunt)) AS avg_of_emprunt
FROM emprunt
WHERE date_retour_effective IS NOT null;
--  Taux de retard global : nombre d’emprunts en retard / nombre total d’emprunts

SELECT COUNT(*)/ (SELECT COUNT(*) FROM emprunt) AS taux_de_retard
FROM emprunt
WHERE date_retour_effective is null  AND date_retour_prevue < CURDATE()
;

--Nombre d’ouvrages empruntés par mois

SELECT
YEAR(date_emprunt) AS annee,
MONTH(date_emprunt) AS mois,
COUNT(*) AS nb_ouvrage_emprunter
FROM emprunt
GROUP BY YEAR(date_emprunt),MONTH(date_emprunt)
ORDER BY annee,mois;

--Auteur dont les ouvrages sont les plus demandés


SELECT o.auteur_id,a.nom,count(*) AS nb_of_ouvrage
FROM ouvrage_auteur o
JOIN auteur a ON a.auteur_id= o.auteur_id
JOIN emprunt e ON e.ouvrage_id=o.ouvrage_id
GROUP BY o.auteur_id,a.nom
ORDER BY nb_of_ouvrage DESC
LIMIT 1;