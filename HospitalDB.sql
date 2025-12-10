CREATE DATABASE HospitalDB;
USE HospitalDB;

CREATE TABLE Especialidade (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL
);

CREATE TABLE Funcionario (
  cpf VARCHAR(14) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(150),
  telefone VARCHAR(20),
  cargo VARCHAR(50),
  salario NUMERIC(10,2)
);

CREATE TABLE Medico (
  cpf VARCHAR(14) PRIMARY KEY REFERENCES Funcionario(cpf) ON DELETE CASCADE,
  crm VARCHAR(30),
  especialidade_id INT REFERENCES Especialidade(id)
);

CREATE TABLE Enfermeiro (
  cpf VARCHAR(14) PRIMARY KEY REFERENCES Funcionario(cpf) ON DELETE CASCADE,
  coren VARCHAR(30)
);

CREATE TABLE Atendente (
  cpf VARCHAR(14) PRIMARY KEY REFERENCES Funcionario(cpf) ON DELETE CASCADE,
  turno VARCHAR(30)
);

CREATE TABLE Paciente (
  id SERIAL PRIMARY KEY,
  cpf VARCHAR(14) UNIQUE,
  nome VARCHAR(120) NOT NULL,
  telefone VARCHAR(20),
  dataNascimento DATE,
  endereco TEXT
);

CREATE TABLE Agendamento (
  id SERIAL PRIMARY KEY,
  paciente_id INT REFERENCES Paciente(id) ON DELETE CASCADE,
  funcionario_cpf VARCHAR(14) REFERENCES Funcionario(cpf),
  datahora TIMESTAMP NOT NULL,
  status VARCHAR(30)
);

CREATE TABLE Consulta (
  id SERIAL PRIMARY KEY,
  paciente_id INT REFERENCES Paciente(id) ON DELETE CASCADE,
  medico_cpf VARCHAR(14) REFERENCES Medico(cpf),
  atendente_cpf VARCHAR(14) REFERENCES Atendente(cpf),
  datahora TIMESTAMP NOT NULL,
  motivo TEXT,
  observacoes TEXT
);

CREATE TABLE Exame (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  tipo VARCHAR(80),
  datahora TIMESTAMP
);

CREATE TABLE ConsultaExame (
  consulta_id INT REFERENCES Consulta(id) ON DELETE CASCADE,
  exame_id INT REFERENCES Exame(id) ON DELETE CASCADE,
  PRIMARY KEY (consulta_id, exame_id)
);

CREATE TABLE Prescricao (
  id SERIAL PRIMARY KEY,
  consulta_id INT REFERENCES Consulta(id) ON DELETE CASCADE,
  paciente_id INT REFERENCES Paciente(id) ON DELETE CASCADE,
  datahora TIMESTAMP NOT NULL,
  orientacoes TEXT
);

CREATE TABLE Medicamento (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  dosagem VARCHAR(80),
  fabricante VARCHAR(120)
);

CREATE TABLE ItemPrescricao (
  prescricao_id INT REFERENCES Prescricao(id) ON DELETE CASCADE,
  medicamento_id INT REFERENCES Medicamento(id) ON DELETE CASCADE,
  quantidade INT NOT NULL,
  instrucoes VARCHAR(200),
  PRIMARY KEY (prescricao_id, medicamento_id)
);

CREATE TABLE Setor (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  localizacao VARCHAR(100)
);

CREATE TABLE Leito (
  id SERIAL PRIMARY KEY,
  setor_id INT REFERENCES Setor(id) ON DELETE SET NULL,
  numero VARCHAR(20),
  descricao TEXT,
  ocupado BOOLEAN DEFAULT FALSE
);

CREATE TABLE Internacao (
  id SERIAL PRIMARY KEY,
  paciente_id INT REFERENCES Paciente(id) ON DELETE CASCADE,
  leito_id INT REFERENCES Leito(id),
  dataEntrada TIMESTAMP NOT NULL,
  dataAlta TIMESTAMP,
  motivo TEXT
);

-- PARTE DO INSERT INTO

INSERT INTO Especialidade (nome) VALUES
('Cardiologia'), ('Pediatria'), ('Ortopedia'), ('Ginecologia');

INSERT INTO Funcionario (cpf, nome, email, telefone, cargo, salario) VALUES
('111.222.333-44','Dr. Carlos Silva','carlos@hospital.com','(11)9999-1111','Médico',12000),
('222.333.444-55','Ana Pereira','ana@hospital.com','(11)98888-2222','Atendente',2000),
('333.444.555-66','Marcos Souza','marcos@hospital.com','(11)97777-3333','Enfermeiro',3000),
('444.555.666-77','Dra. Fernanda','fernanda@hospital.com','(11)96666-4444','Médico',11000);

INSERT INTO Medico (cpf, crm, especialidade_id) VALUES
('111.222.333-44','CRM-12345', 1),
('444.555.666-77','CRM-98765', 2);

INSERT INTO Atendente (cpf, turno) VALUES
('222.333.444-55','Manhã');

INSERT INTO Enfermeiro (cpf, coren) VALUES
('333.444.555-66','COREN-2020');

INSERT INTO Paciente (cpf, nome, telefone, dataNascimento, endereco) VALUES
('555.666.777-88','João Silva','(11)95555-0001','1985-06-15','Rua A, 123'),
('666.777.888-99','Maria Oliveira','(11)95555-0002','1990-03-22','Av B, 456'),
('777.888.999-00','Carlos Santos','(11)95555-0003','1978-11-02','Rua C, 789');

INSERT INTO Agendamento (paciente_id, funcionario_cpf, datahora, status) VALUES
(1, '222.333.444-55', '2024-09-15 19:00:00', 'Confirmado'),
(2, '222.333.444-55', '2024-09-16 20:00:00', 'Confirmado');

INSERT INTO Consulta (paciente_id, medico_cpf, atendente_cpf, datahora, motivo, observacoes) VALUES
(1, '111.222.333-44', '222.333.444-55', '2024-09-15 19:30:00', 'Dor no peito', 'Exame cardiológico solicitado'),
(2, '444.555.666-77', '222.333.444-55', '2024-09-16 20:30:00', 'Febre alta', 'Prescrever antitérmico');

INSERT INTO Exame (nome, tipo, datahora) VALUES
('ECG','Cardiológico','2024-09-15 20:00:00'),
('Hemograma','Laboratorial','2024-09-16 21:00:00');

INSERT INTO ConsultaExame (consulta_id, exame_id) VALUES
(1,1),
(2,2);

INSERT INTO Prescricao (consulta_id, paciente_id, datahora, orientacoes) VALUES
(1,1,'2024-09-15 20:05:00','Repouso e retorno em 7 dias'),
(2,2,'2024-09-16 21:10:00','Paracetamol 500mg a cada 8h por 3 dias');

INSERT INTO Medicamento (nome, dosagem, fabricante) VALUES
('Paracetamol','500mg','Lab A'),
('AAS','100mg','Lab B');

INSERT INTO ItemPrescricao (prescricao_id, medicamento_id, quantidade, instrucoes) VALUES
(2,1,10,'1 comprimido a cada 8h');

INSERT INTO Setor (nome, localizacao) VALUES
('Hospital Geral - Clínica Médica','1º Andar'),
('Hospital Geral - UTI','Térreo');

INSERT INTO Leito (setor_id, numero, descricao, ocupado) VALUES
(1,'101','Leito semi-privado', false),
(2,'201','Leito UTI', false);

INSERT INTO Internacao (paciente_id, leito_id, dataEntrada, motivo) VALUES
(3, 1, '2024-09-14 10:00:00', 'Observação pós-operatória');
