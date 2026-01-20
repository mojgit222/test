/* ============================================================
   BAZE PODATAKA II – KOMPLETNO RJEŠENJE
   Baza: AdventureWorks2017
   Autor: (upiši ime / indeks)
   ============================================================ */


/* ============================================================
   1. TEORIJA
   ============================================================ */

-- 1.
-- DDL, DML i DCL izrazi služe za različite vrste rada sa bazom podataka.
-- DDL se koristi za kreiranje i izmjenu strukture baze podataka
-- (CREATE, ALTER, DROP – tabele, pogledi, indeksi).
-- DML se koristi za rad sa podacima (SELECT, INSERT, UPDATE, DELETE).
-- DCL se koristi za upravljanje pravima pristupa (GRANT, REVOKE).

-- 2.
-- U bazi postoje različiti tipovi korisnika: administratori, programeri i krajnji korisnici.
-- Administrator baze upravlja sigurnošću, performansama i održavanjem.
-- Programeri pristupaju bazi kroz aplikacije.
-- Krajnji korisnici koriste bazu indirektno, najčešće kroz forme i izvještaje.

-- 3.
-- Ekskluzivno zaključavanje (exclusive lock) onemogućava drugim transakcijama
-- čitanje i izmjenu podataka dok je lock aktivan, čime se osigurava konzistentnost.

-- 4.
-- WHERE filtrira redove prije grupisanja,
-- HAVING filtrira rezultate nakon grupisanja i agregacije.

-- 5.
-- Procedure omogućavaju ponovno korištenje SQL logike,
-- poboljšavaju sigurnost i performanse jer se izvršavaju na strani baze.

-- 6.
-- Podupiti su SQL upiti unutar drugih upita
-- i koriste se za kompleksna poređenja (AVG, MAX, EXISTS...).

-- 7.
-- ACID garantuje pouzdanost transakcija,
-- BASE daje prednost dostupnosti i brzini uz privremenu nekonzistentnost.

-- 8.
-- Kursori omogućavaju obradu podataka red po red,
-- koriste se kada set-based rješenja nisu dovoljna.

-- 9.
-- SQL upit nije ispravan ako koristi agregatnu funkciju
-- bez GROUP BY klauzule za ostale kolone.

-- 10.
-- Rezultat SQL izraza je lista kupaca sa ukupnim iznosom većim od 10000,
-- sortirana opadajuće po ukupnom iznosu.

-- 11.
-- SQL upit nije ispravan ako koristi kolone koje ne postoje
-- u tabelama navedenim u FROM klauzuli.

-- 12.
-- Rezultat su svi odjeli koji nemaju nijednog zaposlenog
-- (NOT EXISTS / LEFT JOIN IS NULL).



/* ============================================================
   2. ADVENTUREWORKS2017 – SQL UPITI (60 BODOVA)
   ============================================================ */

-- 2a (10 bodova)
SELECT
    pc.Name AS Kategorija,
    COUNT(*) AS [Broj proizvoda ispod prosjeka]
FROM AdventureWorks2017.Production.Product p
JOIN AdventureWorks2017.Production.ProductSubcategory psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN AdventureWorks2017.Production.ProductCategory pc
    ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE p.ListPrice <
(
    SELECT AVG(p2.ListPrice)
    FROM AdventureWorks2017.Production.Product p2
    JOIN AdventureWorks2017.Production.ProductSubcategory ps2
        ON p2.ProductSubcategoryID = ps2.ProductSubcategoryID
    WHERE ps2.ProductCategoryID = pc.ProductCategoryID
)
GROUP BY pc.Name;


-- 2b (10 bodova)
SELECT
    soh.SalesOrderID AS [ID narudžbe],
    soh.OrderDate AS [Datum narudžbe]
FROM AdventureWorks2017.Sales.SalesOrderHeader soh
JOIN AdventureWorks2017.Sales.SalesOrderDetail sod
    ON soh.SalesOrderID = sod.SalesOrderID
WHERE
(
    (YEAR(soh.OrderDate) = 2013 AND DATEPART(QUARTER, soh.OrderDate) = 4)
 OR (YEAR(soh.OrderDate) = 2014 AND DATEPART(QUARTER, soh.OrderDate) = 1)
)
AND soh.TotalDue > 1500
AND soh.CreditCardID IS NOT NULL
AND DATEDIFF(DAY, soh.OrderDate, soh.ShipDate) <= 7
GROUP BY soh.SalesOrderID, soh.OrderDate
HAVING COUNT(sod.SalesOrderDetailID) >= 4
   AND SUM(CASE WHEN sod.UnitPriceDiscount > 0 THEN 1 ELSE 0 END) >= 1;


-- 2c (10 bodova)
SELECT
    sp.BusinessEntityID AS [ID prodavača],
    pp.FirstName + ' ' + pp.LastName AS [Ime i prezime prodavača],
    SUM(soh.TotalDue) AS [Ukupna prodaja]
FROM AdventureWorks2017.Sales.SalesOrderHeader soh
JOIN AdventureWorks2017.Sales.SalesPerson sp
    ON soh.SalesPersonID = sp.BusinessEntityID
JOIN AdventureWorks2017.Person.Person pp
    ON sp.BusinessEntityID = pp.BusinessEntityID
WHERE YEAR(soh.OrderDate) = 2013
GROUP BY sp.BusinessEntityID, pp.FirstName, pp.LastName
HAVING SUM(soh.TotalDue) > 150000
   AND MAX(soh.TotalDue) > 5000;


-- 2d (5 bodova)
SELECT DISTINCT
    p.Name AS [Naziv proizvoda]
FROM AdventureWorks2017.Production.Product p
JOIN AdventureWorks2017.Sales.SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
WHERE sod.UnitPriceDiscount > 0
  AND p.SellEndDate IS NOT NULL;


-- 2e (5 bodova)
SELECT
    c.CustomerID AS [ID kupca],
    pp.FirstName + ' ' + pp.LastName AS [Ime i prezime]
FROM AdventureWorks2017.Sales.Customer c
JOIN AdventureWorks2017.Person.Person pp
    ON c.PersonID = pp.BusinessEntityID
JOIN AdventureWorks2017.Sales.SalesOrderHeader soh
    ON c.CustomerID = soh.CustomerID
WHERE pp.LastName = 'Adams'
GROUP BY c.CustomerID, pp.FirstName, pp.LastName
HAVING SUM(soh.TotalDue) > 1000
ORDER BY SUM(soh.TotalDue) DESC;


-- 2f (10 bodova)
SELECT
    p.Name AS [Naziv proizvoda],
    SUM(sod.OrderQty) AS [Prodana količina]
FROM AdventureWorks2017.Production.Product p
JOIN AdventureWorks2017.Sales.SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name, p.ProductSubcategoryID
HAVING SUM(sod.OrderQty) >
(
    SELECT AVG(t.Ukupno)
    FROM
    (
        SELECT SUM(sod2.OrderQty) AS Ukupno
        FROM AdventureWorks2017.Production.Product p2
        JOIN AdventureWorks2017.Sales.SalesOrderDetail sod2
            ON p2.ProductID = sod2.ProductID
        WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID
        GROUP BY p2.ProductID
    ) t
)
ORDER BY [Prodana količina] DESC;


-- 2g (10 bodova)
SELECT DISTINCT
    p.Name AS [Naziv proizvoda]
FROM AdventureWorks2017.Production.Product p
JOIN AdventureWorks2017.Sales.SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
JOIN AdventureWorks2017.Sales.SalesOrderHeader soh
    ON sod.SalesOrderID = soh.SalesOrderID
JOIN AdventureWorks2017.Production.ProductSubcategory psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN AdventureWorks2017.Production.ProductCategory pc
    ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Clothing'
GROUP BY p.ProductID, p.Name
HAVING COUNT(DISTINCT sod.SalesOrderID) > 20
   AND p.ProductID NOT IN
   (
       SELECT TOP 10 sod2.ProductID
       FROM AdventureWorks2017.Sales.SalesOrderDetail sod2
       JOIN AdventureWorks2017.Sales.SalesOrderHeader soh2
           ON sod2.SalesOrderID = soh2.SalesOrderID
       WHERE soh2.OrderDate < DATEADD(YEAR, 5,
             (SELECT MIN(OrderDate)
              FROM AdventureWorks2017.Sales.SalesOrderHeader))
       GROUP BY sod2.ProductID
       ORDER BY SUM(sod2.OrderQty) DESC
   )
ORDER BY p.Name;



/* ============================================================
   3. KREIRANJE BAZE I OBJEKATA (20 BODOVA)
   ============================================================ */

CREATE DATABASE IB200200;
GO

USE IB200200;
GO


-- 3.1 Tabele

CREATE TABLE Proizvodi
(
    ProizvodID INT IDENTITY(1,1) PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL,
    Boja NVARCHAR(15),
    Velicina NVARCHAR(5),
    DatumPocetkaProdaje DATETIME NOT NULL,
    DatumZavrsetkaProdaje DATETIME NOT NULL,
    UkupnaKolicinaNaSkladistu INT
);

CREATE TABLE StavkeNarudzbe
(
    NarudzbaID INT NOT NULL,
    StavkaNarudzbeID INT IDENTITY(1,1) NOT NULL,
    ProizvodID INT NOT NULL,
    Kolicina SMALLINT NOT NULL,
    Cijena MONEY NOT NULL,
    Popust MONEY NOT NULL,
    OpisSpecijalnePonude NVARCHAR(255),
    CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY (NarudzbaID, StavkaNarudzbeID),
    CONSTRAINT FK_StavkeNarudzbe_Proizvodi
        FOREIGN KEY (ProizvodID) REFERENCES Proizvodi(ProizvodID)
);


-- 3.2 Kopiranje podataka

SET IDENTITY_INSERT Proizvodi ON;

INSERT INTO Proizvodi
SELECT
    p.ProductID,
    p.Name,
    p.Color,
    p.Size,
    p.SellStartDate,
    ISNULL(p.SellEndDate, GETDATE()),
    ISNULL(SUM(pi.Quantity), 0)
FROM AdventureWorks2017.Production.Product p
LEFT JOIN AdventureWorks2017.Production.ProductInventory pi
    ON p.ProductID = pi.ProductID
WHERE p.SellStartDate IS NOT NULL
GROUP BY
    p.ProductID, p.Name, p.Color, p.Size, p.SellStartDate, p.SellEndDate;

SET IDENTITY_INSERT Proizvodi OFF;


SET IDENTITY_INSERT StavkeNarudzbe ON;

INSERT INTO StavkeNarudzbe
SELECT
    sod.SalesOrderID,
    sod.SalesOrderDetailID,
    sod.ProductID,
    sod.OrderQty,
    sod.UnitPrice,
    sod.UnitPriceDiscount,
    so.Description
FROM AdventureWorks2017.Sales.SalesOrderDetail sod
JOIN AdventureWorks2017.Sales.SpecialOffer so
    ON sod.SpecialOfferID = so.SpecialOfferID
JOIN Proizvodi p
    ON sod.ProductID = p.ProizvodID;

SET IDENTITY_INSERT StavkeNarudzbe OFF;


-- Procedura
CREATE OR ALTER PROCEDURE sp_Prodaja_insertUpdate
(
    @NarudzbaID INT,
    @ProizvodID INT,
    @Kolicina SMALLINT,
    @Cijena MONEY,
    @Popust MONEY,
    @OpisSpecijalnePonude NVARCHAR(255) = NULL
)
AS
BEGIN
    INSERT INTO StavkeNarudzbe
    VALUES (@NarudzbaID, DEFAULT, @ProizvodID, @Kolicina, @Cijena, @Popust, @OpisSpecijalnePonude);

    UPDATE Proizvodi
    SET UkupnaKolicinaNaSkladistu = UkupnaKolicinaNaSkladistu - @Kolicina
    WHERE ProizvodID = @ProizvodID;
END;


-- Funkcija
CREATE OR ALTER FUNCTION ProvjeriDostupnostProizvoda
(
    @ProizvodID INT,
    @Kolicina INT
)
RETURNS NVARCHAR(2)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Proizvodi
        WHERE ProizvodID = @ProizvodID
          AND UkupnaKolicinaNaSkladistu >= @Kolicina
    )
        RETURN 'Da';
    RETURN 'Ne';
END;


-- View
CREATE OR ALTER VIEW v_StatistikaProdaje
AS
SELECT
    p.Naziv AS Proizvod,
    SUM(sn.Cijena * sn.Kolicina) AS [Vrijednost prodaje],
    SUM(sn.Kolicina) AS [Količina prodaje]
FROM Proizvodi p
JOIN StavkeNarudzbe sn ON p.ProizvodID = sn.ProizvodID
GROUP BY p.Naziv
HAVING SUM(sn.Kolicina) > 50
   AND SUM(sn.Cijena * sn.Kolicina) > 1000;
