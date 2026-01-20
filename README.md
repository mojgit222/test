-- 2. Baza: AdventureWorks2017
-- Maksimalno: 60 bodova


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
-- svakog od prodavača pojedinačno. U obzir uzeti samo one
-- prodavače koji su imali barem jednu narudžbu veću od 5000
-- i one čija je ukupna prodaja veća od 150000.
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
-- Prikazati sve Adamse (kupce s prezimenom Adams) koji su
-- potrošili više od 1000 KM na sve kreirane narudžbe.
-- Rezultate sortirati po utrošku u opadajućem redoslijedu.
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
-- Prikazati proizvode koji su prodani u količini većoj od
-- prosječne prodaje podkategorije kojoj pripadaju.
-- Rezultate sortirati prema ukupnoj količini u opadajućem redoslijedu.
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


SELECT 
    p1.Name AS [Naziv proizvoda],
    SUM(sod1.OrderQty) AS [Prodana količina]
FROM AdventureWorks2017.Production.Product AS p1
INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod1
    ON p1.ProductID = sod1.ProductID
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS ps1
    ON p1.ProductSubcategoryID = ps1.ProductSubcategoryID
GROUP BY 
    p1.ProductID,
    p1.Name,
    ps1.ProductSubcategoryID,
    ps1.ProductCategoryID
HAVING SUM(sod1.OrderQty) >
(
    SELECT AVG(a.suma)
    FROM
    (
        SELECT 
            p.ProductID,
            SUM(sod.OrderQty) AS suma
        FROM AdventureWorks2017.Production.Product AS p
        INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS ps
            ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
            ON p.ProductID = sod.ProductID
        WHERE 
            ps.ProductSubcategoryID = ps1.ProductSubcategoryID
            OR ps.ProductCategoryID = ps1.ProductCategoryID
        GROUP BY p.ProductID
    ) AS a
)
ORDER BY [Prodana količina] DESC;












-- 2g (10 bodova)
-- Prikazati odjevne predmete prodane više od 20 puta
-- (nalaze se na više od 20 narudžbi), a nisu na listi
-- 10 najprodavanijih proizvoda u prvih pet godina prodaje.
-- Sortirati po nazivu proizvoda.
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




-- 3.
-- Kreirati bazu podataka koju ćete imenovati svojim brojem indeksa.
-- max: 20 bodova

CREATE DATABASE IB200200;

USE IB200200;

-- 3.1. (3 boda)
-- U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:

-- a) Proizvodi
-- • ProizvodID, cjelobrojni tip i primarni ključ, autoinkrement
-- • Naziv, 50 UNICODE karaktera (obavezan unos)
-- • Boja, 15 UNICODE karaktera
-- • Veličina, 5 UNICODE karaktera
-- • DatumPocetkaProdaje, polje za unos datuma i vremena (obavezan unos)
-- • DatumZavrsetkaProdaje, polje za unos datuma i vremena (obavezan unos)
-- • UkupnaKolicinaNaSkladistu, cjelobrojni tip

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

-- b) StavkeNarudzbe
-- • NarudzbaID, cjelobrojni tip i primarni ključ
-- • StavkaNarudzbeID, cjelobrojni tip i primarni ključ, autoinkrement
-- • ProizvodID, cjelobrojni tip, spoljni ključ
-- • Količina, skraćeni cjelobrojni tip (obavezan unos)
-- • Cijena, novčani tip (obavezan unos)
-- • Popust, novčani tip (obavezan unos)
-- • OpisSpecijalnePonude, 255 UNICODE karaktera

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



-- 3.2. (3 boda)
-- U kreiranu bazu kopirati podatke iz baze AdventureWorks2017:

-- a)
-- U tabelu Proizvodi dodati sve proizvode
-- • ProductID → ProizvodID
-- • Name → Naziv
-- • Color → Boja
-- • Size → Velicina
-- • SellStartDate → DatumPocetkaProdaje
-- • SellEndDate → DatumZavrsetkaProdaje
-- • Izračunata vrijednost za svaki proizvod na osnovu zaliha
--   na skladištu → UkupnaKolicinaNaSkladistu

SET IDENTITY_INSERT Proizvodi ON;
INSERT INTO Proizvodi
(
    ProizvodID,
    Naziv,
    Boja,
    Velicina,
    DatumPocetkaProdaje,
    DatumZavrsetkaProdaje,
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

-- b)
-- U tabelu StavkeNarudzbe dodati sve narudžbe
-- • SalesOrderID → NarudzbaID
-- • SalesOrderDetailID → StavkaNarudzbeID
-- • ProductID → ProizvodID
-- • OrderQty → Kolicina
-- • UnitPrice → Cijena
-- • UnitPriceDiscount → Popust
-- • Description → OpisSpecijalnePonude

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

-- 3.2. (14 bodova)

-- a) (5 bodova)
-- Kreirati proceduru sp_Prodaja_insertUpdate kojom će se izvršiti
-- insert podataka unutar tabele StavkeNarudzbe i automatski
-- smanjiti količina proizvoda na skladištu.
-- OBAVEZNO kreirati testni slučaj.

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
    (
        NarudzbaID,
        ProizvodID,
        Kolicina,
        Cijena,
        Popust,
        OpisSpecijalnePonude
    )
    VALUES
    (
        @NarudzbaID,
        @ProizvodID,
        @Kolicina,
        @Cijena,
        @Popust,
        @OpisSpecijalnePonude
    );

    UPDATE Proizvodi
    SET UkupnaKolicinaNaSkladistu =
        UkupnaKolicinaNaSkladistu - @Kolicina
    WHERE ProizvodID = @ProizvodID;
END;


-- Testni slučajevi za proceduru

EXEC sp_Prodaja_insertUpdate
    1001, 1, 2, 1200, 0.1, N'Specijalna ponuda';

EXEC sp_Prodaja_insertUpdate
    1002, 2, 1, 800, 0, NULL;

	select*
	from StavkeNarudzbe

	select*
	from Proizvodi

-- b) (5 bodova)
-- Kreirati funkciju ProvjeriDostupnostProizvoda
-- koja prima dva parametra: id proizvoda i količinu.
-- Funkcija vraća 'Da' ako na skladištu ima dovoljno proizvoda,
-- ili 'Ne' ako nema.
-- OBAVEZNO kreirati testni slučaj.

CREATE OR ALTER FUNCTION ProvjeriDostupnostProizvoda
(
    @ProizvodID INT,
    @Kolicina INT
)
RETURNS NVARCHAR(2)
AS
BEGIN
    DECLARE @Rezultat NVARCHAR(2) = 'Ne';
    DECLARE @NaStanju INT;

    SELECT @NaStanju = UkupnaKolicinaNaSkladistu
    FROM Proizvodi
    WHERE ProizvodID = @ProizvodID;

    IF ISNULL(@NaStanju, 0) >= @Kolicina
        SET @Rezultat = 'Da';

    RETURN @Rezultat;
END;


-- Testni slučajevi za funkciju

SELECT dbo.ProvjeriDostupnostProizvoda(1, 5);
SELECT dbo.ProvjeriDostupnostProizvoda(1, 5000);


-- c) (4 boda)
-- Kreirati pogled v_StatistikaProdaje koji za proizvode
-- prikazuje ukupnu vrijednost prodaje i ukupnu prodanu količinu.
-- Pogledom prikazati samo one proizvode koji su prodani
-- u količini većoj od 50, a ukupna je vrijednost bila veća od 1000.
--
-- Zaglavlje rješenja:
-- Proizvod, Vrijednost prodaje, Količina prodaje

CREATE OR ALTER VIEW v_StatistikaProdaje
AS
SELECT
    p.Naziv AS Proizvod,
    SUM(sn.Cijena * sn.Kolicina) AS [Vrijednost prodaje],
    SUM(sn.Kolicina) AS [Količina prodaje]
FROM Proizvodi p
INNER JOIN StavkeNarudzbe sn
    ON p.ProizvodID = sn.ProizvodID
GROUP BY p.Naziv
HAVING
    SUM(sn.Kolicina) > 50
    AND SUM(sn.Cijena * sn.Kolicina) > 1000;


-- Test pogleda

SELECT *
FROM v_StatistikaProdaje
ORDER BY [Vrijednost prodaje] DESC;



--1.
--DDL, DML i DCL izrazi služe za različite vrste rada sa bazom podataka. DDL se koristi za kreiranje i izmjenu strukture baze podataka, kao što su tabele, pogledi i indeksi. DML se koristi za rad sa podacima unutar tabela, odnosno za unos, izmjenu, brisanje i čitanje podataka. DCL se koristi za upravljanje pravima pristupa bazi podataka, odnosno za dodjeljivanje i oduzimanje privilegija korisnicima.

--2.
--U bazi podataka postoje različiti tipovi korisnika, kao što su administrator baze, programeri i krajnji korisnici. Administrator baze ima najveće ovlasti i odgovoran je za sigurnost, performanse i održavanje baze. Programeri koriste bazu kroz aplikacije i imaju ovlasti za rad nad podacima koje aplikacija zahtijeva. Krajnji korisnici koriste bazu indirektno, najčešće kroz forme i izvještaje, bez direktnog pristupa strukturi baze.

--3.
--Ekskluzivno zaključavanje funkcioniše tako da u trenutku kada jedna transakcija dobije ekskluzivni lock nad nekim podatkom, nijedna druga transakcija ne može taj podatak ni čitati ni mijenjati dok se zaključavanje ne oslobodi. Na taj način se sprječavaju nekonzistentni podaci i osigurava ispravnost transakcija.

--4.
--Sličnost između WHERE i HAVING klauzula je u tome što se obje koriste za filtriranje podataka. Razlika je u tome što WHERE filtrira redove prije grupisanja, dok HAVING filtrira rezultate nakon što je izvršeno grupisanje i agregacija podataka.

--5.
--Procedure se koriste kako bi se često korištene SQL operacije smjestile na jedno mjesto i ponovo koristile bez ponovnog pisanja koda. Takođe, procedure poboljšavaju sigurnost i performanse jer se logika izvršava na strani baze i može se ograničiti direktan pristup tabelama.

--6.
--Podupiti su SQL upiti koji se nalaze unutar drugih upita i služe za dobijanje privremenih rezultata koji se koriste u glavnom upitu. Oni omogućavaju složenije upite i poređenja, kao što su provjere prosjeka, maksimuma ili postojanja određenih podataka.

--7.
--Razlika između ACID i BASE pristupa je u načinu upravljanja transakcijama. ACID pristup garantuje potpunu tačnost, konzistentnost i pouzdanost transakcija, dok BASE pristup daje prednost dostupnosti i brzini, prihvatajući privremenu nekonzistentnost podataka.

--8.
--Kursori su mehanizam koji omogućava obradu podataka red po red. Koriste se u situacijama kada se nad svakim redom mora izvršiti posebna logika koju nije moguće jednostavno realizovati standardnim SQL upitima.

--9.
--SQL upit nije ispravan jer koristi agregatnu funkciju zajedno sa kolonom koja nije obuhvaćena GROUP BY klauzulom, što dovodi do sintaksne greške.

--10.
--Rezultat ovog SQL izraza je lista kupaca kod kojih je ukupan iznos računa veći od 10000, pri čemu je prikazana njihova šifra i prosječan iznos računa. Rezultati su sortirani po ukupnom iznosu računa u opadajućem redoslijedu, što omogućava menadžeru da vidi najvrijednije kupce.

--11.
--SQL upit nije ispravan jer u SELECT dijelu koristi kolone koje ne postoje u tabeli navednoj u FROM klauzuli, niti su tabele međusobno povezane.

--12.
--Rezultat ovog SQL izraza su svi odjeli koji nemaju nijednog zaposlenog. Upit provjerava za svaki odjel da li ne postoji nijedan zapis u tabeli zaposlenih koji je povezan s tim odjelom.
