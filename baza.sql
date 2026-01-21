

-- =====================================================
-- 2. Baza: AdventureWorks2017
-- =====================================================


-- =====================================================
-- 2a (5 bodova)
-- Prikazati proizvode koji su barem jednom prodani sa popustom,
-- a ne nalaze se više u ponudi (prestali se prodavati).
-- Zaglavlje: Naziv proizvoda, Kategorija
-- =====================================================

SELECT DISTINCT
    p.Name AS [Naziv proizvoda],
    pc.Name AS [Kategorija]
FROM AdventureWorks2017.Production.Product p
JOIN AdventureWorks2017.Sales.SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
JOIN AdventureWorks2017.Production.ProductSubcategory psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN AdventureWorks2017.Production.ProductCategory pc
    ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE sod.UnitPriceDiscount > 0
  AND p.SellEndDate IS NOT NULL;



-- =====================================================
-- 2b (5 bodova)
-- Prikazati sve Adamse (kupce s prezimenom Adams)
-- koji su potrošili više od 1000 KM.
-- Sortirati po utrošku opadajuće.
-- Zaglavlje: ID kupca, Ime kupca, Prezime kupca
-- =====================================================

SELECT
    c.CustomerID AS [ID kupca],
    pp.FirstName AS [Ime kupca],
    pp.LastName AS [Prezime kupca]
FROM AdventureWorks2017.Sales.Customer c
JOIN AdventureWorks2017.Person.Person pp
    ON c.PersonID = pp.BusinessEntityID
JOIN AdventureWorks2017.Sales.SalesOrderHeader soh
    ON c.CustomerID = soh.CustomerID
WHERE pp.LastName = 'Adams'
GROUP BY c.CustomerID, pp.FirstName, pp.LastName
HAVING SUM(soh.TotalDue) > 1000
ORDER BY SUM(soh.TotalDue) DESC;



-- =====================================================
-- 2c (10 bodova)
-- Prikazati kupce koji su od početka 2012. godine
-- na proizvode iz kategorije Bikes potrošili više
-- nego prije tog razdoblja.
-- Zaglavlje: ID kupca, Prezime kupca
-- =====================================================

SELECT
    c.CustomerID AS [ID kupca],
    pp.LastName AS [Prezime kupca]
FROM AdventureWorks2017.Sales.Customer c
JOIN AdventureWorks2017.Person.Person pp
    ON c.PersonID = pp.BusinessEntityID
JOIN AdventureWorks2017.Sales.SalesOrderHeader soh
    ON c.CustomerID = soh.CustomerID
JOIN AdventureWorks2017.Sales.SalesOrderDetail sod
    ON soh.SalesOrderID = sod.SalesOrderID
JOIN AdventureWorks2017.Production.Product p
    ON sod.ProductID = p.ProductID
JOIN AdventureWorks2017.Production.ProductSubcategory psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN AdventureWorks2017.Production.ProductCategory pc
    ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes'
GROUP BY c.CustomerID, pp.LastName
HAVING
    SUM(CASE WHEN soh.OrderDate >= '2012-01-01'
             THEN sod.LineTotal ELSE 0 END)
    >
    SUM(CASE WHEN soh.OrderDate < '2012-01-01'
             THEN sod.LineTotal ELSE 0 END);



-- =====================================================
-- 2d (10 bodova)
-- Prikazati ukupnu vrijednost prodaje u 2013. godini
-- za svakog prodavača.
-- Uslovi:
--  - barem jedna narudžba > 5000
--  - ukupna prodaja > 150000
-- Zaglavlje: ID prodavača, Ime i prezime prodavača, Ukupna prodaja
-- =====================================================

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



-- =====================================================
-- 2e (10 bodova)
-- Prikazati zaposlenike koji su trenutno zaposleni
-- u nekom odjelu, a čiji je broj slobodnih dana
-- veći od prosjeka svih zaposlenika.
-- Zaglavlje: Prezime zaposlenika, Ime zaposlenika
-- =====================================================

SELECT
    p.LastName AS [Prezime zaposlenika],
    p.FirstName AS [Ime zaposlenika]
FROM AdventureWorks2017.HumanResources.Employee e
JOIN AdventureWorks2017.Person.Person p
    ON e.BusinessEntityID = p.BusinessEntityID
JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory edh
    ON e.BusinessEntityID = edh.BusinessEntityID
WHERE edh.EndDate IS NULL
  AND e.VacationHours >
  (
      SELECT AVG(VacationHours)
      FROM AdventureWorks2017.HumanResources.Employee
  );


-- =====================================================
-- 2f (10 bodova)
-- Za svaku kategoriju prikazati koliko joj pripada proizvoda
-- čija je ListPrice manja od prosječne cijene te kategorije.
-- Zaglavlje: Kategorija, Broj proizvoda ispod prosjeka
-- =====================================================

SELECT
    pc.Name AS [Kategorija],
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
    JOIN AdventureWorks2017.Production.ProductSubcategory psc2
        ON p2.ProductSubcategoryID = psc2.ProductSubcategoryID
    WHERE psc2.ProductCategoryID = pc.ProductCategoryID
)
GROUP BY pc.Name;



CREATE DATABASE IB190056;
USE IB190056;



--  3.1 a) Tabela Proizvodi
CREATE TABLE Proizvodi
(
    ProizvodID INT IDENTITY(1,1) PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL,
    Boja NVARCHAR(15),
    Velicina NVARCHAR(5),
    DatumPocetkaProdaje DATETIME NOT NULL,
    DatumKrajaProdaje DATETIME NOT NULL,
    UkupnaKolicinaNaSkladistu INT
);



-- 3. 1 b) Tabela StavkeNarudzbe
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


 -- 3.2 a
SET IDENTITY_INSERT Proizvodi ON;
INSERT INTO Proizvodi
(
    ProizvodID,
    Naziv,
    Boja,
    Velicina,
    DatumPocetkaProdaje,
    DatumKrajaProdaje,
    UkupnaKolicinaNaSkladistu
)
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
    p.ProductID,
    p.Name,
    p.Color,
    p.Size,
    p.SellStartDate,
    p.SellEndDate;
SET IDENTITY_INSERT Proizvodi OFF;



 -- 3.2 b
SET IDENTITY_INSERT StavkeNarudzbe ON;
INSERT INTO StavkeNarudzbe
(
    NarudzbaID,
    StavkaNarudzbeID,
    ProizvodID,
    Kolicina,
    Cijena,
    Popust,
    OpisSpecijalnePonude
)
SELECT
    sod.SalesOrderID,
    sod.SalesOrderDetailID,
    sod.ProductID,
    sod.OrderQty,
    sod.UnitPrice,
    sod.UnitPriceDiscount,
    so.Description
FROM AdventureWorks2017.Sales.SalesOrderDetail sod
INNER JOIN AdventureWorks2017.Sales.SpecialOffer so
    ON sod.SpecialOfferID = so.SpecialOfferID
INNER JOIN Proizvodi p
    ON sod.ProductID = p.ProizvodID;
SET IDENTITY_INSERT StavkeNarudzbe OFF;









--1. (2 boda)
--DDL, DML i DCL izrazi služe za različite vrste rada s bazom podataka.
--DDL se koristi za kreiranje i izmjenu strukture baze (tabele, pogledi, indeksi).
--DML se koristi za rad sa podacima (unos, izmjena, brisanje, čitanje).
--DCL se koristi za upravljanje pravima pristupa bazi podataka.

--2. (2 boda)
--Podupiti su SQL upiti koji se izvršavaju unutar drugih upita.
--Izvršavaju se prvo, a njihov rezultat se koristi u glavnom upitu.
--Tri osnovna načina rada s podupitima su:
--– podupit koji vraća jednu vrijednost,
--– podupit koji vraća više vrijednosti,
--– korelirani podupit.

--3. (2 boda)
--Sličnost između WHERE i HAVING klauzule je što obje služe za filtriranje podataka.
--Razlika je u tome što WHERE filtrira redove prije grupisanja, dok HAVING filtrira rezultate nakon grupisanja i agregatnih funkcija.

--4. (2 boda)
--Procedure se koriste radi ponovne upotrebe koda i boljih performansi.
--Takođe povećavaju sigurnost jer se korisnicima može ograničiti direktan pristup tabelama.

--5. (2 boda)
--Sličnost između okidača (triggera) i procedura je što oba sadrže SQL logiku.
--Razlika je u tome što se triggeri izvršavaju automatski kao reakcija na INSERT, UPDATE ili DELETE, dok se procedure pokreću ručno.

--6. (2 boda)
--Transakcija je skup SQL naredbi koje se izvršavaju kao jedna cjelina.
--Može se prekinuti pomoću ROLLBACK naredbe, a potvrđuje se pomoću COMMIT.

--7. (2 boda)
--Kontrola višekorisničkog pristupa podrazumijeva istovremeni rad više korisnika nad bazom bez narušavanja podataka.
--Postiže se zaključavanjem (locking), transakcijama i različitim nivoima izolacije.

--8. (1 bod)
--Deadlock nastaje kada dvije ili više transakcija međusobno čekaju da se oslobode resursi koje jedna drugoj drže zaključane.

--9. (1 bod)
--ROLE služe za grupisanje privilegija i lakše upravljanje pravima korisnika u bazi podataka.

--10. (1 bod)
--Rezultat ovog SQL izraza je lista proizvoda koji nemaju nijednu stavku računa, odnosno proizvodi koji nikada nisu prodani.
--To se postiže korištenjem NOT EXISTS podupita.

--11. (1 bod)
--SQL upit nije ispravan.
--HAVING se koristi samo uz GROUP BY, a u ovom upitu GROUP BY nije naveden, što dovodi do greške.

--12. (1 bod)
--SQL upit nije ispravan.
--Nedostaje uslov povezivanja između tabela, odnosno ne postoji JOIN uslov koji bi definisao odnos između tabela kupci i skladište.
