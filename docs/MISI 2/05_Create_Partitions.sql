-- 1. Membuat Schema Staging (untuk ETL)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg')
END
GO

-- 2. Membuat Partition Function berdasarkan Tahun (untuk Fact Table)
-- Tujuan: Membagi data ke dalam grup berdasarkan Tahun Audit.
-- RANGE RIGHT: Boundary values adalah batas bawah partisi berikutnya.
CREATE PARTITION FUNCTION PF_AuditYear (INT)
AS RANGE RIGHT FOR VALUES (
    2020, -- Partisi 1: Tahun_Audit < 2020 (Historical)
    2021, -- Partisi 2: 2020 <= Tahun_Audit < 2021
    2022, -- Partisi 3: 2021 <= Tahun_Audit < 2022
    2023, -- Partisi 4: 2022 <= Tahun_Audit < 2023
    2024, -- Partisi 5: 2023 <= Tahun_Audit < 2024
    2025  -- Partisi 6: 2024 <= Tahun_Audit < 2025
);
GO

-- 3. Membuat Partition Scheme
-- Tujuan: Memetakan setiap partisi dari Partition Function ke Filegroup tertentu.
-- ALL TO ([PRIMARY]) berarti semua partisi disimpan di Filegroup utama (untuk lingkungan sederhana).
CREATE PARTITION SCHEME PS_AuditYear
AS PARTITION PF_AuditYear
ALL TO ([PRIMARY]);
GO
