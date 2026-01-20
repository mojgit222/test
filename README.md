# SQL rješenje – Baze podataka II

```sql
-- =========================================================
-- 2. Baza: AdventureWorks2017
-- Maksimalno: 60 bodova
-- =========================================================


-- 2a (10 bodova)
-- Za svaku kategoriju prikaži koliko joj pripada proizvoda
-- čija je maloprodajna cijena (List Price) manja od prosječne
-- maloprodajne cijene kategorije proizvoda kojoj proizvod pripada.
--
-- Zaglavlje rješenja:
-- Kategorija, Broj proizvoda ispod prosjeka

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
-- Prikazati narudžbe kreirane u četvrtom kvartalu 2013. ili
-- prvom kvartalu 2014. godine, imaju najmanje 4 stavke,
-- ukupna vrijednost narudžbe veća od 1500 (TotalDue),
-- isporučene u roku od 7 dana, plaćene kreditnom karticom
-- i sadrže barem jednu stavku sa popustom.
--
-- Zaglavlje rješenja:
-- ID narudžbe, Datum narudžbe

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
-- Prikazati ukupnu vrijednost prodaje u 2013. godini za
-- svakog od prodavača pojedinačno.
-- U obzir uzeti samo one prodavače koji su imali barem
-- jednu narudžbu veću od 5000 i ukupnu prodaju veću od 150000.
--
-- Zaglavlje rješenja:
-- ID prodavača, Ime i prezime prodavača, Ukupna prodaja

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
-- Prikazati proizvode koji su barem jednom prodani sa
-- popustom, a ne nalaze se više u ponudi.
--
-- Zaglavlje rješenja:
-- Naziv proizvoda

SELECT DISTINCT
    p.Name AS [Naziv proizvoda]
FROM AdventureWorks2017.Production.Product p
JOIN AdventureWorks2017.Sales.SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
WHERE sod.UnitPriceDiscount > 0
  AND p.SellEndDate IS NOT NULL;



-- 2e (5 bodova)
-- Prikazati sve Adamse (kupce s prezimenom Adams)
-- koji su potrošili više od 1000 KM.
--
-- Zaglavlje rješenja:
-- ID kupca, Ime i prezime

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
-- Prikazati proizvode koji su prodani u količini većoj
-- od prosječne prodaje podkategorije kojoj pripadaju.
--
-- Zaglavlje rješenja:
-- Naziv proizvoda, Prodana količina

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
-- Prikazati odjevne predmete prodane više od 20 puta,
-- a koji nisu među 10 najprodavanijih u prvih 5 godina.
--
-- Zaglavlje rješenja:
-- Naziv proizvoda

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



-- =========================================================
-- 3. Kreiranje baze i objekata
-- =========================================================

CREATE DATABASE IB200200;
GO

USE IB200200;
GO

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

    CONSTRAINT PK_StavkeNarudzbe
        PRIMARY KEY (NarudzbaID, StavkaNarudzbeID),

    CONSTRAINT FK_StavkeNarudzbe_Proizvodi
        FOREIGN KEY (ProizvodID)
        REFERENCES Proizvodi(ProizvodID)
);



-- =========================================================
-- Teorijska pitanja
-- =========================================================

-- 1.
-- DDL, DML i DCL izrazi služe za različite vrste rada sa bazom
-- podataka. DDL se koristi za kreiranje i izmjenu strukture
-- baze podataka, DML za rad sa podacima, a DCL za upravljanje
-- pravima pristupa.

-- 2.
-- U bazi podataka postoje administratori, programeri i
-- krajnji korisnici, sa različitim nivoima ovlasti.

-- 3.
-- Ekskluzivno zaključavanje onemogućava drugim transakcijama
-- pristup podacima dok se zaključavanje ne oslobodi.

-- 4.
-- WHERE filtrira redove prije grupisanja, a HAVING filtrira
-- rezultate nakon agregacije.

-- 5.
-- Procedure omogućavaju ponovnu upotrebu koda, veću sigurnost
-- i bolje performanse.

-- 6.
-- Podupiti su upiti unutar drugih upita koji omogućavaju
-- složenija poređenja i izračune.

-- 7.
-- ACID garantuje konzistentnost i pouzdanost, dok BASE daje
-- prednost dostupnosti i brzini.

-- 8.
-- Kursori omogućavaju obradu podataka red po red.

-- 9.
-- Greška nastaje kada se agregat koristi bez GROUP BY.

-- 10.
-- Rezultat prikazuje najvrijednije kupce prema ukupnom iznosu.

-- 11.
-- Greška je korištenje kolona koje ne postoje ili nisu povezane.

-- 12.
-- Rezultat su odjeli bez zaposlenih.
```
