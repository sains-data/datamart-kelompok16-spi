# 📂 Data Sources Identification (Identifikasi Sumber Data)

Dokumen ini mengidentifikasi dan menganalisis sumber-sumber data yang dibutuhkan untuk membangun Data Mart Satuan Pengawas Internal (SPI).

---

## 1. Identifikasi Sumber Data Utama

Terdapat lima jenis sumber data utama yang relevan untuk kebutuhan analisis SPI:

* **Database Operasional (OLTP):** Database utama dari sistem operasional unit kerja yang diaudit (misalnya, Sistem Keuangan, Sistem HRD, Sistem Pengadaan). Data ini penting untuk audit transaksional dan analisis anomali.
* **Sistem Internal Audit & GRC:** Database atau aplikasi yang digunakan SPI/Unit Kepatuhan untuk mencatat temuan audit, rekomendasi, profil risiko unit kerja, dan laporan insiden/fraud.
* **File Excel/CSV:** Data yang dikelola secara *ad-hoc* oleh unit kerja, seperti daftar aset tetap non-sistem, log manual, atau ringkasan data bulanan yang diekstrak. Data ini seringkali memerlukan validasi tinggi.
* **External APIs/Layanan Eksternal:** Data dari pihak ketiga yang memengaruhi kepatuhan (misalnya, data regulasi terbaru, daftar vendor terlarang, atau data kurs/suku bunga dari bank sentral).
* **Manual Data Entry:** Data kualitatif yang dimasukkan langsung oleh auditor, seperti penilaian risiko inheren, tingkat materialitas, dan justifikasi temuan audit.

---

## 2. Analisis Sumber Data (Data Source Analysis)

Aspek-aspek kritis dari sumber data yang harus dipertimbangkan dalam proses ETL:

| Aspek | Pertimbangan Khusus untuk Data SPI |
| :--- | :--- |
| **Struktur dan Schema** | Variatif. Data OLTP terstruktur, tetapi data dari sistem audit internal mungkin semi-terstruktur (kolom teks bebas). Perlu memetakan **Primary Key** antara temuan audit (SPI) dan transaksi terkait (OLTP). |
| **Volume dan Growth Rate** | Volume **Tinggi** di Sisi Transaksional (Data keuangan/transaksi harian). Data temuan audit SPI volumenya lebih rendah, tetapi pertumbuhannya linear seiring bertambahnya siklus audit. |
| **Kualitas Data** | **Kritis**. Kualitas data dari OLTP harus dipertanyakan dan diverifikasi. Data internal SPI (status tindak lanjut) harus memiliki integritas tinggi. |
| **Frekuensi Update Data** | Bervariasi. Data transaksi (OLTP) mungkin perlu diperbarui **harian** untuk *Continuous Auditing*. Data temuan audit/rekomendasi diperbarui **mingguan**. |

---

## 3. Data Profiling

Data *profiling* adalah langkah penting untuk memahami kualitas data dari perspektif SPI, yang akan memengaruhi temuan audit[cite: 49].

* **Analisis Distribusi Data:** Menganalisis distribusi nilai kunci (misalnya, distribusi jumlah transaksi) untuk mendeteksi anomali pada transaksi besar atau kecil.
* **Identifikasi Null Values dan Outliers:**
    * Mencari nilai kosong (*Null Values*) di kolom penting (misalnya, Tanggal Persetujuan atau Skor Risiko). [cite_start]*Null values* di kolom kontrol bisa menjadi indikasi kelemahan kontrol.
    * Menggunakan statistik (misalnya, Z-score atau IQR) untuk mendeteksi transaksi atau item yang berada di luar batas normal (*Outliers*), yang merupakan fokus utama audit (*red flags*).
* **Deteksi Duplikasi:** Mencari duplikasi entitas (misalnya, vendor atau pegawai yang sama) dan duplikasi transaksi (misalnya, pembayaran yang sama dicatat dua kali)
* **Konsistensi Format Data:** Memastikan format data tanggal, mata uang, dan kode unit kerja konsisten di seluruh sistem sumber.

***
