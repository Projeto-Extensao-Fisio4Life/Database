USE fisio4life;

-- 1. ENDEREÇOS

INSERT INTO endereco (
    logradouro, numero, bairro, cidade, estado, cep
)
VALUES
('Rua de Teste BI', 100, 'Centro', 'Osasco', 'SP', '06000000'),
('Avenida de Teste BI', 200, 'Centro', 'Osasco', 'SP', '06000001');

-- 2. USUÁRIOS

INSERT INTO usuario (
	fk_endereco, nome, data_nascimento, telefone, celular, email, senha, tipo_usuario, status_usuario
)
VALUES
(1, 'Samara BI', '1995-05-10', '11999999991', '11988888891', 'samara@teste.com', 'senha_teste', 'COMUM', 1),
(1, 'Vicky BI', '1995-05-10', '11999999992', '11988888892', 'vicky@teste.com', 'senha_teste', 'COMUM', 1),
(1, 'Paciente Ativo BI', '1997-03-10', '11999999993', '11988888893', 'ativo@teste.com', 'senha_teste', 'COMUM', 1),
(1, 'Paciente Concluído BI', '1998-04-10', '11999999994', '11988888894', 'concluido@teste.com', 'senha_teste', 'COMUM', 1),
(2, 'Fisioterapeuta BI', '1990-05-10', '11999999995', '11988888895', 'fisio@teste.com', 'senha_teste', 'FISIOTERAPEUTA', 1);

select * from usuario;

-- 3. PACIENTE

INSERT INTO paciente (
    fk_usuario, cpf, permite_atendimento_grupo
)
VALUES
(1, '11111111111', 1),
(2, '22222222222', 1),
(3, '33333333333', 1),
(4, '44444444444', 1);

-- 4. FISIOTERAPEUTA

INSERT INTO fisioterapeuta (
    fk_usuario, crefito, especialidade, cnpj
)
VALUES (
    5, '1234567890', 'Ortopedia', '12345678000199'
);

-- 5. CLÍNICA

INSERT INTO clinica (
    fk_endereco, nome, cnpj, telefone, celular, email
)
VALUES (
    2, 'Clínica Teste BI', '98765432000199', '1133333333', '11977777777', 'clinica@teste.com'
);

-- 6. PRONTUÁRIOS

INSERT INTO prontuario (
    fk_paciente, status_prontuario, observacao_inicial
)
VALUES
(1, 'EM ANDAMENTO', 'Tratamento em andamento'),
(2, 'EM ANDAMENTO', 'Paciente sem agendamento válido'),
(3, 'EM ANDAMENTO', 'Tratamento em andamento'),
(4, 'CONCLUIDO', 'Tratamento finalizado');

-- 7. AGENDAMENTOS
-- Status 1 = CANCELADO
-- Status 0 = NÃO CANCELADO (utilizado no teste)

INSERT INTO agendamento (
    fk_clinica, fk_fisioterapeuta, fk_paciente, tipo_atendimento, status_agendamento, observacao
)
VALUES

(1, 1, 1, 'INDIVIDUAL', 0, 'Primeiro agendamento'),
(1, 1, 2, 'INDIVIDUAL', 0, 'Segundo agendamento'),
(1, 1, 2, 'INDIVIDUAL', 1, 'Agendamento cancelado'),
(1, 1, 3, 'INDIVIDUAL', 0, 'Agendamento válido'),
(1, 1, 4, 'INDIVIDUAL', 0, 'Agendamento válido');

INSERT INTO servico (
    valor, nome, quantidade_sessoes, tipo, status_servico
)
VALUES
(1000.00, 'Pacote Fisioterapia - 5 Sessões', 5, 'FISIOTERAPIA', 1),
(1800.00, 'Pacote Fisioterapia - 10 Sessões', 10, 'FISIOTERAPIA', 1);

INSERT INTO servico_contratado (
    fk_paciente, fk_servico, status_servico, observacao
)
VALUES
(1, 1, 'CONCLUÍDO', 'Primeiro pacote finalizado'),
(1, 1, 'EM ANDAMENTO', 'Novo pacote contratado'),
(2, 1, 'CANCELADO', 'Pacote cancelado'),
(3, 2, 'EM ANDAMENTO', 'Pacote em andamento'),
(4, 2, 'CONCLUÍDO', 'Pacote finalizado');