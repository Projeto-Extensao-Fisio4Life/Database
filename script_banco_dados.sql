CREATE DATABASE fisio4life;
USE fisio4life;

-- -----------------------------------------------------
-- Tabela: endereco
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS endereco (
  id_endereco INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  logradouro VARCHAR(45) NOT NULL, -- Tipo e nome da via (ex: Rua cebolinha)
  numero INT NOT NULL, -- Número do local 
  bairro VARCHAR(45) NOT NULL, -- Bairro em que o endereço está localizado
  cidade VARCHAR(45) NOT NULL, -- Cidade em que o endereço está localizado
  estado CHAR(2) NOT NULL, -- Sigla do estado (UF)
  cep VARCHAR(45) NOT NULL -- Código de Endereçamento Postal (CEP)
);

-- -----------------------------------------------------
-- Tabela: contato
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS contato (
  id_contato INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  telefone CHAR(14) NOT NULL, -- Número de telefone
  celular CHAR(14) NOT NULL, -- Número do celular
  email VARCHAR(45) NOT NULL -- Endereço digital
);

-- -----------------------------------------------------
-- Tabela: usuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS usuario (
  id_usuario INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_endereco INT NOT NULL, -- Foreign key para vincular endereço
  fk_contato INT NOT NULL, -- Foreign key para vincular contato
  nome VARCHAR(255) NOT NULL, -- Nome completo do usuário
  data_nascimento DATE NOT NULL, -- Informa a data de nascimento
  senha VARCHAR(60) NOT NULL, -- Senha para acesso a aplicação
  tipo_usuario VARCHAR(45) NOT NULL, -- Define o tipo de usuário, usado para controle de permissões de acesso (ex: administrador)
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Salva a data de cadastro
  status_usuario TINYINT NOT NULL, -- Indica se esta ativo ou inativo
	CONSTRAINT fk_usuario_endereco 
		FOREIGN KEY (fk_endereco) 
			REFERENCES endereco (id_endereco),
	CONSTRAINT fk_usuario_contato 
		FOREIGN KEY (fk_contato) 
			REFERENCES contato (id_contato)
);

-- -----------------------------------------------------
-- Tabela: paciente
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS paciente (
  id_paciente INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_usuario INT NOT NULL UNIQUE, -- Foreign key para vincular usuario
  cpf CHAR(11) NOT NULL UNIQUE, -- Cadastro de Pessoa Fisíca
  permite_atendimento_grupo TINYINT NOT NULL, -- Indica se irá receber atendimento sozinho ou em grupo
	CONSTRAINT fk_paciente_usuario 
		FOREIGN KEY (fk_usuario) 
			REFERENCES usuario (id_usuario)
);

-- -----------------------------------------------------
-- Tabela: fisioterapeuta
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS fisioterapeuta (
  id_fisioterapeuta INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_usuario INT NOT NULL UNIQUE, -- Referência a tabela de usuario
  crefito CHAR(10) NOT NULL UNIQUE, -- Conselho Regional de Fisioterapia e Terapia Ocupaciona (registro profissional fisioterapeuta)
  especialidade VARCHAR(45) NOT NULL, -- Parte que o fisioterapeuta atua 
  cnpj CHAR(14) NOT NULL UNIQUE, -- Cadastro Nacional da Pessoa Jurídica
	CONSTRAINT fk_fisioterapeuta_usuario 
		FOREIGN KEY (fk_usuario) 
			REFERENCES usuario (id_usuario)
);

-- -----------------------------------------------------
-- Tabela: clinica
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS clinica (
  id_clinica INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_contato INT NOT NULL, -- Foreign key para vincular contato
  fk_endereco INT NOT NULL UNIQUE, -- Foreign key para vincular endereco
  nome VARCHAR(255) NOT NULL, -- Nome da clinica
  cnpj CHAR(14) NOT NULL UNIQUE, -- Cadastro Nacional da Pessoa Jurídica
	CONSTRAINT fk_clinica_contato 
		FOREIGN KEY (fk_contato) 
			REFERENCES contato (id_contato),
	CONSTRAINT fk_clinica_endereco 
		FOREIGN KEY (fk_endereco) 
			REFERENCES endereco (id_endereco)
);

-- -----------------------------------------------------
-- Tabela: agendamento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agendamento (
  id_agendamento INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_clinica INT NOT NULL, -- Foreign key para vincular clinica
  fk_fisioterapeuta INT NOT NULL, -- Foreign key para vincular fisioterapeuta
  fk_paciente INT NOT NULL, -- Foreign key para vincular paciente
  data_agendamento DATE NOT NULL, -- Data que houve o agendamento 
  hora_inicio TIME NOT NULL, -- Horário de inicio 
  hora_fim TIME NOT NULL, -- Horário de termino
  status_agendamento TINYINT NOT NULL, -- Indica se esta ativo ou inativo
  observacao VARCHAR(255) NULL, -- Registrar informações complementares
	CONSTRAINT fk_agendamento_clinica 
		FOREIGN KEY (fk_clinica) 
			REFERENCES clinica (id_clinica),
	CONSTRAINT fk_agendamento_fisioterapeuta 
		FOREIGN KEY (fk_fisioterapeuta) 
			REFERENCES fisioterapeuta (id_fisioterapeuta),
	CONSTRAINT fk_agendamento_paciente 
		FOREIGN KEY (fk_paciente) 
			REFERENCES paciente (id_paciente)
);

-- -----------------------------------------------------
-- Tabela: paciente_clinica
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS paciente_clinica (
  id_vinculo INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_clinica INT NOT NULL, -- Foreign key para vincular clinica
  fk_paciente INT NOT NULL, -- -- Foreign key para vincular
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Data de cadastro do paciente na clinica
  ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Data da ultima atualizacao
  status_paciente_clinica TINYINT NOT NULL, -- Indica se esta ativo ou inativo
	CONSTRAINT fk_paciente_clinica_clinica 
		FOREIGN KEY (fkclinica) 
			REFERENCES clinica (id_clinica),
	CONSTRAINT fk_paciente_clinica_paciente 
		FOREIGN KEY (fkpaciente) 
			REFERENCES paciente (id_paciente)
);

-- -----------------------------------------------------
-- Tabela: sessao
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS sessao (
  id_sessao INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_agendamento INT NOT NULL, -- Foreign key para vincular agendamento
  data_sessao DATETIME NOT NULL, -- Data que esta marcada
  descricao VARCHAR(255) NOT NULL, -- Acontecimento ou opontamentos
  observacao VARCHAR(255) NOT NULL, -- Informações complementares
	CONSTRAINT fk_sessao_agendamento 
		FOREIGN KEY (fk_agendamento) 
			REFERENCES agendamento (id_agendamento)
);

-- -----------------------------------------------------
-- Tabela: prontuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS prontuario (
  id_prontuario INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_paciente INT NOT NULL UNIQUE, -- Foreign key para vincular paciente
  data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Data de abertura 
  status_prontuario TINYINT NOT NULL, -- Indica se esta ativo ou inativo
  observacao_inicial VARCHAR(255) NULL, -- Informações complementares
	CONSTRAINT fk_prontuario_paciente 
		FOREIGN KEY (fk_paciente) 
			REFERENCES paciente (id_paciente)
);

-- -----------------------------------------------------
-- Tabela: evolucao
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS evolucao (
  id_evolucao INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_sessao INT NOT NULL UNIQUE, -- Foreign key para vincular sessao
  fk_prontuario INT NOT NULL, -- Foreign key para vincular prontuario
  data_evolucao DATETIME NOT NULL, -- Data que foi marcada
  conduta VARCHAR(255) NOT NULL, -- Conjunto de técnicas e métodos para alcançar o objetivo
  avaliacao VARCHAR(255) NOT NULL, -- Exame inicial detalhado
  observacao VARCHAR(255) NULL, -- Informações complementares
	CONSTRAINT fk_evolucao_sessao 
		FOREIGN KEY (fk_sessao) 
			REFERENCES sessao (id_sessao),
	CONSTRAINT fk_evolucao_prontuario 
		FOREIGN KEY (fk_prontuario) 
			REFERENCES prontuario (id_prontuario)
);

-- -----------------------------------------------------
-- Tabela: servico
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS servico (
  id_servico INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_clinica INT NOT NULL, -- Foreign key para vincular clinica
  nome VARCHAR(45) NOT NULL, -- Nome do servico
  quantidade_sessoes INT NOT NULL, -- Indica quantas sessões terá (se é unitário ou não)
  valor DECIMAL(10,2) NOT NULL, -- Seu valor combrado (preço)
  tipo VARCHAR(20) NOT NULL, -- Indicará qual o tipo de vertente (ex: ortopedia)
	CONSTRAINT fk_servico_clinica 
		FOREIGN KEY (fk_clinica) 
			REFERENCES clinica (id_clinica)
);

-- -----------------------------------------------------
-- Tabela: pacote_paciente
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pacote_paciente (
  id_pacote_paciente INT PRIMARY KEY AUTO_INCREMENT,  -- Identificador único do registro
  fk_servico INT NOT NULL, -- Foreign key para vincular servico
  fk_paciente INT NOT NULL, -- Foreign key para vincular paciente
  sessoes_restantes VARCHAR(45) NOT NULL, -- Do total quantas faltam realizar
  data_compra DATETIME NOT NULL, -- Aquisição do servico
  status_pacote_paciente TINYINT NOT NULL, -- Indica se esta ativo ou inativo
	CONSTRAINT fk_pacote_paciente_servico 
		FOREIGN KEY (fk_servico) 
			REFERENCES servico (id_servico),
	CONSTRAINT fk_pacote_paciente_paciente
		FOREIGN KEY (fk_paciente) 
			REFERENCES paciente (id_paciente)
);

-- -----------------------------------------------------
-- Tabela: documento_prontuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS documento_prontuario (
  id_documento INT NOT NULL, -- Referenciar o documento
  fk_prontuario INT NOT NULL, -- Foreign key para vincular prontuario
  nome_arquivo VARCHAR(45) NOT NULL UNIQUE, -- Nome do arquivo
  tipo_documento VARCHAR(45) NOT NULL, -- Indica seu tipo (ex: PDF, .csv)
  s3_key VARCHAR(45) NOT NULL, -- Chave do S3 que esta armazenado
  url_documento VARCHAR(45) NOT NULL UNIQUE, -- Caminho para acesso
  data_upload DATETIME NOT NULL, -- data que foi armazenado
	PRIMARY KEY (id_documento, fk_prontuario), -- Identificador único do registro
	CONSTRAINT fk_documento_prontuario_prontuario 
		FOREIGN KEY (fk_prontuario) 
			REFERENCES prontuario (id_prontuario)
);

-- -----------------------------------------------------
-- Tabela: exercicio
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS exercicio (
  id_exercicio INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  categoria VARCHAR(45) NOT NULL, -- Movimentos corporais planejados e técnica (ex: passivo)
  nome VARCHAR(45) NOT NULL -- Nome do exercicio
);

-- -----------------------------------------------------
-- Tabela: exercicio_na_sessao
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS exercicio_na_sessao (
  fk_sessao INT NOT NULL, -- Foreign key para vincular sessao
  fk_exercicio INT NOT NULL, -- Foreign key para vincular exercicio
  segmento VARCHAR(45) NULL, -- Parte do corpo trabalhada no exercício (ex: membro superior, tronco)
  quantidade_series INT NULL, -- Quantidade de séries realizadas do exercício
  quantidade_repeticoes INT NULL, -- Quantidade de repetições por série
  carga INT NULL, -- Peso ou resistência utilizada no exercício
  tempo TIME NULL, -- Tempo de duração do exercício (para exercícios cronometrados)
	PRIMARY KEY (fk_sessao, fk_exercicio), -- Identificador único do registro
	CONSTRAINT fk_exercicio_na_sessao_sessao 
		FOREIGN KEY (fk_sessao) 
			REFERENCES sessao (id_sessao),
	CONSTRAINT fk_exercicio_na_sessao_exercicio 
		FOREIGN KEY (fk_exercicio) 
			REFERENCES exercicio (id_exercicio)
);

-- -----------------------------------------------------
-- Tabela: exercicio_em_casa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS exercicio_em_casa (
  fk_evolucao INT NOT NULL, -- Foreign key para vincular sessao
  fk_exercicio INT NOT NULL, -- Foreign key para vincular exercicio
  segmento VARCHAR(45) NULL, -- Parte do corpo trabalhada no exercício (ex: membro superior, tronco)
  quantidade_series INT NULL, -- Quantidade de séries realizadas do exercício
  quantidade_repeticoes INT NULL, -- Quantidade de repetições por série
  carga INT NULL, -- Peso ou resistência utilizada no exercício
  tempo TIME NULL, -- Tempo de duração do exercício (para exercícios cronometrados)
	PRIMARY KEY (fk_evolucao, fk_exercicio), -- Identificador único do registro
	CONSTRAINT fk_exercicio_em_casa_evolucao 
		FOREIGN KEY (fk_evolucao) 
			REFERENCES evolucao (id_evolucao),
	CONSTRAINT fk_exercicio_em_casa_exercicio 
		FOREIGN KEY (fk_exercicio) 
			REFERENCES exercicio (id_exercicio)
);