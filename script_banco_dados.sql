CREATE DATABASE fisio4life;
USE fisio4life;

-- -----------------------------------------------------
-- Tabela: endereco
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS endereco (
  id_endereco INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  logradouro VARCHAR(45) NOT NULL, -- Tipo e nome da via
  numero INT NOT NULL, -- Número do local
  bairro VARCHAR(45) NOT NULL, -- Bairro
  cidade VARCHAR(45) NOT NULL, -- Cidade
  estado CHAR(2) NOT NULL, -- Sigla do estado (UF)
  cep VARCHAR(45) NOT NULL -- CEP
);

-- -----------------------------------------------------
-- Tabela: usuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS usuario (
  id_usuario INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_endereco INT NOT NULL, -- Foreign key para vincular endereço
  nome VARCHAR(255) NOT NULL, -- Nome completo do usuário
  data_nascimento DATE NOT NULL, -- Data de nascimento
  telefone CHAR(14), -- Número de telefone
  celular CHAR(14) NOT NULL, -- Número do celular
  email VARCHAR(45) NOT NULL, -- Endereço digital
  senha VARCHAR(60) NOT NULL, -- Senha de acesso
  tipo_usuario VARCHAR(45) NOT NULL, -- Tipo de usuário (permissões)
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Data de cadastro
  status_usuario TINYINT NOT NULL, -- Indica se está ativo ou inativo
  CONSTRAINT fk_usuario_endereco FOREIGN KEY (fk_endereco) REFERENCES endereco (id_endereco),
  CONSTRAINT fk_usuario_contato FOREIGN KEY (fk_contato) REFERENCES contato (id_contato)
);

-- -----------------------------------------------------
-- Tabela: paciente
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS paciente (
  id_paciente INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_usuario INT NOT NULL UNIQUE, -- Foreign key para vincular usuario
  cpf CHAR(11) NOT NULL UNIQUE, -- Cadastro de Pessoa Fisica (CPF)
  permite_atendimento_grupo TINYINT NOT NULL, -- Permite atendimento individual ou em grupo
  crefito_fisioterapeuta CHAR(10), -- Identificar o fisioterapeuar que o usuário tem preferência 
  CONSTRAINT fk_paciente_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario (id_usuario)
);

-- -----------------------------------------------------
-- Tabela: fisioterapeuta
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS fisioterapeuta (
  id_fisioterapeuta INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_usuario INT NOT NULL UNIQUE, -- Referência à tabela de usuario
  crefito CHAR(10) NOT NULL UNIQUE, -- Registro profissional CREFITO
  especialidade VARCHAR(45) NOT NULL, -- Especialidade técnica
  cnpj CHAR(14) NOT NULL UNIQUE, -- CNPJ
  CONSTRAINT fk_fisioterapeuta_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario (id_usuario)
);

-- -----------------------------------------------------
-- Tabela: clinica
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS clinica (
  id_clinica INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_endereco INT NOT NULL UNIQUE, -- Foreign key para vincular endereco
  nome VARCHAR(255) NOT NULL, -- Nome da clínica
  cnpj CHAR(14) NOT NULL UNIQUE, -- Cadastro Nacional da Pessoa Jurídica (CNPJ)
  telefone CHAR(14), -- Número de telefone
  celular CHAR(14) NOT NULL, -- Número do celular
  email VARCHAR(45) NOT NULL, -- Endereço digital
  CONSTRAINT fk_clinica_contato FOREIGN KEY (fk_contato) REFERENCES contato (id_contato),
  CONSTRAINT fk_clinica_endereco FOREIGN KEY (fk_endereco) REFERENCES endereco (id_endereco)
);

-- -----------------------------------------------------
-- Tabela: agenda_fisioterapeuta
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agenda_fisioterapeuta (
  id_agenda_fisioterapeuta INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_fisioterapeuta INT NOT NULL, -- Referência à tabela de fisioterapeuta
  fk_clinica INT NOT NULL, -- Referência à tabela de clinica
  data_agenda DATE NOT NULL, -- Data que acontecerá a sessão
  hora_inicio TIME NOT NULL, -- Horário de início
  hora_fim TIME NOT NULL, -- Horário de término
  status_agenda TINYINT NOT NULL, -- Status do agendamento
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Data do cadastro
  CONSTRAINT fk_fisioterapeuta_agenda FOREIGN KEY (fk_fisioterapeuta) REFERENCES fisioterapeuta (id_fisioterapeuta),
  CONSTRAINT fk_clinica_agenda FOREIGN KEY (fk_clinica) REFERENCES clinica (id_clinica)
);

-- -----------------------------------------------------
-- Tabela: bloqueio_agenda
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS bloqueio_agenda (
  id_bloqueio INT PRIMARY KEY AUTO_INCREMENT,  -- Identificador único do registro
  fk_fisioterapeuta INT NOT NULL, -- Foreign key para vincular fisioterapeuta
  fk_clinica INT NOT NULL, -- Referência à tabela de clinica
  data_inicio TIMESTAMP NOT NULL, -- Horário de início
  data_fim TIMESTAMP NOT NULL, -- Horário de fim
  dia_inteiro TINYINT NOT NULL DEFAULT 1, -- 1 = Sim, 0 = Não
  tipo_bloqueio VARCHAR(45) NOT NULL,    -- Ex: 'FOLGA', 'FERIAS', 'COMPROMISSO'
  CONSTRAINT fk_bloqueio_fisio FOREIGN KEY (fk_fisioterapeuta) REFERENCES fisioterapeuta(id_fisioterapeuta),
  CONSTRAINT fk_clinica_bloqueio FOREIGN KEY (fk_clinica) REFERENCES clinica (id_clinica)
);

-- -----------------------------------------------------
-- Tabela: agendamento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agendamento (
  id_agendamento INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_clinica INT NOT NULL, -- Foreign key para vincular clinica
  fk_fisioterapeuta INT NOT NULL, -- Foreign key para vincular fisioterapeuta
  fk_paciente INT NOT NULL, -- Foreign key para vincular paciente
  tipo_atendimento VARCHAR(20) NOT NULL, -- Ex: avulsa , pacote, recovery
  status_agendamento TINYINT NOT NULL, -- Status do agendamento
  observacao VARCHAR(255) NULL, -- Informações complementares
  CONSTRAINT fk_agendamento_fisioterapeuta FOREIGN KEY (fk_fisioterapeuta) REFERENCES fisioterapeuta (id_fisioterapeuta),
  CONSTRAINT fk_agendamento_paciente FOREIGN KEY (fk_paciente) REFERENCES paciente (id_paciente)
);

-- -----------------------------------------------------
-- Tabela: servico
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS servico (
  id_servico INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  valor DECIMAL(10,2) NOT NULL, -- Valor cobrado pelo serviço
  nome VARCHAR(45) NOT NULL, -- Nome do serviço
  quantidade_sessoes INT NOT NULL, -- Quantidade de sessões do pacote/serviço
  tipo VARCHAR(20) NOT NULL, -- Categoria ou modalidade do serviço (ex.: ortopedia)
  status_servico TINYINT NOT NULL -- Indica se o serviço está ativo ou inativo
);

-- -----------------------------------------------------
-- Tabela: sessao
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS sessao (
  id_sessao INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único da sessão realizada
  fk_agendamento INT NOT NULL, -- Agendamento que originou a sessão
  fk_servico INT NOT NULL, -- Serviço realizado na sessão
  data_sessao TIMESTAMP NOT NULL, -- Data e hora da sessão
  descricao VARCHAR(255) NOT NULL, -- Descrição das atividades realizadas
  observacao VARCHAR(255) NOT NULL, -- Observações da sessão
  CONSTRAINT fk_sessao_agendamento FOREIGN KEY (fk_agendamento) REFERENCES agendamento (id_agendamento),
  CONSTRAINT fk_sessao_servico FOREIGN KEY (fk_servico) REFERENCES servico (id_servico)
);

-- -----------------------------------------------------
-- Tabela: prontuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS prontuario (
  id_prontuario INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
  fk_paciente INT NOT NULL UNIQUE, -- Foreign key para vincular paciente
  data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Data de abertura
  status_prontuario TINYINT NOT NULL, -- Status do prontuário
  observacao_inicial VARCHAR(255) NULL, -- Informações complementares
  CONSTRAINT fk_prontuario_paciente FOREIGN KEY (fk_paciente) REFERENCES paciente (id_paciente)
);

-- -----------------------------------------------------
-- Tabela: documento_prontuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS documento_prontuario (
  id_documento INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do documento
  fk_prontuario INT NOT NULL, -- Prontuário ao qual o documento pertence
  nome_arquivo VARCHAR(45) NOT NULL, -- Nome original ou identificador do arquivo
  tipo_documento VARCHAR(45) NOT NULL, -- Tipo/formato do documento
  s3_key VARCHAR(45) NOT NULL, -- Chave do objeto armazenado no Amazon S3
  url_documento VARCHAR(45) NOT NULL, -- URL ou referência de acesso ao documento
  data_upload DATETIME NOT NULL, -- Data e hora do envio do documento
  CONSTRAINT fk_documento_prontuario_prontuario FOREIGN KEY (fk_prontuario) REFERENCES prontuario (id_prontuario)
);

-- -----------------------------------------------------
-- Tabela: pagamento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pagamento (
    id_pagamento INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do registro
    fk_paciente INT, -- Foreign key para vincular paciente
    fk_servico INT, -- Foreign key para vincular servico
    valor DECIMAL(10,2) NOT NULL, -- Valor cobrado pelo serviço
    forma_pagamento VARCHAR(45) NOT NULL, -- Meio utilizado para realizar o pagamento
    status_pagamento TINYINT NOT NULL, -- Situação atual do pagamento
    data_concluida TIMESTAMP NOT NULL, -- Data em que o pagamento foi concluído
    CONSTRAINT fk_pagamento_paciente FOREIGN KEY (fk_paciente) REFERENCES paciente(id_paciente),
    CONSTRAINT fk_pagamento_servico FOREIGN KEY (fk_servico) REFERENCES servico(id_servico)
);

-- -----------------------------------------------------
-- Tabela: evolucao
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS evolucao (
  id_evolucao INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único da evolução clínica
  fk_sessao INT NOT NULL, -- Sessão à qual a evolução se refere
  fk_prontuario INT NOT NULL, -- Prontuário onde a evolução será registrada
  data_evolucao DATETIME NOT NULL, -- Data e hora do registro da evolução
  conduta VARCHAR(255) NOT NULL, -- Conduta ou procedimento aplicado
  avaliacao VARCHAR(255) NOT NULL, -- Avaliação feita pelo fisioterapeuta
  observacao VARCHAR(255) NOT NULL, -- Observações complementares da evolução
  CONSTRAINT fk_evolucao_sessao FOREIGN KEY (fk_sessao) REFERENCES sessao (id_sessao),
  CONSTRAINT fk_evolucao_prontuario FOREIGN KEY (fk_prontuario) REFERENCES prontuario (id_prontuario)
);

-- -----------------------------------------------------
-- Tabela: escala
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS escala (
  id_escala INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único da escala de avaliação
  nome VARCHAR(45) NOT NULL, -- Nome da escala aplicada ao paciente
  descricao VARCHAR(45) NOT NULL -- Descrição resumida da escala
);

-- -----------------------------------------------------
-- Tabela: escala_perguntas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS escala_perguntas (
  id_escala_perguntas INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único da pergunta da escala
  fk_escala INT NOT NULL, -- Escala à qual a pergunta pertence
  titulo_pergunta VARCHAR(45) NOT NULL, -- Texto/título da pergunta
  tipo_dado VARCHAR(45) NOT NULL, -- Tipo de resposta esperado para a pergunta
  CONSTRAINT fk_escala_perguntas_escala FOREIGN KEY (fk_escala) REFERENCES escala (id_escala)
);

-- -----------------------------------------------------
-- Tabela: escala_prontuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS escala_prontuario (
  id_escala_prontuario INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único da aplicação da escala ao prontuário
  fk_prontuario INT NOT NULL, -- Prontuário do paciente avaliado
  fk_escala INT NOT NULL, -- Escala aplicada
  data_resposta DATETIME NOT NULL, -- Data e hora em que a escala foi respondida
  CONSTRAINT fk_escala_prontuario_prontuario FOREIGN KEY (fk_prontuario) REFERENCES prontuario (id_prontuario),
  CONSTRAINT fk_escala_prontuario_escala FOREIGN KEY (fk_escala) REFERENCES escala (id_escala)
);

-- -----------------------------------------------------
-- Tabela: escala_respostas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS escala_respostas (
  id_escala_respostas INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único da resposta
  fk_escala_prontuario INT NOT NULL, -- Aplicação da escala respondida no prontuário
  fk_escala_perguntas INT NOT NULL, -- Pergunta respondida
  valor_resposta VARCHAR(45) NOT NULL, -- Valor/texto informado como resposta
  CONSTRAINT fk_escala_respostas_escala_prontuario FOREIGN KEY (fk_escala_prontuario) REFERENCES escala_prontuario (id_escala_prontuario),
  CONSTRAINT fk_escala_respostas_pergunta FOREIGN KEY (fk_escala_perguntas) REFERENCES escala_perguntas (id_escala_perguntas)
);

-- -----------------------------------------------------
-- Tabela: exercicio
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS exercicio (
  id_exercicio INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do exercício
  categoria VARCHAR(45) NOT NULL, -- Categoria ou tipo de exercício
  nome VARCHAR(45) NOT NULL -- Nome do exercício
);

-- -----------------------------------------------------
-- Tabela: exercicio_passado
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS exercicio_passado (
  id_exercicio_passado INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único do exercício prescrito/registrado
  fk_exercicio INT NOT NULL, -- Exercício relacionado ao registro
  fk_evolucao INT NOT NULL, -- Evolução clínica em que o exercício foi registrado
  segmento VARCHAR(45) NOT NULL, -- Segmento corporal trabalhado
  quantidade_series INT NOT NULL, -- Quantidade de séries realizadas ou recomendadas
  quantidade_repeticoes INT NOT NULL, -- Quantidade de repetições por série
  carga INT NOT NULL, -- Carga ou nível de resistência utilizado
  tempo TIME NOT NULL, -- Tempo de execução do exercício
  local VARCHAR(45) NOT NULL, -- Local em que o exercício deve/foi realizado
  CONSTRAINT fk_exercicio_passado_exercicio FOREIGN KEY (fk_exercicio) REFERENCES exercicio (id_exercicio),
  CONSTRAINT fk_exercicio_passado_evolucao FOREIGN KEY (fk_evolucao) REFERENCES evolucao (id_evolucao)
);
