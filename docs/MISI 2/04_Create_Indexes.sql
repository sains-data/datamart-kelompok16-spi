-- 1. Clustered Index on Fact Table
-- Mengganti Clustered Index PK_Fact_Temuan_Rekomendasi ke Fact Key & Waktu Key
-- (Waktu_SK adalah kunci utama untuk query DW)
DROP INDEX PK_Fact_Temuan_Rekomendasi ON dbo.Fact_Temuan_Rekomendasi; -- Drop PK Clustered default
CREATE CLUSTERED INDEX CIX_Fact_Temuan_Waktu
ON dbo.Fact_Temuan_Rekomendasi (Waktu_SK, Fakta_SK)
ON PS_AuditYear (Tahun_Audit); -- Index ini juga menggunakan Partition Scheme
GO


-- 2. Non-Clustered Indexes
-- Index untuk Foreign Key Unit Kerja (Optimasi Join Analisis Profil Risiko Unit)
CREATE NONCLUSTERED INDEX IX_Fact_Unit_Key
ON dbo.Fact_Temuan_Rekomendasi (Unit_Kerja_SK)
INCLUDE (Skor_Risiko_Temuan, Potensi_Kerugian_IDR); -- Sering diakses bersama
GO

-- Index untuk Foreign Key Auditor (Optimasi Join Analisis Kinerja Auditor)
CREATE NONCLUSTERED INDEX IX_Fact_Auditor_Key
ON dbo.Fact_Temuan_Rekomendasi (Auditor_SK)
INCLUDE (Jumlah_Temuan, Usia_Rekomendasi_Hari); -- Sering diakses bersama
GO

-- Index untuk Foreign Key Temuan (Mendukung pelacakan temuan dan Rekomendasi)
CREATE NONCLUSTERED INDEX IX_Fact_Temuan_Rekomendasi_Keys
ON dbo.Fact_Temuan_Rekomendasi (Temuan_SK, Rekomendasi_SK);
GO

-- Covering Index untuk common queries (Misalnya, Laporan Tindak Lanjut per Siklus Audit)
CREATE NONCLUSTERED INDEX IX_Fact_Covering_Siklus
ON dbo.Fact_Temuan_Rekomendasi (Siklus_Audit_SK, Waktu_SK)
INCLUDE (Potensi_Kerugian_IDR, Usia_Rekomendasi_Hari);
GO



-- 3. Columnstore Index (for large fact tables)
-- Columnstore index untuk analytical queries (OLAP style)
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fact_Analytic
ON dbo.Fact_Temuan_Rekomendasi (
    Waktu_SK, Auditor_SK, Unit_Kerja_SK, Siklus_Audit_SK, Temuan_SK, Rekomendasi_SK,
    Tahun_Audit,
    Jumlah_Temuan, Skor_Risiko_Temuan, Potensi_Kerugian_IDR, Usia_Rekomendasi_Hari
)
WHERE Tahun_Audit > 2023; -- Fokus pada data terbaru untuk Analitik Cepat
GO
