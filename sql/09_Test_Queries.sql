USE DM_SPI_DW;
GO

-- Aktifkan statistik untuk melihat waktu eksekusi dan I/O
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- TEST SCENARIO 1: Simple Aggregation (Laporan Profil Risiko per Unit)
-- Menguji: Kecepatan Join ke Dimensi Unit Kerja & Waktu + Agregasi SUM
-- Target: < 1 detik
PRINT '>>> Executing Query 1: Risk Profile per Unit ...';

SELECT
    u.Nama_Unit,
    u.Jenis_Unit,
    COUNT(f.Fakta_SK) AS Total_Temuan,
    AVG(f.Skor_Risiko_Temuan) AS Rata_Rata_Risiko,
    SUM(f.Potensi_Kerugian_IDR) AS Total_Potensi_Kerugian
FROM dbo.Fact_Temuan_Rekomendasi f
INNER JOIN dbo.Dim_Unit_Kerja u ON f.Unit_Kerja_SK = u.Unit_Kerja_SK
INNER JOIN dbo.Dim_Waktu w ON f.Waktu_SK = w.Waktu_SK
-- Filter Partition Pruning (Menguji efektivitas partisi Tahun)
WHERE f.Tahun_Audit = 2024
GROUP BY u.Nama_Unit, u.Jenis_Unit
ORDER BY Total_Potensi_Kerugian DESC;
GO


-- TEST SCENARIO 2: Monthly Trend (Tren Temuan Bulanan)
-- Menguji: Kecepatan Grouping berdasarkan Waktu (Partition Elimination)
-- Target: < 2 detik
PRINT '>>> Executing Query 2: Monthly Trends ...';

SELECT
    w.Tahun,
    w.Bulan_Number,
    w.Nama_Bulan,
    COUNT(f.Fakta_SK) AS Jumlah_Temuan_Baru,
    SUM(f.Potensi_Kerugian_IDR) AS Total_Kerugian_Bulan_Ini,
    AVG(f.Usia_Rekomendasi_Hari) AS Avg_Aging_Rekomendasi
FROM dbo.Fact_Temuan_Rekomendasi f
INNER JOIN dbo.Dim_Waktu w ON f.Waktu_SK = w.Waktu_SK
WHERE w.Tahun IN (2024, 2025)
GROUP BY w.Tahun, w.Bulan_Number, w.Nama_Bulan
ORDER BY w.Tahun, w.Bulan_Number;
GO


-- QUERY 3: Drill-down Kinerja Auditor (SCD & Filtering)
-- Tujuan: Menguji filter pada atribut dimensi spesifik
-- Target Optimasi: Non-Clustered Index pada Auditor_SK
PRINT '>>> Executing Query 3: Auditor Performance Drill-down ...';

SELECT
    a.Tim_Audit,
    a.Nama_Auditor,
    COUNT(f.Fakta_SK) AS Temuan_Ditemukan,
    SUM(CASE WHEN r.Status_Tindak_Lanjut = 'Closed' THEN 1 ELSE 0 END) AS Rekomendasi_Selesai
FROM dbo.Fact_Temuan_Rekomendasi f
INNER JOIN dbo.Dim_Auditor a ON f.Auditor_SK = a.Auditor_SK
INNER JOIN dbo.Dim_Rekomendasi r ON f.Rekomendasi_SK = r.Rekomendasi_SK
WHERE a.IsCurrent = 1 -- Hanya auditor status aktif saat ini
GROUP BY a.Tim_Audit, a.Nama_Auditor
ORDER BY Temuan_Ditemukan DESC;
GO




-- Matikan fitur statistik
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

