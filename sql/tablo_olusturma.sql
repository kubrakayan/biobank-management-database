create database biyobank_db;
use biyobank_db;

CREATE TABLE HASTA (
  hasta_id INT AUTO_INCREMENT PRIMARY KEY,
  ad            VARCHAR(50)  NOT NULL,
  soyad         VARCHAR(50)  NOT NULL,
  dogum_tarihi  DATE NOT NULL,
  cinsiyet      ENUM('K','E') NOT NULL,
  telefon       VARCHAR(10) NOT NULL,
  email         VARCHAR(50) NOT NULL,
  yakin_telefon VARCHAR(10) NOT NULL,
  tcno          CHAR(11) NOT NULL,
  CONSTRAINT uq_hasta_tcno UNIQUE (tcno),
  CONSTRAINT uq_hasta_email UNIQUE (email),
  CONSTRAINT chk_hasta_tcno CHECK (tcno REGEXP '^[0-9]{11}$'),
  CONSTRAINT chk_hasta_tel CHECK (telefon REGEXP '^[0-9]{10}$'),
  CONSTRAINT chk_hasta_yakin_tel CHECK (yakin_telefon REGEXP '^[0-9]{10}$'),
  CONSTRAINT chk_hasta_email CHECK (email LIKE '%@%')
);

CREATE TABLE DOKTOR (
   doktor_id int NOT NULL AUTO_INCREMENT PRIMARY KEY ,
   ad varchar(50) NOT NULL,
   soyad varchar(50) NOT NULL,
   uzmanlik_alani varchar(40) NOT NULL,
   email varchar(50) NOT NULL,
   telefon varchar(10) NOT NULL,
   UNIQUE KEY uq_doktor_email (email),
   CONSTRAINT chk_doktor_email CHECK ((email like _utf8mb4'%@%')),
   CONSTRAINT chk_doktor_tel CHECK (regexp_like(telefon,_utf8mb4'^[0-9]{10}$'))
 ); 
 
CREATE TABLE depolama_birimi (
   depolama_id int NOT NULL AUTO_INCREMENT PRIMARY KEY ,
   dondurucu_no varchar(20) NOT NULL,
   raf_no varchar(20) NOT NULL,
   oda_kodu varchar(20) NOT NULL,
   sicaklik int NOT NULL,
   kapasite int NOT NULL DEFAULT '50',
   UNIQUE KEY uq_depolama_konum (dondurucu_no,raf_no,oda_kodu),
   CONSTRAINT chk_depolama_kapasite CHECK ((kapasite >= 0)),
   CONSTRAINT chk_depolama_sicaklik CHECK ((sicaklik between -(90) and 30))
 ) ;
 
 CREATE TABLE GENETIK_MARKER (
  marker_id INT AUTO_INCREMENT PRIMARY KEY,
  marker_adi VARCHAR(40) NOT NULL,
  gen_lokasyonu VARCHAR(40) NOT NULL,
  CONSTRAINT uq_marker_adi UNIQUE(marker_adi)
);

CREATE TABLE NUMUNE (
  numune_id INT AUTO_INCREMENT PRIMARY KEY,      
  hasta_id INT NOT NULL,                         
  depolama_id INT NOT NULL,                      
  numune_kodu VARCHAR(30) NOT NULL,              
  alim_tarihi DATE NOT NULL,                    
  numune_turu VARCHAR(30) NOT NULL,              
  saklama_kosulu VARCHAR(60) NOT NULL,           
  tanim VARCHAR(120) NULL,                       
  durum ENUM('AKTIF','TUKENDI','IMHA') NOT NULL DEFAULT 'AKTIF', 
  hacim DECIMAL(8,2) NOT NULL,  
  
  CONSTRAINT uq_numune_kodu UNIQUE (numune_kodu),
  CONSTRAINT chk_numune_hacim CHECK (hacim > 0),
  CONSTRAINT fk_numune_hasta FOREIGN KEY (hasta_id)
    REFERENCES HASTA(hasta_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_numune_depolama FOREIGN KEY (depolama_id)
    REFERENCES DEPOLAMA_BIRIMI(depolama_id)
    ON DELETE RESTRICT
);

CREATE TABLE LAB_TESTI (
  lab_test_id INT AUTO_INCREMENT PRIMARY KEY,
  numune_id INT NOT NULL,
  test_adi VARCHAR(60) NOT NULL,
  test_tarihi DATE NOT NULL,
  sonuc_durumu ENUM('BEKLEMEDE','DEVAM_EDIYOR','TAMAMLANDI','BASARISIZ')
    NOT NULL DEFAULT 'BEKLEMEDE',

  CONSTRAINT fk_test_numune FOREIGN KEY (numune_id)
    REFERENCES NUMUNE(numune_id)
    ON DELETE CASCADE
);

CREATE TABLE SONUC_RAPORU (
  rapor_id INT AUTO_INCREMENT PRIMARY KEY,
  lab_test_id INT NOT NULL,
  hasta_id INT NOT NULL,
  doktor_id INT NOT NULL,
  rapor_tarihi DATE NOT NULL,
  tani_ozeti VARCHAR(200) NOT NULL,
  yorum VARCHAR(300) NULL,
  onay_durumu ENUM('TASLAK','ONAYLANDI','RED') NOT NULL DEFAULT 'TASLAK',
  
  CONSTRAINT fk_rapor_test FOREIGN KEY (lab_test_id)
    REFERENCES LAB_TESTI(lab_test_id)
    ON DELETE CASCADE,
    
  CONSTRAINT fk_rapor_hasta FOREIGN KEY (hasta_id)
    REFERENCES HASTA(hasta_id)
    ON DELETE RESTRICT,
    
  CONSTRAINT fk_rapor_doktor FOREIGN KEY (doktor_id)
    REFERENCES DOKTOR(doktor_id)
    ON DELETE RESTRICT
);

CREATE TABLE NUMUNE_MARKER (
  numune_id INT NOT NULL,
  marker_id INT NOT NULL,
  ifade_duzeyi DECIMAL(10,4) NOT NULL,
  tespit_tarihi DATE NOT NULL,
  PRIMARY KEY (numune_id, marker_id),
  
  CONSTRAINT chk_ifade CHECK (ifade_duzeyi >= 0),
  CONSTRAINT fk_nm_numune FOREIGN KEY (numune_id)
    REFERENCES NUMUNE(numune_id)
    ON DELETE CASCADE,
    
  CONSTRAINT fk_nm_marker FOREIGN KEY (marker_id)
    REFERENCES GENETIK_MARKER(marker_id)
    ON DELETE CASCADE
);

CREATE TABLE NUMUNE_TAKIP_LOG (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  numune_id INT NOT NULL,
  eski_depolama_id INT NULL,
  yeni_depolama_id INT NULL,
  hareket_tarihi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  islem_turu ENUM('ALINDI','TASINDI','CIKARILDI') NOT NULL,

  CONSTRAINT fk_log_numune FOREIGN KEY (numune_id)
    REFERENCES NUMUNE(numune_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_log_eski_dep FOREIGN KEY (eski_depolama_id)
    REFERENCES DEPOLAMA_BIRIMI(depolama_id)
    ON DELETE SET NULL,

  CONSTRAINT fk_log_yeni_dep FOREIGN KEY (yeni_depolama_id)
    REFERENCES DEPOLAMA_BIRIMI(depolama_id)
    ON DELETE SET NULL
);








