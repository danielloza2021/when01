/*
| Tabla    | Significado                                  | ¿Qué almacena?                             |
| -------- | -------------------------------------------- | ------------------------------------------ |
| **OCRD** | **O** + **CRD** = *Business Partners / Card* | Socios de negocios: clientes y proveedores |
| **OITM** | **O** + **ITM** = *Items*                    | Maestro de artículos/productos             |
| **OSLP** | **O** + **SLP** = *Sales Persons*            | Vendedores                                 |
| **OBPL** | **O** + **BPL** = *Business Places*          | Sucursales / establecimientos              |
| **OINV** | **O** + **INV** = *Invoices*                 | Cabecera de facturas de clientes           |
| **INV1** | **INV** + **1**                              | Líneas/detalle de las facturas             |
| **ORDR** | **O** + **RDR** = *Orders*                   | Cabecera de pedidos de clientes            |
| **RDR1** | **RDR** + **1**                              | Líneas/detalle de los pedidos              |

*/

IF DB_ID('SAPB1_Practica') IS NOT NULL
BEGIN
    ALTER DATABASE SAPB1_Practica SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SAPB1_Practica;
END;



USE MASTER
GO

CREATE DATABASE SAPB1_Practica;
GO
USE SAPB1_Practica;
GO

/*SOCIOS DE NEGOCIOS (O + CRD) = Business Partners/Card - Clientes y Proveedores*/
CREATE TABLE OCRD (
    CardCode VARCHAR(15) NOT NULL PRIMARY KEY,
    CardName VARCHAR(100) NOT NULL,
    CardType CHAR(1) NOT NULL,       -- C=Cliente, S=Proveedor
    GroupCode INT NOT NULL,
    City VARCHAR(60),
    Phone VARCHAR(30),
    SalesPersonCode INT NULL,
    CreditLine DECIMAL(18,2) DEFAULT 0,
    Balance DECIMAL(18,2) DEFAULT 0,
    Active BIT DEFAULT 1
);
GO

/*ARTICULOS O + ITM=Items Maestro de artículos/productos*/
CREATE TABLE OITM (
    ItemCode VARCHAR(20) NOT NULL PRIMARY KEY,
    ItemName VARCHAR(120) NOT NULL,
    ItmsGrpCod INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Stock DECIMAL(18,2) NOT NULL,
    Active BIT DEFAULT 1
);
GO

/*O + SLP = Sales Persons = Vendedores*/
CREATE TABLE OSLP (
    SlpCode INT NOT NULL PRIMARY KEY,
    SlpName VARCHAR(100) NOT NULL,
    Commission DECIMAL(5,2) DEFAULT 0
);
GO

/*O + BPL = Business Places = Sucursales / establecimientos */
CREATE TABLE OBPL (
    BPLId INT NOT NULL PRIMARY KEY,
    BPLName VARCHAR(100) NOT NULL,
    City VARCHAR(60) NOT NULL
);
GO

/* O + INV = Invoices = Cabecera de facturas de clientes */
CREATE TABLE OINV (
    DocEntry INT NOT NULL PRIMARY KEY,
    DocNum INT NOT NULL UNIQUE,
    CardCode VARCHAR(15) NOT NULL,
    DocDate DATE NOT NULL,
    DocDueDate DATE NOT NULL,
    TaxDate DATE NOT NULL,
    DocTotal DECIMAL(18,2) NOT NULL,
    PaidToDate DECIMAL(18,2) DEFAULT 0,
    DocStatus CHAR(1) NOT NULL,      -- O=Abierta, C=Cerrada
    BPLId INT NOT NULL,
    SlpCode INT NULL,
    Comments VARCHAR(250),
    CONSTRAINT FK_OINV_OCRD FOREIGN KEY (CardCode) REFERENCES OCRD(CardCode),
    CONSTRAINT FK_OINV_OBPL FOREIGN KEY (BPLId) REFERENCES OBPL(BPLId),
    CONSTRAINT FK_OINV_OSLP FOREIGN KEY (SlpCode) REFERENCES OSLP(SlpCode)
);
GO

/* INV + 1 = Líneas/detalle de las facturas */
CREATE TABLE INV1 (
    DocEntry INT NOT NULL,
    LineNum INT NOT NULL,
    ItemCode VARCHAR(20) NOT NULL,
    Quantity DECIMAL(18,2) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    LineTotal AS (Quantity * Price) PERSISTED,
    CONSTRAINT PK_INV1 PRIMARY KEY (DocEntry, LineNum),
    CONSTRAINT FK_INV1_OINV FOREIGN KEY (DocEntry) REFERENCES OINV(DocEntry),
    CONSTRAINT FK_INV1_OITM FOREIGN KEY (ItemCode) REFERENCES OITM(ItemCode)
);
GO

/* O + RDR = Orders = Cabecera de pedidos de clientes */
CREATE TABLE ORDR (
    DocEntry INT NOT NULL PRIMARY KEY,
    DocNum INT NOT NULL UNIQUE,
    CardCode VARCHAR(15) NOT NULL,
    DocDate DATE NOT NULL,
    DocDueDate DATE NOT NULL,
    DocTotal DECIMAL(18,2) NOT NULL,
    DocStatus CHAR(1) NOT NULL,
    BPLId INT NOT NULL,
    SlpCode INT NULL,
    CONSTRAINT FK_ORDR_OCRD FOREIGN KEY (CardCode) REFERENCES OCRD(CardCode),
    CONSTRAINT FK_ORDR_OBPL FOREIGN KEY (BPLId) REFERENCES OBPL(BPLId),
    CONSTRAINT FK_ORDR_OSLP FOREIGN KEY (SlpCode) REFERENCES OSLP(SlpCode)
);
GO

/* RDR + 1 Líneas/detalle de los pedidos */
CREATE TABLE RDR1 (
    DocEntry INT NOT NULL,
    LineNum INT NOT NULL,
    ItemCode VARCHAR(20) NOT NULL,
    Quantity DECIMAL(18,2) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    LineTotal AS (Quantity * Price) PERSISTED,
    CONSTRAINT PK_RDR1 PRIMARY KEY (DocEntry, LineNum),
    CONSTRAINT FK_RDR1_ORDR FOREIGN KEY (DocEntry) REFERENCES ORDR(DocEntry),
    CONSTRAINT FK_RDR1_OITM FOREIGN KEY (ItemCode) REFERENCES OITM(ItemCode)
);
GO

/* Registros */
INSERT INTO OSLP VALUES
(1,'Ana Torres',5.00),(2,'Carlos Ruiz',4.50),(3,'María López',6.00),
(4,'Jorge Díaz',3.50),(5,'Lucía Pérez',5.50);

INSERT INTO OBPL VALUES
(1,'Sucursal Lima Centro','Lima'),
(2,'Sucursal Miraflores','Lima'),
(3,'Sucursal Arequipa','Arequipa'),
(4,'Sucursal Trujillo','Trujillo');

INSERT INTO OCRD VALUES
('C0001','Comercial Andina','C',100,'Lima','987111111',1,50000,12500,1),
('C0002','Distribuidora Norte','C',101,'Trujillo','987222222',2,30000,18000,1),
('C0003','Inversiones Sol','C',100,'Arequipa','987333333',3,40000,7500,1),
('C0004','Corporación Pacífico','C',102,'Lima','987444444',1,60000,32000,1),
('C0005','TecnoPerú','C',103,'Lima','987555555',4,25000,3000,1),
('C0006','Retail Sur','C',104,'Arequipa','987666666',5,35000,22000,1),
('C0007','Mercantil Norte','C',101,'Trujillo','987777777',2,20000,4500,1),
('C0008','Servicios Lima','C',102,'Lima','987888888',3,45000,12000,1),
('C0009','Importadora Sol','C',105,'Lima','987999999',4,70000,41000,1),
('C0010','Comercial del Sur','C',104,'Arequipa','988000000',5,28000,6000,1),
('P0001','Proveedor Global','S',200,'Lima','986111111',NULL,0,0,1),
('P0002','Tecnología Andina','S',201,'Lima','986222222',NULL,0,0,1);

INSERT INTO OITM VALUES
('A0001','Laptop Business 14',10,3200,45,1),
('A0002','Monitor LED 24',10,750,80,1),
('A0003','Teclado Mecánico',11,280,120,1),
('A0004','Mouse Óptico',11,90,200,1),
('A0005','Impresora Multifunción',12,980,35,1),
('A0006','Disco SSD 1TB',13,420,95,1),
('A0007','Memoria RAM 16GB',13,260,150,1),
('A0008','Router WiFi 6',14,520,70,1),
('A0009','Cámara Web HD',15,310,65,1),
('A0010','UPS 1200VA',16,690,40,1),
('A0011','Laptop Pro 16',10,5200,20,1),
('A0012','Monitor Profesional 27',10,1450,30,1);

INSERT INTO OINV
VALUES
(1,1001,'C0001','2026-01-05','2026-02-04','2026-01-05',6400,6400,'C',1,1,'Factura pagada'),
(2,1002,'C0002','2026-01-10','2026-02-09','2026-01-10',7500,2000,'O',4,2,'Saldo pendiente'),
(3,1003,'C0003','2026-01-15','2026-02-14','2026-01-15',2940,2940,'C',3,3,'Factura pagada'),
(4,1004,'C0004','2026-02-03','2026-03-05','2026-02-03',10400,0,'O',2,1,'Pendiente'),
(5,1005,'C0005','2026-02-12','2026-03-14','2026-02-12',4200,4200,'C',1,4,'Pagada'),
(6,1006,'C0006','2026-02-20','2026-03-22','2026-02-20',1380,500,'O',3,5,'Pago parcial'),
(7,1007,'C0007','2026-03-02','2026-04-01','2026-03-02',3200,0,'O',4,2,'Pendiente'),
(8,1008,'C0008','2026-03-08','2026-04-07','2026-03-08',7500,7500,'C',2,3,'Pagada'),
(9,1009,'C0009','2026-03-15','2026-04-14','2026-03-15',10400,4000,'O',1,4,'Pago parcial'),
(10,1010,'C0010','2026-03-25','2026-04-24','2026-03-25',2080,0,'O',3,5,'Pendiente'),
(11,1011,'C0001','2026-04-02','2026-05-02','2026-04-02',14500,14500,'C',1,1,'Pagada'),
(12,1012,'C0002','2026-04-12','2026-05-12','2026-04-12',5200,0,'O',4,2,'Pendiente'),
(13,1013,'C0003','2026-04-18','2026-05-18','2026-04-18',6300,3000,'O',3,3,'Pago parcial'),
(14,1014,'C0004','2026-05-05','2026-06-04','2026-05-05',15600,15600,'C',2,1,'Pagada'),
(15,1015,'C0005','2026-05-14','2026-06-13','2026-05-14',7800,0,'O',1,4,'Pendiente'),
(16,1016,'C0006','2026-05-20','2026-06-19','2026-05-20',10350,0,'O',3,5,'Pendiente'),
(17,1017,'C0007','2026-06-01','2026-07-01','2026-06-01',4160,4160,'C',4,2,'Pagada'),
(18,1018,'C0008','2026-06-10','2026-07-10','2026-06-10',7250,0,'O',2,3,'Pendiente'),
(19,1019,'C0009','2026-06-18','2026-07-18','2026-06-18',6400,2000,'O',1,4,'Pago parcial'),
(20,1020,'C0010','2026-06-25','2026-07-25','2026-06-25',5600,5600,'C',3,5,'Pagada');

INSERT INTO INV1 (DocEntry,LineNum,ItemCode,Quantity,Price) VALUES
(1,0,'A0001',2,3200),
(2,0,'A0002',10,750),
(3,0,'A0003',7,280),(3,1,'A0004',10,90),
(4,0,'A0011',2,5200),
(5,0,'A0006',10,420),
(6,0,'A0007',3,260),(6,1,'A0004',6,90),
(7,0,'A0001',1,3200),
(8,0,'A0002',10,750),
(9,0,'A0005',10,980),(9,1,'A0004',6,90),
(10,0,'A0008',4,520),
(11,0,'A0012',10,1450),
(12,0,'A0008',10,520),
(13,0,'A0009',10,310),(13,1,'A0004',35,90),
(14,0,'A0011',3,5200),
(15,0,'A0006',10,420),(15,1,'A0007',14,260),
(16,0,'A0010',15,690),
(17,0,'A0005',4,980),(17,1,'A0004',2,60),
(18,0,'A0002',5,750),(18,1,'A0003',10,280),
(19,0,'A0001',2,3200),
(20,0,'A0008',10,520),(20,1,'A0004',4,90);

INSERT INTO ORDR VALUES
(101,2001,'C0001','2026-06-05','2026-06-20',3200,'O',1,1),
(102,2002,'C0002','2026-06-08','2026-06-23',7500,'O',4,2),
(103,2003,'C0003','2026-06-12','2026-06-27',5200,'C',3,3),
(104,2004,'C0004','2026-06-15','2026-06-30',1450,'O',2,1),
(105,2005,'C0005','2026-06-20','2026-07-05',9800,'C',1,4),
(106,2006,'C0006','2026-06-22','2026-07-07',1380,'O',3,5),
(107,2007,'C0007','2026-06-25','2026-07-10',6400,'O',4,2),
(108,2008,'C0008','2026-06-28','2026-07-13',10400,'C',2,3);

INSERT INTO RDR1 VALUES
(101,0,'A0001',1,3200),
(102,0,'A0002',10,750),
(103,0,'A0011',1,5200),
(104,0,'A0012',1,1450),
(105,0,'A0005',10,980),
(106,0,'A0007',3,260),(106,1,'A0004',5,120),
(107,0,'A0001',2,3200),
(108,0,'A0005',10,980);

CREATE INDEX IX_OINV_CardCode ON OINV(CardCode);
CREATE INDEX IX_OINV_DocDate ON OINV(DocDate);
CREATE INDEX IX_INV1_ItemCode ON INV1(ItemCode);
GO

/* Verificación rápida */
SELECT COUNT(*) AS Clientes FROM OCRD WHERE CardType='C';
SELECT COUNT(*) AS Articulos FROM OITM;
SELECT COUNT(*) AS Facturas FROM OINV;
SELECT COUNT(*) AS LineasFactura FROM INV1;
GO

SELECT * FROM OCRD
GO

/*Listar los clientes activos*/
select CardCode as Codigo,
       CardName as Nombre,
       Phone as Celular,
       City as Ciudad
       from OCRD
       where CardType='C'
       and Active=1
go

select count(CardType) as Tarjeta from OCRD
go

select City,count(CardType) as Tarjeta from OCRD
group by City,CardType
go

select City,count(CardType) as Tarjeta from OCRD
group by City,CardType
having CardType='S'
go

select City,count(CardType) as Tarjeta from OCRD
group by City,CardType
having CardType='C'
go

select * from OINV
go

/*Listar las facturas emitidas
15 de marzo de 2026*/
Select DocNum as Documento,
       CardCode as Codigo,
       DocDate as Fecha,
       DocTotal as Monto
       from OINV
       go

Select DocNum as Documento,
       CardCode as Codigo,
       DocDate as Fecha,
       DocTotal as Monto
       from OINV
       where DocDate='2026-03-15'
       go

/*Listar las facturas emitidas
por un mes especifico*/
select getdate() as fecha
go

select year(getdate()) as año
go

select month(getdate()) as Mes
go

select day(getdate()) as Dia
go

/*Listar las facturas emitidas
por un mes especifico*/
Select DocNum as Documento,
       CardCode as Codigo,
       DocDate as Fecha,
       DocTotal as Monto
       from OINV
       where month(DocDate)='03'
       go

/*Hallar el Maximo valor del monto*/
Select DocDate as Fecha,DocTotal as Monto
       from OINV
       where DocTotal=(select max(DocTotal)
                     from OINV)
       go

Select DocDate as Fecha,DocTotal as Monto
       from OINV
       where DocDate>='20260301'
             and DocDate<'20260401'
             and DocTotal=(select max(DocTotal)
                     from OINV
                     where month(DocDate)=3)
                     
/*Crear un procedimiento almacenado
  create procedure <Nombre_proc>
  <Parametros>
  as
     begin
        bloque de instrucciones
  
  Modificar un procedimiento almacenado
  alter procedure <Nombre_proc>
  <Parametros>
  as
     begin
        bloque de instrucciones
 
 Eliminar un procedimiento almacenado
 drop procedure <Nombre_proc>
*/
create procedure usp_MesTotal
@mes int
as
  Select DocDate as Fecha,DocTotal as Monto
       from OINV
       where DocDate>='20260301'
             and DocDate<'20260401'
             and DocTotal=(select max(DocTotal)
                     from OINV
                     where month(DocDate)=@mes)
 go

 exec usp_MesTotal 3
 go

create procedure usp_MesEspecificoTotal
@mes int
as
  Select DocDate as Fecha,DocTotal as Monto
       from OINV
       where Month(DocDate)=@mes
             and DocTotal=(select max(DocTotal)
                     from OINV
                     where month(DocDate)=@mes)
 go

exec usp_MesEspecificoTotal 5
go

exec usp_MesEspecificoTotal 6
go

create procedure usp_MesTotalMinimo
@mes int
as
  Select DocDate as Fecha,DocTotal as Monto
       from OINV
       where Month(DocDate)=@mes
             and DocTotal=(select min(DocTotal)
                     from OINV
                     where month(DocDate)=@mes)
 go

exec usp_MesEspecificoTotal 5
go

exec usp_MesEspecificoTotal 6
go

exec usp_MesTotalMinimo 5
go

exec usp_MesTotalMinimo 6
go

select name,type from sysobjects where type='p'
go

select * from OBPL
select * from OINV

Select a.BPLId,a.BPLName,a.City,b.DocStatus,b.DocDate
from OBPL a inner join OINV b
on(a.BPLId=b.BPLId)

/*Facturas emitidas de una sucursal*/
Select a.BPLId,a.BPLName,a.City,b.DocStatus,b.DocDate
from OBPL a inner join OINV b
on(a.BPLId=b.BPLId)
where a.BPLId=1

create procedure usp_FacturasSucursales
@num int
as 
   Select a.BPLId,a.BPLName,a.City,b.DocStatus,b.DocDate
   from OBPL a inner join OINV b
   on(a.BPLId=b.BPLId)
   where a.BPLId=@num
go

exec usp_FacturasSucursales 1
go
exec usp_FacturasSucursales 3
go
exec usp_FacturasSucursales 4
go

/*Facturas emitidas mayor a una cantidad
   oinv -- a
   ocrd -- b
*/
select * from oinv
go
select * from ocrd
go

Select a.DocNum as Documento,b.CardName as Empresa,
a.DocTotal as Total
from oinv a 
inner join ocrd b
on(b.CardCode=a.CardCode)
where a.DocTotal>=7000
order by a.DocTotal

create view v_totalmayorigual700
as
    Select top 100 a.DocNum as Documento,
    b.CardName as Empresa,
    a.DocTotal as Total
    from oinv a 
    inner join ocrd b
    on(b.CardCode=a.CardCode)
    where a.DocTotal>=7000
    order by a.DocTotal

create procedure usp_totalmayorigual700
as
  select * from v_totalmayorigual700
go

exec usp_totalmayorigual700
go

/*Listar clientes de dos sitios
   oinv -- a
   ocrd -- b
   Operadores logicos
   and --> y --> Rango de numeros
   total>=3000 and total<=5000
   fecha>=1/1/2026 and fecha<=30/1/2026
   or --> O --> Para Textos
   ocupacion="Tecnico" or ocupacion="Asistente"
*/
select * from oinv
go
select * from ocrd
go

Select a.DocNum as Documento,b.City as Distrito,
b.CardName as Empresa
from oinv a 
inner join ocrd b
on(b.CardCode=a.CardCode)
where b.city='Arequipa' or b.city='Lima'
order by b.city 
go

create view v_listadistrito
as
    Select top 100 a.DocNum as Documento,
    b.City as Distrito,
    b.CardName as Empresa
    from oinv a 
    inner join ocrd b
    on(b.CardCode=a.CardCode)
    where b.city='Arequipa' or b.city='Lima'
    order by b.city 
    go

create procedure usp_listadistrito
as
    select * from v_listadistrito
go

exec usp_listadistrito
go

create procedure usp_listadistrito02
@city1 varchar(60),
@city2 varchar(60)
as 
    Select a.DocNum as Documento,b.City as Distrito,
    b.CardName as Empresa
    from oinv a 
    inner join ocrd b
    on(b.CardCode=a.CardCode)
    where b.city=@city1 or b.city=@city2
    order by b.city 
    go

 exec usp_listadistrito02 'Trujillo','Lima'
 go

select * from oinv
go

select * from ocrd
go
 /*oinv -- a
   ocrd -- b*/
Select a.DocNum as Documento,b.City as Distrito,
    b.CardName as Empresa,b.CardType as Tipo
    from oinv a 
    inner join ocrd b
    on(b.CardCode=a.CardCode)
    where b.city='Arequipa' or b.city='Lima'
    and b.CardType='C'
    order by b.city 
    go

Select a.DocNum as Documento,b.City as Distrito,
    b.CardName as Empresa,b.CardType as Tipo
    from oinv a 
    inner join ocrd b
    on(b.CardCode=a.CardCode)
    where b.CardType='S'
    and b.City='Lima'

INSERT INTO OINV (DocEntry,DocNum, CardCode, DocDate, DocDueDate, TaxDate,
DocTotal, PaidToDate,
DocStatus, BPLId, SlpCode, Comments)
VALUES
(21,'1021', 'C0002', '2026-02-25', '2026-03-27', '2026-02-25',
 45000.00, 30000.00, 'C', 3, 1, 'Saldo pendiente'),

(22,'1022', 'C0004', '2026-02-26', '2026-09-25', '2026-07-25',
 90000.00, 80000.00, 'C', 4, 2, 'Saldo pendiente');
 

 
INSERT INTO OINV (DocEntry,DocNum, CardCode, DocDate, DocDueDate, TaxDate,
DocTotal, PaidToDate,
DocStatus, BPLId, SlpCode, Comments)
VALUES   (23,'1023', 'C0002', '2026-02-26', '2026-09-25', '2026-07-25',
 90000.00, 80000.00, 'S', 4, 2, 'Saldo pendiente');
  
INSERT INTO OINV (DocEntry,DocNum, CardCode, DocDate, DocDueDate, TaxDate,
DocTotal, PaidToDate,
DocStatus, BPLId, SlpCode, Comments)
VALUES   (24,'1024', 'P0001', '2026-02-26', '2026-09-25', '2026-07-25',
 90000.00, 80000.00, 'S', 4, 2, 'Saldo pendiente');

INSERT INTO OINV (DocEntry,DocNum, CardCode, DocDate, DocDueDate, TaxDate,
DocTotal, PaidToDate,
DocStatus, BPLId, SlpCode, Comments)
VALUES   (25,'1025', 'P0002', '2026-02-26', '2026-09-25', '2026-07-25',
 90000.00, 80000.00, 'S', 4, 2, 'Saldo pendiente');


/*Todos los clientes y sus facturas
  ocrd -- a (Tabla Izquierda)
  oinv  -- b (Tabla Derecha)
  utilizando left join
*/
select a.Cardcode,a.CardName,b.DocNum,
       b.DocDate,b.DocTotal
from OCRD as a
Left Join Oinv as b
on(a.CardCode=b.CardCode)
where a.CardType='C'
order by a.CardCode,b.DocDate

/*Listar a los clientes y sus pedidos
    OCRD -- a (Tabla Izquierda)
    ORDR ---b (Tabla Derecha)
*/
select a.CardCode,a.CardName,a.CardType,
b.DocNum,b.DocDate,b.DocTotal
from OCRD as a
left join ORDR as b
on(a.CardCode=b.CardCode)
where a.CardType='C'

select a.CardCode,a.CardName,a.CardType,
b.DocNum,b.DocDate,b.DocTotal
from OCRD as a
left join ORDR as b
on(a.CardCode=b.CardCode)

select * from ocrd 
select * from ordr 

/*Listar todas las facturas y sus lineas
    OINV -- a (Tabla izquierda)
    INV1 -- b (Tabla derecha)
*/

select a.DocEntry,a.DocNum,a.CardCode,
       b.LineNum,b.ItemCode,b.Quantity,
       b.Price,b.LineTotal
from OINV as a
left join INV1 as b
on(a.DocEntry=b.DocEntry)

select * from OINV 
select * from INV1 

/*Listar los articulos y sus ventas facturadas
  OITM -- a (Tabla Izquierda)
  INV1 -- b (Tabla derecha)
*/
select a.ItemCode,a.ItemName,a.Price,
       b.DocEntry,b.Quantity,b.Price,b.LineTotal
       from OITM as a
Left Join INV1 as b
on(a.ItemCode=b.ItemCode)
order by a.ItemCode,b.DocEntry desc

select * from OITM 
select * from INV1

/*Listar a los vendedores y sus facturas
    OSLP -- a (Tabla Izquierda)
    OINV -- b (Tabla derecha)
    En ambas tablas el campo en comun: SlpCode
*/
select a.SlpCode,a.SlpName,b.DocNum,
       b.DocDate,b.DocTotal
       from OSLP as a
Left Join OINV b
on(a.SlpCode=b.SlpCode)

select * from oslp
select * from oinv

insert into OINV values(26,1026,'C0002',
    '2026-02-26','2026-09-25','2026-07-25',
    600.21,500.30,'C',2,5,'Pagada')

/*Listar todas las sucursales y sus pedidos
   OBPL -- a -- SUCURSALES
   ORDR -- b -- PEDIDOS
*/
Select a.BPLID,a.BPLName,a.City,
       b.DocNum,b.DocDate,b.DocDueDate,b.DocTotal
from OBPL as a
Left Join ORDR as b
on(a.BPLId=b.BPLId)

select * from OBPL
select * from ORDR

/*Mostrar los clientes, las facturas y el vendedor
   OCRD -- a
   OINV -- b
   OSLP -- c
   OCRD Y OINV (CardCode)
   OSLP Y OINV (SlpCode)
*/
Select a.CardCode,a.CardName,a.City,
b.DocNum,b.DocDate,b.DocTotal,c.SlpName
from OCRD as a
left join OINV as b
ON(a.CardCode=b.CardCode)
left join OSLP as c
on(c.SlpCode=b.SlpCode)

Select a.CardCode,a.CardName,a.CardType,a.City,
b.DocNum,b.DocDate,b.DocTotal,c.SlpName
from OCRD as a
left join OINV as b
ON(a.CardCode=b.CardCode)
left join OSLP as c
on(c.SlpCode=b.SlpCode)
where a.CardType='C'
order by a.CardCode,b.DocDate

select * from OCRD
select * from OINV
select * from OSLP

/*
| Tabla    | Significado                                  | ¿Qué almacena?                             |
| -------- | -------------------------------------------- | ------------------------------------------ |
| **OCRD** | **O** + **CRD** = *Business Partners / Card* | Socios de negocios: clientes y proveedores |
| **OITM** | **O** + **ITM** = *Items*                    | Maestro de artículos/productos             |
| **OSLP** | **O** + **SLP** = *Sales Persons*            | Vendedores                                 |
| **OBPL** | **O** + **BPL** = *Business Places*          | Sucursales / establecimientos              |
| **OINV** | **O** + **INV** = *Invoices*                 | Cabecera de facturas de clientes           |
| **INV1** | **INV** + **1**                              | Líneas/detalle de las facturas             |
| **ORDR** | **O** + **RDR** = *Orders*                   | Cabecera de pedidos de clientes            |
| **RDR1** | **RDR** + **1**                              | Líneas/detalle de los pedidos              |

*/


/*Listar las facturas, el detalle de la factura,
  Nombre del articulo
    OINV -- a -- factura del cliente
    INV1 -- b -- detalle de las facturas
    OITM -- c -- Articulos o productos
  */

    /*Left JOin con las tablas
    OINV -- a -- factura del cliente
    INV1 -- b -- detalle de las facturas
    */
    select a.DocEntry,a.DocNum,a.DocDate,a.DocTotal,
         b.LineNum,b.ItemCode,
         b.Quantity,b.Price,b.LineTotal
         from OINV as a
   left join INV1 as b on(a.DocEntry=b.DocEntry)
   
   /*Left JOin con las tablas
    INV1 -- b -- detalle de las facturas
    OITM -- c -- Articulos o productos
    */
   select b.ItemCode,b.Quantity,b.Price,b.LineTotal,c.ItemName
         from INV1 as b
   left join OITM as c on(c.ItemCode=b.ItemCode)

   /*Left JOin con las tablas
    OINV -- a -- factura del cliente
    INV1 -- b -- detalle de las facturas
    OITM -- c -- Articulos o productos
    */
  select a.DocEntry,a.DocNum,a.DocDate,a.DocTotal,
         b.LineNum,b.ItemCode,c.ItemName,
         b.Quantity,b.Price,b.LineTotal
         from OINV as a
   left join INV1 as b on(a.DocEntry=b.DocEntry)
   left join OITM as c on(c.ItemCode=b.ItemCode)
   order by a.DocNum,b.LineNum

   
  select * from OINV
  select * from INV1
  select * from OITM

  /*Rigth Join
    Muestra toda la informacion de la tabla
    de la tabla y si coincide con la tabla
    de la izquierda, muestra los datos en caso
    contrario se imprime Null
    Listar todos los clientes y sus facturas
    OINV -- a (Tabla derecha)
    OCRD -- b (Tabla izquierda)
    Campo ---> CardCode
  */
  select b.CardCode,b.CardName,b.CardType,b.City,
         a.DocNum,a.DocDate,a.DocTotal
         from OINV as a
  right join OCRD as b on(b.CardCode=a.CardCode)


  select b.CardCode,b.CardName,b.CardType,b.City,
         a.DocNum,a.DocDate,a.DocTotal
         from OCRD as b
  left join OINV as a on(b.CardCode=a.CardCode)

   select b.CardCode,b.CardName,b.CardType,b.City,
         a.DocNum,a.DocDate,a.DocTotal
         from OCRD as b
  inner join OINV as a on(b.CardCode=a.CardCode)

  select * from OINV
  select * from OCRD

  /*Listar todas las facturas y sus lineas
    con Rigth Join
    Inv1 -- a(Tabla Derecha)
    OInv -- b(Tabla Izquierda)
    Campo en comun: DocEntry
    */
    Select a.DocEntry,a.DocNum,a.DocDate,
    b.LineNum,b.ItemCode,b.Quantity,
    b.Price,b.LineTotal
    from INV1 as b
    right join OINV as a
    on(b.DocEntry=a.DocEntry)

    select * from OINV
    select * from INV1
  













