 --CREATE DATABASE SmartMatchDB;
 --GO
 --USE SmartMatchDB;
 --GO

-- 1. Tabela de Estudantes
CREATE TABLE Estudantes (
    ID_Estudante INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(100) NOT NULL,
    Curso NVARCHAR(100) NOT NULL,
    Pref_Localizacao NVARCHAR(50),
    Pref_ModeloTrabalho NVARCHAR(50) 
);

-- 2. Tabela de Vagas
CREATE TABLE Vagas (
    ID_Vaga INT PRIMARY KEY IDENTITY(1,1),
    Empresa NVARCHAR(100) NOT NULL,
    Titulo_Vaga NVARCHAR(100) NOT NULL,
    Localizacao NVARCHAR(50),
    ModeloTrabalho NVARCHAR(50),
    -- Pesos definidos pela empresa para o algoritmo
    Peso_HardSkills DECIMAL(3,2) DEFAULT 0.65,
    Peso_SoftSkills DECIMAL(3,2) DEFAULT 0.25,
    Peso_Logistica DECIMAL(3,2) DEFAULT 0.10
);

-- 3. Tabela Catálogo de Competências (Skills globais do sistema)
CREATE TABLE Competencias (
    ID_Competencia INT PRIMARY KEY IDENTITY(1,1),
    Nome_Competencia NVARCHAR(50) NOT NULL,
    Tipo NVARCHAR(20) CHECK (Tipo IN ('Hard Skill', 'Soft Skill'))
);

-- 4. Tabela de Relacionamento: O que o Estudante sabe?
CREATE TABLE Estudante_Competencias (
    ID_Estudante INT FOREIGN KEY REFERENCES Estudantes(ID_Estudante),
    ID_Competencia INT FOREIGN KEY REFERENCES Competencias(ID_Competencia),
    PRIMARY KEY (ID_Estudante, ID_Competencia)
);

-- 5. Tabela de Relacionamento: O que a Vaga exige? (Com critério eliminatório)
CREATE TABLE Vaga_Competencias (
    ID_Vaga INT FOREIGN KEY REFERENCES Vagas(ID_Vaga),
    ID_Competencia INT FOREIGN KEY REFERENCES Competencias(ID_Competencia),
    Obrigatorio BIT DEFAULT 0, -- 1 (True) se for eliminatório, 0 (False) se for preferencial
    PRIMARY KEY (ID_Vaga, ID_Competencia)
);

-- 6. Tabela de Recomendações 
CREATE TABLE Recomendacoes (
    ID_Recomendacao INT PRIMARY KEY IDENTITY(1,1),
    ID_Estudante INT FOREIGN KEY REFERENCES Estudantes(ID_Estudante),
    ID_Vaga INT FOREIGN KEY REFERENCES Vagas(ID_Vaga),
    Score_Total DECIMAL(5,2),       -- Score final calculado (Ex: 85.50%)
    Score_HardSkills DECIMAL(5,2),  -- Detalhe para o Dashboard
    Score_SoftSkills DECIMAL(5,2),  -- Detalhe para o Dashboard
    Score_Logistica DECIMAL(5,2),   -- Detalhe para o Dashboard
    Data_Calculo DATETIME DEFAULT GETDATE()
);
-- Melhoria
ALTER TABLE Estudante_Competencias
ADD Nivel NVARCHAR(20) CHECK (Nivel IN ('Basico', 'Intermedio', 'Avancado'));

ALTER TABLE Vaga_Competencias
ADD Nivel_Minimo NVARCHAR(20) CHECK (Nivel_Minimo IN ('Basico', 'Intermedio', 'Avancado'));

---------------------------INSERTS-----------------------------
INSERT INTO Competencias (Nome_Competencia, Tipo) VALUES 
('Python', 'Hard Skill'),          
('SQL', 'Hard Skill'),            
('Power BI', 'Hard Skill'),           
('Excel Avançado', 'Hard Skill'), 
('Comunicação', 'Soft Skill'),        
('Trabalho em Equipa', 'Soft Skill'), 
('Liderança', 'Soft Skill'),          
('Resolução de Problemas', 'Soft Skill'),
('Penetration Testing', 'Hard Skill'),
('Criptografia', 'Hard Skill'),
('Firewalls e VPNs', 'Hard Skill'),
('Análise de Malware', 'Hard Skill'),
('Gestão de Identidade (IAM)', 'Hard Skill'),
('Segurança em Cloud (AWS/Azure)', 'Hard Skill'),
('Ethical Hacking', 'Hard Skill'),
('Ferramentas SIEM', 'Hard Skill'),
('Resposta a Incidentes', 'Hard Skill'),
('Análise de Vulnerabilidades', 'Hard Skill'),
('Segurança de Redes (TCP/IP)', 'Hard Skill'),
('Forense Digital', 'Hard Skill'),
('DevSecOps', 'Hard Skill'),
('Normas ISO 27001', 'Hard Skill'),
('Segurança Linux/Unix', 'Hard Skill'),
('Pensamento Crítico', 'Soft Skill'),
('Atenção ao Detalhe', 'Soft Skill'),
('Gestão de Stress', 'Soft Skill'),
('Ética e Integridade', 'Soft Skill'),
('Adaptabilidade', 'Soft Skill'),
('Negociação', 'Soft Skill'),
('Auditoria de TI', 'Hard Skill'),
('Arquitetura Zero Trust', 'Hard Skill'),
('Gestão de Risco', 'Hard Skill'),
('Empatia', 'Soft Skill'),
('Proatividade', 'Soft Skill');

-- =============================================
-- DECLARAÇÃO DE VARIÁVEIS PARA OS IDs DAS VAGAS
-- =============================================
DECLARE
    -- NOS
    @IdVaga_NOS_Cyber INT, @IdVaga_NOS_Redes INT,
    -- Altice
    @IdVaga_Altice_SOC INT, @IdVaga_Altice_DevSec INT, @IdVaga_Altice_Incidentes INT,
    -- Claranet
    @IdVaga_Clara_Cloud INT, @IdVaga_Clara_Pentest INT,
    -- Accenture
    @IdVaga_Acc_Risk INT, @IdVaga_Acc_Hacking INT, @IdVaga_Acc_IAM INT,
    -- PwC
    @IdVaga_PwC_Audit INT, @IdVaga_PwC_Risco INT,
    -- Deloitte
    @IdVaga_Del_Cyber INT, @IdVaga_Del_Forense INT, @IdVaga_Del_ISO INT,
    -- EY
    @IdVaga_EY_Cloud INT, @IdVaga_EY_Vuln INT,
    -- KPMG
    @IdVaga_KPMG_Threat INT, @IdVaga_KPMG_Audit INT,
    -- Capgemini
    @IdVaga_Cap_AppSec INT, @IdVaga_Cap_ZeroTrust INT, @IdVaga_Cap_SIEM INT,
    -- Novabase
    @IdVaga_Nova_Redes INT, @IdVaga_Nova_Malware INT,
    -- CGD
    @IdVaga_CGD_Cyber INT, @IdVaga_CGD_Risco INT, @IdVaga_CGD_IAM INT,
    -- Millennium
    @IdVaga_Mill_Aware INT, @IdVaga_Mill_RGPD INT,
    -- Vodafone
    @IdVaga_Voda_Telco INT, @IdVaga_Voda_RedTeam INT,
    -- Banco de Portugal
    @IdVaga_BdP_Super INT, @IdVaga_BdP_Risco INT,
    -- S21sec
    @IdVaga_S21_SOC INT, @IdVaga_S21_Hunt INT, @IdVaga_S21_Incidentes INT;

-- =============================================
-- INSERTS DAS VAGAS + CAPTURA DE IDs
-- =============================================

-- ----- NOS -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('NOS', 'Estágio em Cibersegurança', 'Lisboa', 'Hibrido', 0.65, 0.25, 0.10);
SET @IdVaga_NOS_Cyber = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('NOS', 'Estágio em Análise de Redes', 'Lisboa', 'Presencial', 0.70, 0.20, 0.10);
SET @IdVaga_NOS_Redes = SCOPE_IDENTITY();

-- ----- Altice Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Altice Portugal', 'Estágio em Security Operations Center (SOC)', 'Lisboa', 'Hibrido', 0.70, 0.20, 0.10);
SET @IdVaga_Altice_SOC = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Altice Portugal', 'Estágio em DevSecOps', 'Lisboa', 'Remoto', 0.65, 0.25, 0.10);
SET @IdVaga_Altice_DevSec = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Altice Portugal', 'Estágio em Resposta a Incidentes', 'Lisboa', 'Presencial', 0.65, 0.25, 0.10);
SET @IdVaga_Altice_Incidentes = SCOPE_IDENTITY();

-- ----- Claranet Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Claranet Portugal', 'Estágio em Cloud Security', 'Porto', 'Hibrido', 0.65, 0.25, 0.10);
SET @IdVaga_Clara_Cloud = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Claranet Portugal', 'Estágio em Penetration Testing', 'Porto', 'Presencial', 0.75, 0.15, 0.10);
SET @IdVaga_Clara_Pentest = SCOPE_IDENTITY();

-- ----- Accenture Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Accenture Portugal', 'Estágio em Cyber Risk & Compliance', 'Lisboa', 'Hibrido', 0.60, 0.30, 0.10);
SET @IdVaga_Acc_Risk = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Accenture Portugal', 'Estágio em Ethical Hacking', 'Lisboa', 'Hibrido', 0.70, 0.20, 0.10);
SET @IdVaga_Acc_Hacking = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Accenture Portugal', 'Estágio em Gestão de Identidade (IAM)', 'Lisboa', 'Remoto', 0.65, 0.25, 0.10);
SET @IdVaga_Acc_IAM = SCOPE_IDENTITY();

-- ----- PwC Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('PwC Portugal', 'Estágio em Auditoria de TI', 'Lisboa', 'Hibrido', 0.60, 0.30, 0.10);
SET @IdVaga_PwC_Audit = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('PwC Portugal', 'Estágio em Gestão de Risco Tecnológico', 'Lisboa', 'Hibrido', 0.55, 0.35, 0.10);
SET @IdVaga_PwC_Risco = SCOPE_IDENTITY();

-- ----- Deloitte Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Deloitte Portugal', 'Estágio em Cibersegurança e Privacidade', 'Lisboa', 'Hibrido', 0.60, 0.30, 0.10);
SET @IdVaga_Del_Cyber = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Deloitte Portugal', 'Estágio em Forense Digital', 'Lisboa', 'Presencial', 0.70, 0.20, 0.10);
SET @IdVaga_Del_Forense = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Deloitte Portugal', 'Estágio em Normas ISO 27001', 'Porto', 'Hibrido', 0.60, 0.30, 0.10);
SET @IdVaga_Del_ISO = SCOPE_IDENTITY();

-- ----- EY Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('EY Portugal', 'Estágio em Segurança em Cloud', 'Lisboa', 'Hibrido', 0.65, 0.25, 0.10);
SET @IdVaga_EY_Cloud = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('EY Portugal', 'Estágio em Análise de Vulnerabilidades', 'Lisboa', 'Presencial', 0.70, 0.20, 0.10);
SET @IdVaga_EY_Vuln = SCOPE_IDENTITY();

-- ----- KPMG Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('KPMG Portugal', 'Estágio em Cyber Threat Intelligence', 'Lisboa', 'Hibrido', 0.65, 0.25, 0.10);
SET @IdVaga_KPMG_Threat = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('KPMG Portugal', 'Estágio em Conformidade e Auditoria de Sistemas', 'Lisboa', 'Hibrido', 0.55, 0.35, 0.10);
SET @IdVaga_KPMG_Audit = SCOPE_IDENTITY();

-- ----- Capgemini Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Capgemini Portugal', 'Estágio em Segurança de Aplicações', 'Lisboa', 'Remoto', 0.65, 0.25, 0.10);
SET @IdVaga_Cap_AppSec = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Capgemini Portugal', 'Estágio em Arquitetura Zero Trust', 'Lisboa', 'Hibrido', 0.70, 0.20, 0.10);
SET @IdVaga_Cap_ZeroTrust = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Capgemini Portugal', 'Estágio em SIEM e Monitorização', 'Porto', 'Hibrido', 0.70, 0.20, 0.10);
SET @IdVaga_Cap_SIEM = SCOPE_IDENTITY();

-- ----- Novabase -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Novabase', 'Estágio em Segurança de Redes', 'Lisboa', 'Presencial', 0.70, 0.20, 0.10);
SET @IdVaga_Nova_Redes = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Novabase', 'Estágio em Análise de Malware', 'Lisboa', 'Presencial', 0.75, 0.15, 0.10);
SET @IdVaga_Nova_Malware = SCOPE_IDENTITY();

-- ----- CGD -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('CGD', 'Estágio em Cibersegurança Bancária', 'Lisboa', 'Presencial', 0.65, 0.25, 0.10);
SET @IdVaga_CGD_Cyber = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('CGD', 'Estágio em Gestão de Risco e Conformidade', 'Lisboa', 'Hibrido', 0.55, 0.35, 0.10);
SET @IdVaga_CGD_Risco = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('CGD', 'Estágio em Controlo de Acessos (IAM)', 'Lisboa', 'Presencial', 0.65, 0.25, 0.10);
SET @IdVaga_CGD_IAM = SCOPE_IDENTITY();

-- ----- Millennium BCP -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Millennium BCP', 'Estágio em Security Awareness', 'Lisboa', 'Hibrido', 0.50, 0.40, 0.10);
SET @IdVaga_Mill_Aware = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Millennium BCP', 'Estágio em Proteção de Dados e RGPD', 'Lisboa', 'Hibrido', 0.55, 0.35, 0.10);
SET @IdVaga_Mill_RGPD = SCOPE_IDENTITY();

-- ----- Vodafone Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Vodafone Portugal', 'Estágio em Segurança de Telecomunicações', 'Lisboa', 'Hibrido', 0.65, 0.25, 0.10);
SET @IdVaga_Voda_Telco = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Vodafone Portugal', 'Estágio em Ethical Hacking e Red Team', 'Lisboa', 'Presencial', 0.75, 0.15, 0.10);
SET @IdVaga_Voda_RedTeam = SCOPE_IDENTITY();

-- ----- Banco de Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Banco de Portugal', 'Estágio em Supervisão de Cibersegurança', 'Lisboa', 'Presencial', 0.60, 0.30, 0.10);
SET @IdVaga_BdP_Super = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('Banco de Portugal', 'Estágio em Análise de Risco Operacional', 'Lisboa', 'Presencial', 0.55, 0.35, 0.10);
SET @IdVaga_BdP_Risco = SCOPE_IDENTITY();

-- ----- S21sec Portugal -----
INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('S21sec Portugal', 'Estágio em SOC Analyst', 'Porto', 'Hibrido', 0.70, 0.20, 0.10);
SET @IdVaga_S21_SOC = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('S21sec Portugal', 'Estágio em Threat Hunting', 'Porto', 'Presencial', 0.75, 0.15, 0.10);
SET @IdVaga_S21_Hunt = SCOPE_IDENTITY();

INSERT INTO Vagas (Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica)
VALUES ('S21sec Portugal', 'Estágio em Resposta a Incidentes Avançada', 'Porto', 'Presencial', 0.70, 0.20, 0.10);
SET @IdVaga_S21_Incidentes = SCOPE_IDENTITY();


-- =============================================
-- INSERTS EM Vaga_Competencias
-- usando as variáveis capturadas acima
-- IDs das Competencias (pela ordem do INSERT inicial):
--  1=Python, 2=SQL, 3=Power BI, 4=Excel Avançado
--  5=Comunicação, 6=Trabalho em Equipa, 7=Liderança, 8=Resolução de Problemas
--  9=Penetration Testing, 10=Criptografia, 11=Firewalls e VPNs, 12=Análise de Malware
-- 13=Gestão de Identidade (IAM), 14=Segurança em Cloud, 15=Ethical Hacking
-- 16=Ferramentas SIEM, 17=Resposta a Incidentes, 18=Análise de Vulnerabilidades
-- 19=Segurança de Redes (TCP/IP), 20=Forense Digital, 21=DevSecOps
-- 22=Normas ISO 27001, 23=Segurança Linux/Unix, 24=Pensamento Crítico
-- 25=Atenção ao Detalhe, 26=Gestão de Stress, 27=Ética e Integridade
-- 28=Adaptabilidade, 29=Negociação, 30=Auditoria de TI
-- 31=Arquitetura Zero Trust, 32=Gestão de Risco, 33=Empatia, 34=Proatividade
-- =============================================

-- NOS — Cibersegurança
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Cyber, 11, 1, 'Intermedio'); -- Firewalls (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Cyber, 19, 1, 'Intermedio'); -- Seg. Redes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Cyber, 10, 0, 'Basico');     -- Criptografia
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Cyber, 27, 0, 'Basico');     -- Ética
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Cyber, 8,  0, 'Basico');     -- Resolução Problemas

-- NOS — Análise de Redes
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Redes, 19, 1, 'Intermedio'); -- Seg. Redes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Redes, 11, 1, 'Basico');     -- Firewalls (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Redes, 2,  0, 'Basico');     -- SQL
INSERT INTO Vaga_Competencias VALUES (@IdVaga_NOS_Redes, 24, 0, 'Basico');     -- Pensamento Crítico

-- Altice — SOC
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_SOC, 16, 1, 'Intermedio'); -- SIEM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_SOC, 17, 1, 'Basico');     -- Resposta Incidentes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_SOC, 19, 0, 'Basico');     -- Seg. Redes
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_SOC, 25, 0, 'Basico');     -- Atenção ao Detalhe
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_SOC, 26, 0, 'Basico');     -- Gestão de Stress

-- Altice — DevSecOps
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_DevSec, 21, 1, 'Intermedio'); -- DevSecOps (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_DevSec, 1,  1, 'Intermedio'); -- Python (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_DevSec, 14, 0, 'Basico');     -- Seg. Cloud
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_DevSec, 28, 0, 'Basico');     -- Adaptabilidade

-- Altice — Resposta a Incidentes
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_Incidentes, 17, 1, 'Intermedio'); -- Resp. Incidentes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_Incidentes, 16, 1, 'Basico');     -- SIEM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_Incidentes, 12, 0, 'Basico');     -- Análise Malware
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_Incidentes, 8,  0, 'Intermedio'); -- Resolução Problemas
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Altice_Incidentes, 26, 0, 'Basico');     -- Gestão de Stress

-- Claranet — Cloud Security
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Cloud, 14, 1, 'Intermedio'); -- Seg. Cloud (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Cloud, 13, 0, 'Basico');     -- IAM
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Cloud, 31, 0, 'Basico');     -- Zero Trust
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Cloud, 28, 0, 'Basico');     -- Adaptabilidade

-- Claranet — Penetration Testing
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Pentest, 9,  1, 'Intermedio'); -- Pentest (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Pentest, 15, 1, 'Basico');     -- Ethical Hacking (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Pentest, 18, 0, 'Intermedio'); -- Análise Vuln.
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Pentest, 23, 0, 'Basico');     -- Seg. Linux
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Clara_Pentest, 24, 0, 'Intermedio'); -- Pensamento Crítico

-- Accenture — Cyber Risk
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_Risk, 32, 1, 'Basico');     -- Gestão de Risco (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_Risk, 22, 0, 'Basico');     -- ISO 27001
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_Risk, 5,  0, 'Intermedio'); -- Comunicação
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_Risk, 29, 0, 'Basico');     -- Negociação

-- Accenture — Ethical Hacking
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_Hacking, 15, 1, 'Intermedio'); -- Ethical Hacking (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_Hacking, 9,  1, 'Basico');     -- Pentest (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_Hacking, 18, 0, 'Intermedio'); -- Análise Vuln.
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_Hacking, 27, 0, 'Intermedio'); -- Ética

-- Accenture — IAM
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_IAM, 13, 1, 'Intermedio'); -- IAM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_IAM, 31, 0, 'Basico');     -- Zero Trust
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_IAM, 14, 0, 'Basico');     -- Seg. Cloud
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Acc_IAM, 6,  0, 'Basico');     -- Trabalho Equipa

-- PwC — Auditoria de TI
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Audit, 30, 1, 'Intermedio'); -- Auditoria TI (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Audit, 22, 0, 'Basico');     -- ISO 27001
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Audit, 2,  0, 'Basico');     -- SQL
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Audit, 25, 0, 'Intermedio'); -- Atenção ao Detalhe
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Audit, 5,  0, 'Intermedio'); -- Comunicação

-- PwC — Gestão de Risco
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Risco, 32, 1, 'Intermedio'); -- Gestão de Risco (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Risco, 22, 0, 'Basico');     -- ISO 27001
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Risco, 5,  0, 'Intermedio'); -- Comunicação
INSERT INTO Vaga_Competencias VALUES (@IdVaga_PwC_Risco, 7,  0, 'Basico');     -- Liderança

-- Deloitte — Cibersegurança e Privacidade
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_Cyber, 10, 1, 'Basico');     -- Criptografia (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_Cyber, 22, 0, 'Basico');     -- ISO 27001
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_Cyber, 32, 0, 'Basico');     -- Gestão Risco
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_Cyber, 27, 0, 'Intermedio'); -- Ética

-- Deloitte — Forense Digital
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_Forense, 20, 1, 'Intermedio'); -- Forense Digital (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_Forense, 12, 1, 'Basico');     -- Análise Malware (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_Forense, 24, 0, 'Intermedio'); -- Pensamento Crítico
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_Forense, 25, 0, 'Intermedio'); -- Atenção ao Detalhe

-- Deloitte — ISO 27001
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_ISO, 22, 1, 'Intermedio'); -- ISO 27001 (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_ISO, 32, 1, 'Basico');     -- Gestão Risco (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_ISO, 30, 0, 'Basico');     -- Auditoria TI
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Del_ISO, 5,  0, 'Intermedio'); -- Comunicação

-- EY — Segurança em Cloud
INSERT INTO Vaga_Competencias VALUES (@IdVaga_EY_Cloud, 14, 1, 'Intermedio'); -- Seg. Cloud (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_EY_Cloud, 13, 0, 'Basico');     -- IAM
INSERT INTO Vaga_Competencias VALUES (@IdVaga_EY_Cloud, 31, 0, 'Basico');     -- Zero Trust
INSERT INTO Vaga_Competencias VALUES (@IdVaga_EY_Cloud, 34, 0, 'Basico');     -- Proatividade

-- EY — Análise de Vulnerabilidades
INSERT INTO Vaga_Competencias VALUES (@IdVaga_EY_Vuln, 18, 1, 'Intermedio'); -- Análise Vuln. (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_EY_Vuln, 9,  0, 'Basico');     -- Pentest
INSERT INTO Vaga_Competencias VALUES (@IdVaga_EY_Vuln, 16, 0, 'Basico');     -- SIEM
INSERT INTO Vaga_Competencias VALUES (@IdVaga_EY_Vuln, 24, 0, 'Intermedio'); -- Pensamento Crítico

-- KPMG — Cyber Threat Intelligence
INSERT INTO Vaga_Competencias VALUES (@IdVaga_KPMG_Threat, 16, 1, 'Intermedio'); -- SIEM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_KPMG_Threat, 18, 0, 'Basico');     -- Análise Vuln.
INSERT INTO Vaga_Competencias VALUES (@IdVaga_KPMG_Threat, 24, 0, 'Intermedio'); -- Pensamento Crítico
INSERT INTO Vaga_Competencias VALUES (@IdVaga_KPMG_Threat, 8,  0, 'Intermedio'); -- Resolução Problemas

-- KPMG — Conformidade e Auditoria
INSERT INTO Vaga_Competencias VALUES (@IdVaga_KPMG_Audit, 30, 1, 'Intermedio'); -- Auditoria TI (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_KPMG_Audit, 22, 1, 'Basico');     -- ISO 27001 (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_KPMG_Audit, 32, 0, 'Basico');     -- Gestão Risco
INSERT INTO Vaga_Competencias VALUES (@IdVaga_KPMG_Audit, 25, 0, 'Intermedio'); -- Atenção ao Detalhe

-- Capgemini — Segurança de Aplicações
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_AppSec, 21, 1, 'Basico');     -- DevSecOps (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_AppSec, 1,  1, 'Intermedio'); -- Python (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_AppSec, 18, 0, 'Basico');     -- Análise Vuln.
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_AppSec, 28, 0, 'Basico');     -- Adaptabilidade

-- Capgemini — Zero Trust
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_ZeroTrust, 31, 1, 'Intermedio'); -- Zero Trust (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_ZeroTrust, 13, 1, 'Basico');     -- IAM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_ZeroTrust, 14, 0, 'Basico');     -- Seg. Cloud
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_ZeroTrust, 19, 0, 'Basico');     -- Seg. Redes

-- Capgemini — SIEM
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_SIEM, 16, 1, 'Intermedio'); -- SIEM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_SIEM, 17, 0, 'Basico');     -- Resp. Incidentes
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_SIEM, 25, 0, 'Intermedio'); -- Atenção ao Detalhe
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Cap_SIEM, 34, 0, 'Basico');     -- Proatividade

-- Novabase — Segurança de Redes
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Nova_Redes, 19, 1, 'Intermedio'); -- Seg. Redes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Nova_Redes, 11, 1, 'Intermedio'); -- Firewalls (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Nova_Redes, 10, 0, 'Basico');     -- Criptografia
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Nova_Redes, 23, 0, 'Basico');     -- Seg. Linux

-- Novabase — Análise de Malware
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Nova_Malware, 12, 1, 'Intermedio'); -- Análise Malware (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Nova_Malware, 20, 1, 'Basico');     -- Forense Digital (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Nova_Malware, 23, 0, 'Intermedio'); -- Seg. Linux
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Nova_Malware, 24, 0, 'Intermedio'); -- Pensamento Crítico

-- CGD — Cibersegurança Bancária
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_Cyber, 19, 1, 'Basico');     -- Seg. Redes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_Cyber, 10, 1, 'Basico');     -- Criptografia (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_Cyber, 32, 0, 'Basico');     -- Gestão Risco
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_Cyber, 27, 0, 'Intermedio'); -- Ética

-- CGD — Gestão de Risco
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_Risco, 32, 1, 'Intermedio'); -- Gestão Risco (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_Risco, 22, 0, 'Basico');     -- ISO 27001
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_Risco, 5,  0, 'Intermedio'); -- Comunicação
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_Risco, 33, 0, 'Basico');     -- Empatia

-- CGD — IAM
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_IAM, 13, 1, 'Intermedio'); -- IAM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_IAM, 31, 0, 'Basico');     -- Zero Trust
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_IAM, 25, 0, 'Intermedio'); -- Atenção ao Detalhe
INSERT INTO Vaga_Competencias VALUES (@IdVaga_CGD_IAM, 6,  0, 'Basico');     -- Trabalho Equipa

-- Millennium — Security Awareness
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_Aware, 5,  1, 'Intermedio'); -- Comunicação (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_Aware, 7,  0, 'Basico');     -- Liderança
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_Aware, 27, 0, 'Intermedio'); -- Ética
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_Aware, 33, 0, 'Basico');     -- Empatia
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_Aware, 34, 0, 'Basico');     -- Proatividade

-- Millennium — RGPD
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_RGPD, 32, 1, 'Basico');     -- Gestão Risco (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_RGPD, 22, 0, 'Basico');     -- ISO 27001
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_RGPD, 5,  0, 'Intermedio'); -- Comunicação
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Mill_RGPD, 27, 0, 'Intermedio'); -- Ética

-- Vodafone — Segurança de Telecomunicações
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_Telco, 19, 1, 'Intermedio'); -- Seg. Redes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_Telco, 11, 1, 'Basico');     -- Firewalls (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_Telco, 10, 0, 'Basico');     -- Criptografia
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_Telco, 28, 0, 'Basico');     -- Adaptabilidade

-- Vodafone — Red Team
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_RedTeam, 15, 1, 'Avancado');  -- Ethical Hacking (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_RedTeam, 9,  1, 'Intermedio'); -- Pentest (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_RedTeam, 18, 0, 'Intermedio'); -- Análise Vuln.
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_RedTeam, 23, 0, 'Intermedio'); -- Seg. Linux
INSERT INTO Vaga_Competencias VALUES (@IdVaga_Voda_RedTeam, 24, 0, 'Avancado');  -- Pensamento Crítico

-- Banco de Portugal — Supervisão
INSERT INTO Vaga_Competencias VALUES (@IdVaga_BdP_Super, 30, 1, 'Intermedio'); -- Auditoria TI (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_BdP_Super, 22, 1, 'Basico');     -- ISO 27001 (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_BdP_Super, 5,  0, 'Intermedio'); -- Comunicação
INSERT INTO Vaga_Competencias VALUES (@IdVaga_BdP_Super, 27, 0, 'Avancado');  -- Ética

-- Banco de Portugal — Risco Operacional
INSERT INTO Vaga_Competencias VALUES (@IdVaga_BdP_Risco, 32, 1, 'Intermedio'); -- Gestão Risco (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_BdP_Risco, 2,  0, 'Basico');     -- SQL
INSERT INTO Vaga_Competencias VALUES (@IdVaga_BdP_Risco, 3,  0, 'Basico');     -- Power BI
INSERT INTO Vaga_Competencias VALUES (@IdVaga_BdP_Risco, 25, 0, 'Intermedio'); -- Atenção ao Detalhe

-- S21sec — SOC Analyst
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_SOC, 16, 1, 'Intermedio'); -- SIEM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_SOC, 17, 1, 'Basico');     -- Resp. Incidentes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_SOC, 19, 0, 'Basico');     -- Seg. Redes
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_SOC, 26, 0, 'Intermedio'); -- Gestão Stress
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_SOC, 25, 0, 'Intermedio'); -- Atenção ao Detalhe

-- S21sec — Threat Hunting
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Hunt, 16, 1, 'Avancado');  -- SIEM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Hunt, 18, 1, 'Intermedio'); -- Análise Vuln. (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Hunt, 12, 0, 'Intermedio'); -- Análise Malware
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Hunt, 24, 0, 'Avancado');  -- Pensamento Crítico

-- S21sec — Resposta a Incidentes Avançada
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Incidentes, 17, 1, 'Avancado');  -- Resp. Incidentes (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Incidentes, 16, 1, 'Intermedio'); -- SIEM (obrig.)
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Incidentes, 20, 0, 'Intermedio'); -- Forense Digital
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Incidentes, 12, 0, 'Intermedio'); -- Análise Malware
INSERT INTO Vaga_Competencias VALUES (@IdVaga_S21_Incidentes, 26, 0, 'Intermedio'); -- Gestão Stress


-- =============================================
-- DECLARAÇÃO DE VARIÁVEIS PARA IDs DOS ESTUDANTES
-- =============================================
DECLARE
    @IdEst_Ana INT, @IdEst_Bruno INT, @IdEst_Carolina INT, @IdEst_David INT,
    @IdEst_Elisa INT, @IdEst_Filipe INT, @IdEst_Goncalo INT, @IdEst_Helena INT,
    @IdEst_Ines INT, @IdEst_Joao INT, @IdEst_Katia INT, @IdEst_Luis INT,
    @IdEst_Mariana INT, @IdEst_Nuno INT, @IdEst_Olivia INT, @IdEst_Pedro INT,
    @IdEst_Rita INT, @IdEst_Samuel INT, @IdEst_Tania INT, @IdEst_Vitor INT,
    @IdEst_Xana INT, @IdEst_Yuri INT, @IdEst_Zelia INT, @IdEst_Afonso INT,
    @IdEst_Beatriz INT, @IdEst_Carlos INT, @IdEst_Diana INT;

-- =============================================
-- INSERT DOS 27 ESTUDANTES
-- =============================================

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Ana Ferreira', 'Engenharia Informática', 'Lisboa', 'Hibrido');
SET @IdEst_Ana = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Bruno Martins', 'Cibersegurança', 'Lisboa', 'Presencial');
SET @IdEst_Bruno = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Carolina Silva', 'Sistemas de Informação', 'Porto', 'Remoto');
SET @IdEst_Carolina = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('David Rodrigues', 'Cibersegurança', 'Lisboa', 'Hibrido');
SET @IdEst_David = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Elisa Costa', 'Engenharia Informática', 'Porto', 'Hibrido');
SET @IdEst_Elisa = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Filipe Sousa', 'Redes e Comunicações', 'Lisboa', 'Presencial');
SET @IdEst_Filipe = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Gonçalo Pereira', 'Cibersegurança', 'Porto', 'Presencial');
SET @IdEst_Goncalo = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Helena Carvalho', 'Gestão de Sistemas de Informação', 'Lisboa', 'Hibrido');
SET @IdEst_Helena = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Inês Lopes', 'Engenharia Informática', 'Lisboa', 'Remoto');
SET @IdEst_Ines = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('João Santos', 'Cibersegurança', 'Lisboa', 'Presencial');
SET @IdEst_Joao = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Kátia Mendes', 'Sistemas de Informação', 'Porto', 'Hibrido');
SET @IdEst_Katia = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Luís Oliveira', 'Redes e Comunicações', 'Porto', 'Presencial');
SET @IdEst_Luis = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Mariana Neves', 'Gestão de Sistemas de Informação', 'Lisboa', 'Hibrido');
SET @IdEst_Mariana = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Nuno Teixeira', 'Cibersegurança', 'Lisboa', 'Hibrido');
SET @IdEst_Nuno = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Olívia Pinto', 'Engenharia Informática', 'Porto', 'Remoto');
SET @IdEst_Olivia = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Pedro Gomes', 'Cibersegurança', 'Lisboa', 'Presencial');
SET @IdEst_Pedro = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Rita Fernandes', 'Sistemas de Informação', 'Lisboa', 'Hibrido');
SET @IdEst_Rita = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Samuel Azevedo', 'Redes e Comunicações', 'Porto', 'Hibrido');
SET @IdEst_Samuel = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Tânia Ribeiro', 'Gestão de Sistemas de Informação', 'Lisboa', 'Remoto');
SET @IdEst_Tania = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Vítor Monteiro', 'Cibersegurança', 'Porto', 'Presencial');
SET @IdEst_Vitor = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Alexandrina Faria', 'Engenharia Informática', 'Lisboa', 'Hibrido');
SET @IdEst_Xana = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Yuri Nascimento', 'Cibersegurança', 'Lisboa', 'Remoto');
SET @IdEst_Yuri = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Zélia Campos', 'Sistemas de Informação', 'Porto', 'Hibrido');
SET @IdEst_Zelia = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Afonso Guerreiro', 'Redes e Comunicações', 'Lisboa', 'Presencial');
SET @IdEst_Afonso = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Beatriz Antunes', 'Cibersegurança', 'Porto', 'Hibrido');
SET @IdEst_Beatriz = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Carlos Moreira', 'Gestão de Sistemas de Informação', 'Lisboa', 'Hibrido');
SET @IdEst_Carlos = SCOPE_IDENTITY();

INSERT INTO Estudantes (Nome, Curso, Pref_Localizacao, Pref_ModeloTrabalho)
VALUES ('Diana Esteves', 'Engenharia Informática', 'Lisboa', 'Remoto');
SET @IdEst_Diana = SCOPE_IDENTITY();

-- =============================================
-- INSERT EM Estudante_Competencias
-- Perfis variados com níveis distintos
-- =============================================

-- Ana — perfil análise de dados + risco
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ana, 1,  'Intermedio');  -- Python
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ana, 2,  'Intermedio');  -- SQL
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ana, 3,  'Basico');      -- Power BI
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ana, 32, 'Basico');      -- Gestão de Risco
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ana, 5,  'Intermedio');  -- Comunicação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ana, 8,  'Basico');      -- Resolução de Problemas

-- Bruno — perfil SOC / redes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Bruno, 19, 'Intermedio'); -- Seg. Redes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Bruno, 11, 'Intermedio'); -- Firewalls e VPNs
INSERT INTO Estudante_Competencias VALUES (@IdEst_Bruno, 16, 'Basico');     -- SIEM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Bruno, 17, 'Basico');     -- Resp. Incidentes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Bruno, 25, 'Intermedio'); -- Atenção ao Detalhe
INSERT INTO Estudante_Competencias VALUES (@IdEst_Bruno, 26, 'Basico');     -- Gestão de Stress

-- Carolina — perfil compliance / auditoria
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carolina, 22, 'Basico');     -- ISO 27001
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carolina, 30, 'Basico');     -- Auditoria TI
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carolina, 32, 'Basico');     -- Gestão de Risco
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carolina, 5,  'Intermedio'); -- Comunicação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carolina, 25, 'Intermedio'); -- Atenção ao Detalhe

-- David — perfil ethical hacking / pentest
INSERT INTO Estudante_Competencias VALUES (@IdEst_David, 15, 'Intermedio'); -- Ethical Hacking
INSERT INTO Estudante_Competencias VALUES (@IdEst_David, 9,  'Intermedio'); -- Penetration Testing
INSERT INTO Estudante_Competencias VALUES (@IdEst_David, 18, 'Basico');     -- Análise de Vuln.
INSERT INTO Estudante_Competencias VALUES (@IdEst_David, 23, 'Basico');     -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_David, 27, 'Intermedio'); -- Ética e Integridade
INSERT INTO Estudante_Competencias VALUES (@IdEst_David, 24, 'Intermedio'); -- Pensamento Crítico

-- Elisa — perfil cloud / IAM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Elisa, 14, 'Intermedio'); -- Seg. Cloud
INSERT INTO Estudante_Competencias VALUES (@IdEst_Elisa, 13, 'Basico');     -- IAM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Elisa, 31, 'Basico');     -- Zero Trust
INSERT INTO Estudante_Competencias VALUES (@IdEst_Elisa, 1,  'Basico');     -- Python
INSERT INTO Estudante_Competencias VALUES (@IdEst_Elisa, 28, 'Intermedio'); -- Adaptabilidade
INSERT INTO Estudante_Competencias VALUES (@IdEst_Elisa, 34, 'Basico');     -- Proatividade

-- Filipe — perfil redes / firewalls
INSERT INTO Estudante_Competencias VALUES (@IdEst_Filipe, 19, 'Avancado');  -- Seg. Redes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Filipe, 11, 'Avancado');  -- Firewalls e VPNs
INSERT INTO Estudante_Competencias VALUES (@IdEst_Filipe, 10, 'Intermedio'); -- Criptografia
INSERT INTO Estudante_Competencias VALUES (@IdEst_Filipe, 23, 'Intermedio'); -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Filipe, 8,  'Intermedio'); -- Resolução Problemas

-- Gonçalo — perfil pentest avançado
INSERT INTO Estudante_Competencias VALUES (@IdEst_Goncalo, 9,  'Avancado');  -- Penetration Testing
INSERT INTO Estudante_Competencias VALUES (@IdEst_Goncalo, 15, 'Avancado');  -- Ethical Hacking
INSERT INTO Estudante_Competencias VALUES (@IdEst_Goncalo, 18, 'Intermedio'); -- Análise de Vuln.
INSERT INTO Estudante_Competencias VALUES (@IdEst_Goncalo, 23, 'Intermedio'); -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Goncalo, 24, 'Avancado');  -- Pensamento Crítico
INSERT INTO Estudante_Competencias VALUES (@IdEst_Goncalo, 27, 'Intermedio'); -- Ética

-- Helena — perfil gestão / soft skills fortes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Helena, 32, 'Intermedio'); -- Gestão de Risco
INSERT INTO Estudante_Competencias VALUES (@IdEst_Helena, 22, 'Basico');     -- ISO 27001
INSERT INTO Estudante_Competencias VALUES (@IdEst_Helena, 5,  'Avancado');   -- Comunicação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Helena, 7,  'Intermedio'); -- Liderança
INSERT INTO Estudante_Competencias VALUES (@IdEst_Helena, 29, 'Basico');     -- Negociação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Helena, 33, 'Intermedio'); -- Empatia

-- Inês — perfil DevSecOps
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ines, 21, 'Intermedio'); -- DevSecOps
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ines, 1,  'Avancado');   -- Python
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ines, 14, 'Basico');     -- Seg. Cloud
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ines, 18, 'Basico');     -- Análise de Vuln.
INSERT INTO Estudante_Competencias VALUES (@IdEst_Ines, 28, 'Intermedio'); -- Adaptabilidade

-- João — perfil SOC avançado
INSERT INTO Estudante_Competencias VALUES (@IdEst_Joao, 16, 'Avancado');   -- SIEM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Joao, 17, 'Intermedio'); -- Resp. Incidentes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Joao, 19, 'Intermedio'); -- Seg. Redes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Joao, 12, 'Basico');     -- Análise Malware
INSERT INTO Estudante_Competencias VALUES (@IdEst_Joao, 25, 'Avancado');   -- Atenção ao Detalhe
INSERT INTO Estudante_Competencias VALUES (@IdEst_Joao, 26, 'Intermedio'); -- Gestão de Stress

-- Kátia — perfil análise / dados
INSERT INTO Estudante_Competencias VALUES (@IdEst_Katia, 2,  'Avancado');   -- SQL
INSERT INTO Estudante_Competencias VALUES (@IdEst_Katia, 3,  'Intermedio'); -- Power BI
INSERT INTO Estudante_Competencias VALUES (@IdEst_Katia, 4,  'Intermedio'); -- Excel Avançado
INSERT INTO Estudante_Competencias VALUES (@IdEst_Katia, 30, 'Basico');     -- Auditoria TI
INSERT INTO Estudante_Competencias VALUES (@IdEst_Katia, 25, 'Intermedio'); -- Atenção ao Detalhe

-- Luís — perfil redes + Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Luis, 19, 'Avancado');   -- Seg. Redes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Luis, 23, 'Avancado');   -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Luis, 11, 'Intermedio'); -- Firewalls e VPNs
INSERT INTO Estudante_Competencias VALUES (@IdEst_Luis, 10, 'Basico');     -- Criptografia
INSERT INTO Estudante_Competencias VALUES (@IdEst_Luis, 6,  'Intermedio'); -- Trabalho em Equipa

-- Mariana — perfil compliance / comunicação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Mariana, 22, 'Intermedio'); -- ISO 27001
INSERT INTO Estudante_Competencias VALUES (@IdEst_Mariana, 30, 'Intermedio'); -- Auditoria TI
INSERT INTO Estudante_Competencias VALUES (@IdEst_Mariana, 5,  'Avancado');   -- Comunicação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Mariana, 7,  'Basico');     -- Liderança
INSERT INTO Estudante_Competencias VALUES (@IdEst_Mariana, 33, 'Intermedio'); -- Empatia
INSERT INTO Estudante_Competencias VALUES (@IdEst_Mariana, 34, 'Intermedio'); -- Proatividade

-- Nuno — perfil forense / malware
INSERT INTO Estudante_Competencias VALUES (@IdEst_Nuno, 20, 'Intermedio'); -- Forense Digital
INSERT INTO Estudante_Competencias VALUES (@IdEst_Nuno, 12, 'Intermedio'); -- Análise Malware
INSERT INTO Estudante_Competencias VALUES (@IdEst_Nuno, 23, 'Basico');     -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Nuno, 24, 'Intermedio'); -- Pensamento Crítico
INSERT INTO Estudante_Competencias VALUES (@IdEst_Nuno, 25, 'Intermedio'); -- Atenção ao Detalhe

-- Olívia — perfil cloud / remoto
INSERT INTO Estudante_Competencias VALUES (@IdEst_Olivia, 14, 'Avancado');   -- Seg. Cloud
INSERT INTO Estudante_Competencias VALUES (@IdEst_Olivia, 13, 'Intermedio'); -- IAM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Olivia, 31, 'Intermedio'); -- Zero Trust
INSERT INTO Estudante_Competencias VALUES (@IdEst_Olivia, 1,  'Intermedio'); -- Python
INSERT INTO Estudante_Competencias VALUES (@IdEst_Olivia, 28, 'Avancado');   -- Adaptabilidade
INSERT INTO Estudante_Competencias VALUES (@IdEst_Olivia, 34, 'Intermedio'); -- Proatividade

-- Pedro — perfil Red Team
INSERT INTO Estudante_Competencias VALUES (@IdEst_Pedro, 15, 'Avancado');   -- Ethical Hacking
INSERT INTO Estudante_Competencias VALUES (@IdEst_Pedro, 9,  'Avancado');   -- Penetration Testing
INSERT INTO Estudante_Competencias VALUES (@IdEst_Pedro, 18, 'Avancado');   -- Análise de Vuln.
INSERT INTO Estudante_Competencias VALUES (@IdEst_Pedro, 23, 'Avancado');   -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Pedro, 24, 'Avancado');   -- Pensamento Crítico
INSERT INTO Estudante_Competencias VALUES (@IdEst_Pedro, 27, 'Avancado');   -- Ética

-- Rita — perfil SI / generalista
INSERT INTO Estudante_Competencias VALUES (@IdEst_Rita, 2,  'Intermedio'); -- SQL
INSERT INTO Estudante_Competencias VALUES (@IdEst_Rita, 3,  'Basico');     -- Power BI
INSERT INTO Estudante_Competencias VALUES (@IdEst_Rita, 32, 'Basico');     -- Gestão de Risco
INSERT INTO Estudante_Competencias VALUES (@IdEst_Rita, 22, 'Basico');     -- ISO 27001
INSERT INTO Estudante_Competencias VALUES (@IdEst_Rita, 5,  'Intermedio'); -- Comunicação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Rita, 6,  'Intermedio'); -- Trabalho em Equipa

-- Samuel — perfil redes / SOC júnior
INSERT INTO Estudante_Competencias VALUES (@IdEst_Samuel, 19, 'Intermedio'); -- Seg. Redes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Samuel, 16, 'Basico');     -- SIEM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Samuel, 11, 'Basico');     -- Firewalls
INSERT INTO Estudante_Competencias VALUES (@IdEst_Samuel, 17, 'Basico');     -- Resp. Incidentes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Samuel, 34, 'Intermedio'); -- Proatividade

-- Tânia — perfil RGPD / privacidade
INSERT INTO Estudante_Competencias VALUES (@IdEst_Tania, 22, 'Intermedio'); -- ISO 27001
INSERT INTO Estudante_Competencias VALUES (@IdEst_Tania, 32, 'Intermedio'); -- Gestão de Risco
INSERT INTO Estudante_Competencias VALUES (@IdEst_Tania, 27, 'Avancado');   -- Ética e Integridade
INSERT INTO Estudante_Competencias VALUES (@IdEst_Tania, 5,  'Avancado');   -- Comunicação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Tania, 33, 'Intermedio'); -- Empatia

-- Vítor — perfil pentest / Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Vitor, 9,  'Intermedio'); -- Penetration Testing
INSERT INTO Estudante_Competencias VALUES (@IdEst_Vitor, 15, 'Basico');     -- Ethical Hacking
INSERT INTO Estudante_Competencias VALUES (@IdEst_Vitor, 23, 'Avancado');   -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Vitor, 18, 'Basico');     -- Análise de Vuln.
INSERT INTO Estudante_Competencias VALUES (@IdEst_Vitor, 24, 'Intermedio'); -- Pensamento Crítico

-- Alexandrina — perfil IAM / Zero Trust
INSERT INTO Estudante_Competencias VALUES (@IdEst_Xana, 13, 'Avancado');   -- IAM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Xana, 31, 'Intermedio'); -- Zero Trust
INSERT INTO Estudante_Competencias VALUES (@IdEst_Xana, 14, 'Intermedio'); -- Seg. Cloud
INSERT INTO Estudante_Competencias VALUES (@IdEst_Xana, 6,  'Intermedio'); -- Trabalho em Equipa
INSERT INTO Estudante_Competencias VALUES (@IdEst_Xana, 28, 'Basico');     -- Adaptabilidade

-- Yuri — perfil threat hunting / SIEM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Yuri, 16, 'Avancado');   -- SIEM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Yuri, 18, 'Intermedio'); -- Análise de Vuln.
INSERT INTO Estudante_Competencias VALUES (@IdEst_Yuri, 12, 'Intermedio'); -- Análise Malware
INSERT INTO Estudante_Competencias VALUES (@IdEst_Yuri, 17, 'Basico');     -- Resp. Incidentes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Yuri, 24, 'Avancado');   -- Pensamento Crítico

-- Zélia — perfil auditoria / ISO
INSERT INTO Estudante_Competencias VALUES (@IdEst_Zelia, 30, 'Intermedio'); -- Auditoria TI
INSERT INTO Estudante_Competencias VALUES (@IdEst_Zelia, 22, 'Intermedio'); -- ISO 27001
INSERT INTO Estudante_Competencias VALUES (@IdEst_Zelia, 32, 'Basico');     -- Gestão de Risco
INSERT INTO Estudante_Competencias VALUES (@IdEst_Zelia, 2,  'Basico');     -- SQL
INSERT INTO Estudante_Competencias VALUES (@IdEst_Zelia, 25, 'Avancado');   -- Atenção ao Detalhe

-- Afonso — perfil redes / presencial Lisboa
INSERT INTO Estudante_Competencias VALUES (@IdEst_Afonso, 19, 'Intermedio'); -- Seg. Redes
INSERT INTO Estudante_Competencias VALUES (@IdEst_Afonso, 11, 'Avancado');   -- Firewalls
INSERT INTO Estudante_Competencias VALUES (@IdEst_Afonso, 10, 'Intermedio'); -- Criptografia
INSERT INTO Estudante_Competencias VALUES (@IdEst_Afonso, 23, 'Basico');     -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Afonso, 8,  'Intermedio'); -- Resolução Problemas
INSERT INTO Estudante_Competencias VALUES (@IdEst_Afonso, 6,  'Intermedio'); -- Trabalho em Equipa

-- Beatriz — perfil cloud / Porto
INSERT INTO Estudante_Competencias VALUES (@IdEst_Beatriz, 14, 'Intermedio'); -- Seg. Cloud
INSERT INTO Estudante_Competencias VALUES (@IdEst_Beatriz, 13, 'Intermedio'); -- IAM
INSERT INTO Estudante_Competencias VALUES (@IdEst_Beatriz, 21, 'Basico');     -- DevSecOps
INSERT INTO Estudante_Competencias VALUES (@IdEst_Beatriz, 1,  'Basico');     -- Python
INSERT INTO Estudante_Competencias VALUES (@IdEst_Beatriz, 34, 'Intermedio'); -- Proatividade
INSERT INTO Estudante_Competencias VALUES (@IdEst_Beatriz, 28, 'Intermedio'); -- Adaptabilidade

-- Carlos — perfil gestão / risco / compliance
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carlos, 32, 'Avancado');   -- Gestão de Risco
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carlos, 22, 'Avancado');   -- ISO 27001
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carlos, 30, 'Intermedio'); -- Auditoria TI
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carlos, 5,  'Avancado');   -- Comunicação
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carlos, 7,  'Intermedio'); -- Liderança
INSERT INTO Estudante_Competencias VALUES (@IdEst_Carlos, 29, 'Intermedio'); -- Negociação

-- Diana — perfil forense / malware avançado
INSERT INTO Estudante_Competencias VALUES (@IdEst_Diana, 20, 'Avancado');   -- Forense Digital
INSERT INTO Estudante_Competencias VALUES (@IdEst_Diana, 12, 'Avancado');   -- Análise Malware
INSERT INTO Estudante_Competencias VALUES (@IdEst_Diana, 23, 'Intermedio'); -- Seg. Linux
INSERT INTO Estudante_Competencias VALUES (@IdEst_Diana, 24, 'Avancado');   -- Pensamento Crítico
INSERT INTO Estudante_Competencias VALUES (@IdEst_Diana, 25, 'Avancado');   -- Atenção ao Detalhe
INSERT INTO Estudante_Competencias VALUES (@IdEst_Diana, 1,  'Basico');     -- Python
-------------------------- AJUSTES ----------------------------
-- =============================================
-- TABELA DE CANDIDATURAS
-- =============================================
CREATE TABLE Candidaturas (
    ID_Candidatura   INT PRIMARY KEY IDENTITY(1,1),
    ID_Estudante     INT FOREIGN KEY REFERENCES Estudantes(ID_Estudante),
    ID_Vaga          INT FOREIGN KEY REFERENCES Vagas(ID_Vaga),
    Data_Candidatura DATETIME DEFAULT GETDATE(),
    Resultado        NVARCHAR(20) CHECK (Resultado IN ('Pendente', 'Aceite', 'Rejeitado'))
);
------------------------- Candidaturas ----------------------------
-- =============================================
-- INSERTS DE CANDIDATURAS
-- (usa os IDs reais da tua DB após correr os inserts anteriores)
-- =============================================

-- Busca os IDs reais para usar nas candidaturas
-- SELECT ID_Estudante, Nome FROM Estudantes ORDER BY ID_Estudante;
-- SELECT ID_Vaga, Empresa, Titulo_Vaga FROM Vagas ORDER BY ID_Vaga;

-- Abaixo assumindo IDs sequenciais a partir de 1
-- Ajusta se a tua DB começou noutro valor

-- Ana (1) — candidatou-se a vagas de risco/compliance
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (1, 8,  'Aceite');    -- Accenture Risk
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (1, 11, 'Pendente');  -- PwC Auditoria
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (1, 33, 'Rejeitado'); -- BdP Risco Op.

-- Bruno (2) — perfil SOC / redes
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (2, 3,  'Aceite');    -- Altice SOC
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (2, 1,  'Pendente');  -- NOS Cyber
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (2, 35, 'Rejeitado'); -- S21sec SOC

-- Carolina (3) — compliance / auditoria / Porto remoto
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (3, 15, 'Aceite');    -- Deloitte ISO
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (3, 19, 'Aceite');    -- KPMG Audit
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (3, 11, 'Pendente');  -- PwC Auditoria

-- David (4) — ethical hacking / pentest
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (4, 9,  'Aceite');    -- Accenture Hacking
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (4, 7,  'Pendente');  -- Claranet Pentest
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (4, 32, 'Rejeitado'); -- Vodafone RedTeam

-- Elisa (5) — cloud / IAM / Porto
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (5, 6,  'Aceite');    -- Claranet Cloud
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (5, 16, 'Pendente');  -- EY Cloud
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (5, 10, 'Rejeitado'); -- Accenture IAM

-- Filipe (6) — redes / firewalls / Lisboa presencial
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (6, 2,  'Aceite');    -- NOS Redes
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (6, 23, 'Aceite');    -- Novabase Redes
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (6, 31, 'Pendente');  -- Vodafone Telco

-- Gonçalo (7) — pentest avançado / Porto presencial
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (7, 7,  'Aceite');    -- Claranet Pentest
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (7, 9,  'Aceite');    -- Accenture Hacking
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (7, 32, 'Pendente');  -- Vodafone RedTeam

-- Helena (8) — gestão / soft skills / Lisboa híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (8, 29, 'Aceite');    -- Millennium Awareness
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (8, 12, 'Pendente');  -- PwC Risco
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (8, 27, 'Rejeitado'); -- CGD Risco

-- Inês (9) — DevSecOps / Lisboa remoto
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (9, 4,  'Aceite');    -- Altice DevSecOps
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (9, 20, 'Pendente');  -- Capgemini AppSec
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (9, 6,  'Rejeitado'); -- Claranet Cloud

-- João (10) — SOC avançado / Lisboa presencial
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (10, 3,  'Aceite');   -- Altice SOC
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (10, 22, 'Aceite');   -- Capgemini SIEM
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (10, 35, 'Pendente'); -- S21sec SOC

-- Kátia (11) — análise de dados / Porto híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (11, 33, 'Pendente'); -- BdP Risco Op.
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (11, 19, 'Aceite');   -- KPMG Audit
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (11, 11, 'Rejeitado');-- PwC Auditoria

-- Luís (12) — redes + Linux / Porto presencial
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (12, 23, 'Aceite');   -- Novabase Redes
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (12, 2,  'Pendente'); -- NOS Redes
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (12, 24, 'Rejeitado');-- Novabase Malware

-- Mariana (13) — compliance / comunicação / Lisboa híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (13, 15, 'Aceite');   -- Deloitte ISO
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (13, 34, 'Aceite');   -- BdP Supervisão
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (13, 29, 'Pendente'); -- Millennium Aware

-- Nuno (14) — forense / malware / Lisboa híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (14, 14, 'Aceite');   -- Deloitte Forense
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (14, 24, 'Pendente'); -- Novabase Malware
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (14, 37, 'Rejeitado');-- S21sec Incidentes

-- Olívia (15) — cloud / Porto remoto
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (15, 6,  'Aceite');   -- Claranet Cloud
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (15, 16, 'Aceite');   -- EY Cloud
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (15, 10, 'Pendente'); -- Accenture IAM

-- Pedro (16) — Red Team completo / Lisboa presencial
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (16, 32, 'Aceite');   -- Vodafone RedTeam
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (16, 7,  'Aceite');   -- Claranet Pentest
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (16, 36, 'Pendente'); -- S21sec Hunt

-- Rita (17) — generalista SI / Lisboa híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (17, 27, 'Pendente'); -- CGD Risco
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (17, 30, 'Rejeitado');-- Millennium RGPD
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (17, 13, 'Pendente'); -- Deloitte Cyber

-- Samuel (18) — SOC júnior / Porto híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (18, 35, 'Pendente'); -- S21sec SOC
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (18, 3,  'Rejeitado');-- Altice SOC
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (18, 22, 'Pendente'); -- Capgemini SIEM

-- Tânia (19) — RGPD / Lisboa remoto
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (19, 30, 'Aceite');   -- Millennium RGPD
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (19, 27, 'Aceite');   -- CGD Risco
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (19, 34, 'Pendente'); -- BdP Supervisão

-- Vítor (20) — pentest/Linux / Porto presencial
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (20, 7,  'Pendente'); -- Claranet Pentest
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (20, 36, 'Rejeitado');-- S21sec Hunt
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (20, 9,  'Pendente'); -- Accenture Hacking

-- Alexandrina (21) — IAM / Lisboa híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (21, 10, 'Aceite');   -- Accenture IAM
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (21, 21, 'Aceite');   -- Capgemini ZeroTrust
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (21, 28, 'Pendente'); -- CGD IAM

-- Yuri (22) — threat hunting / Lisboa remoto
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (22, 36, 'Aceite');   -- S21sec Hunt
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (22, 18, 'Aceite');   -- KPMG Threat
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (22, 17, 'Pendente'); -- EY Vuln

-- Zélia (23) — auditoria/ISO / Porto híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (23, 19, 'Aceite');   -- KPMG Audit
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (23, 15, 'Pendente'); -- Deloitte ISO
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (23, 34, 'Rejeitado');-- BdP Supervisão

-- Afonso (24) — redes / Lisboa presencial
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (24, 2,  'Aceite');   -- NOS Redes
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (24, 31, 'Pendente'); -- Vodafone Telco
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (24, 23, 'Rejeitado');-- Novabase Redes

-- Beatriz (25) — cloud / Porto híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (25, 6,  'Pendente'); -- Claranet Cloud
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (25, 16, 'Rejeitado');-- EY Cloud
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (25, 4,  'Pendente'); -- Altice DevSecOps

-- Carlos (26) — gestão/risco/compliance / Lisboa híbrido
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (26, 12, 'Aceite');   -- PwC Risco
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (26, 15, 'Aceite');   -- Deloitte ISO
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (26, 34, 'Pendente'); -- BdP Supervisão

-- Diana (27) — forense/malware avançado / Lisboa remoto
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (27, 14, 'Aceite');   -- Deloitte Forense
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (27, 24, 'Aceite');   -- Novabase Malware
INSERT INTO Candidaturas (ID_Estudante, ID_Vaga, Resultado) VALUES (27, 37, 'Pendente'); -- S21sec Incidentes
--------------------- VIEWS -----------------------
-- =============================================
-- 1. VIEW PARA O DASHBOARD DA UNIVERSIDADE (Análise de Empregabilidade)
-- Junta o perfil do aluno com o status real da sua candidatura.
-- =============================================
GO
CREATE VIEW vw_Empregabilidade_Alunos AS
SELECT 
    c.ID_Candidatura,
    e.Nome AS Nome_Estudante,
    e.Curso,
    v.Empresa,
    v.Titulo_Vaga,
    c.Data_Candidatura,
    c.Resultado
FROM Candidaturas c
JOIN Estudantes e ON c.ID_Estudante = e.ID_Estudante
JOIN Vagas v ON c.ID_Vaga = v.ID_Vaga;
GO

-- =============================================
-- 2. VIEW PARA O DASHBOARD DA EMPRESA E ESTUDANTE (Análise de Recomendações)
-- Mostra de forma legível quem foi recomendado para o quê.
-- =============================================
GO
CREATE VIEW vw_Matches_Recomendados AS
SELECT 
    r.ID_Recomendacao,
    e.Nome AS Nome_Estudante,
    e.Curso,
    e.Pref_ModeloTrabalho AS Modelo_Aluno,
    v.Empresa,
    v.Titulo_Vaga,
    v.ModeloTrabalho AS Modelo_Vaga,
    r.Score_Total,
    r.Score_HardSkills,
    r.Score_SoftSkills,
    r.Score_Logistica
FROM Recomendacoes r
JOIN Estudantes e ON r.ID_Estudante = e.ID_Estudante
JOIN Vagas v ON r.ID_Vaga = v.ID_Vaga;
GO