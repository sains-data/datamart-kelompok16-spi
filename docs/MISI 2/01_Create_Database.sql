CREATE DATABASE DM_SPI_DW
ON PRIMARY
(
    NAME = DM_SPI_DW_Data,
    FILENAME = 'C:\Data\DM_SPI_DW_Data.mdf',
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME = DM_SPI_DW_Log,
    FILENAME = 'C:\Data\DM_SPI_DW_Log.ldf',
    SIZE = 10MB,
    MAXSIZE = 2048GB,
    FILEGROWTH = 10%
);
GO

PRINT 'Database DM_SPI_DW berhasil dibuat.'

USE DM_SPI_DW;
GO
