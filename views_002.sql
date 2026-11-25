USE fisio4life;	

-- 1. MÉTRICA FATURAMENTO MENSAL + VARIAÇÃO PERCENTUAL

CREATE OR REPLACE VIEW vw_faturamento_mensal AS

-- Primeira Tabela Temp: FATURAMENTO
-- Responsável por calcular o faturamento de cada mês
WITH faturamento AS (

    SELECT
        -- Extrai o ano da data em que o pagamento foi concluído
        YEAR(data_concluida) AS ano,

        -- Extrai o mês da data em que o pagamento foi concluído
        MONTH(data_concluida) AS mes,

        -- Soma os valores de todos os pagamentos realizados no mês
        SUM(valor) AS receita_mensal,

        -- Conta quantos pagamentos foram realizados no mês
        COUNT(id_pagamento) AS quantidade_pagamentos

    FROM pagamento

    -- Considera somente os pagamentos com status 1 (realizado)
    WHERE status_pagamento = 1

    -- Agrupa os pagamentos por ano e mês
    -- Assim todos os pagamentos do mesmo mês são somados juntos
    GROUP BY
        YEAR(data_concluida),
        MONTH(data_concluida)

),

-- Segunda Tabela Temp: EVOLUÇÃO
-- Responsável por recuperar o faturamento do mês anterior,
-- permitindo comparar a receita entre os meses
evolucao AS (

    SELECT
        ano,
        mes,
        receita_mensal,
        quantidade_pagamentos,

        -- LAG() acessa o valor da linha anterior
        LAG(receita_mensal) OVER (

            -- Organiza os registros cronologicamente,
            -- primeiro pelo ano e depois pelo mês
            ORDER BY ano, mes

        ) AS receita_mes_anterior

    -- Utiliza os dados calculados na primeira tabela temp
    FROM faturamento

)

-- SELECT PRINCIPAL
-- Apresenta os dados do faturamento e calcula
-- a variação percentual em relação ao mês anterior.
SELECT
    ano,
    mes,
    -- Formata o período no padrão MM/AAAA
    -- LPAD adiciona um zero à esquerda quando necessário
    -- CONCAT junta o mês e o ano em uma única coluna
    CONCAT(
        LPAD(mes, 2, '0'),
        '/',
        ano
    ) AS periodo,

    -- Valor total recebido no mês
    receita_mensal,

    -- Quantidade de pagamentos realizados no mês
    quantidade_pagamentos,

    -- Valor recebido no mês anterior
    receita_mes_anterior,

    -- Calcula a variação percentual entre o mês atual
    -- e o mês anterior
    CASE
        -- Se não existir mês anterior ou se a receita
        -- anterior for zero, não realiza a divisão
        WHEN receita_mes_anterior IS NULL
             OR receita_mes_anterior = 0
        THEN NULL
        -- Calcula a porcentagem de crescimento ou redução
        ELSE ROUND(
            (
                -- Diferença entre a receita atual e anterior
                (receita_mensal - receita_mes_anterior)

                -- Divide pela receita do mês anterior
                / receita_mes_anterior
            ) * 100, -- Multiplica por 100 para obter porcentagem
            2 -- Arredonda o resultado para duas casas decimais
        )

    END AS variacao_percentual

-- Utiliza os dados da segunda Tabela Temp
FROM evolucao;

-- CONSULTAR FATURAMENTO

SELECT *
FROM vw_faturamento_mensal
ORDER BY ano, mes;

-- /////////////////////////////////////////////////////////////////////////////////////

-- 2. % Usuários Ativos Agendando - Taxa de Conversão em Agenda
-- Prontuário: Em andamento 
-- Se esses pacientes possuem agendamentos

-- Paciente com prontuário EM ANDAMENTO e com agendamento: usuário ativo.
-- Paciente com prontuário EM ANDAMENTO, mas sem agendamento: usuário inativo.


-- =====================================================
-- VIEW: USUÁRIOS ATIVOS AGENDANDO
-- Objetivo: Identificar quantos pacientes possuem
-- prontuário em andamento e possuem agendamentos válidos.
-- =====================================================

CREATE OR REPLACE VIEW vw_usuarios_ativos_agendando AS

-- CTE: CLASSIFICACAO
-- Identifica os pacientes que possuem prontuário
-- em andamento e verifica se possuem agendamentos.

WITH classificacao AS (

    SELECT
        p.id_paciente,
        -- EXISTS verifica se existe pelo menos
        -- um agendamento não cancelado para o paciente.
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM agendamento a
                WHERE a.fk_paciente = p.id_paciente
                -- Desconsidera agendamentos cancelados
                AND a.status_agendamento <> 1
            )
            -- Se encontrar um agendamento válido,
            -- classifica o paciente como ativo.
            THEN 'ATIVO'
            -- Caso não encontre, classifica como inativo.
            ELSE 'INATIVO'
        END AS classificacao_usuario
    -- Tabela de pacientes
    FROM paciente p
    -- Relaciona o paciente ao seu prontuário
    INNER JOIN prontuario pr
        ON pr.fk_paciente = p.id_paciente
    -- Considera somente prontuários em andamento
    WHERE pr.status_prontuario = 'EM ANDAMENTO'
)
-- SELECT PRINCIPAL
-- Conta os pacientes ativos e inativos
-- e calcula a taxa de conversão em agenda.
SELECT
    -- Quantidade total de pacientes com prontuário
    -- em andamento
    COUNT(*) AS total_pacientes,
    -- Quantidade de pacientes que possuem
    -- pelo menos um agendamento válido
    SUM(
        CASE
            WHEN classificacao_usuario = 'ATIVO'
            THEN 1
            ELSE 0
        END
    ) AS usuarios_ativos,
    -- Quantidade de pacientes sem agendamentos válidos
    SUM(
        CASE
            WHEN classificacao_usuario = 'INATIVO'
            THEN 1
            ELSE 0
        END
    ) AS usuarios_inativos,
    -- Calcula a porcentagem de pacientes ativos
    -- em relação ao total de pacientes com
    -- prontuário em andamento
    ROUND(
        (
            SUM(
                CASE
                    WHEN classificacao_usuario = 'ATIVO'
                    THEN 1
                    ELSE 0
                END
            ) / NULLIF(COUNT(*), 0)
        ) * 100,
        2
    ) AS percentual_conversao
FROM classificacao;

-- CONSULTA DA VIEW

SELECT *
FROM vw_usuarios_ativos_agendando;

-- /////////////////////////////////////////////////////////////////////////////////////

-- 3. Índice de Concentração por Fisioterapeuta

CREATE OR REPLACE VIEW vw_concentracao_fisioterapeuta AS

-- Conta pacientes distintos e agendamentos
-- de cada fisioterapeuta.
WITH distribuicao AS (
    SELECT
        f.id_fisioterapeuta,
        u.nome AS fisioterapeuta,
        COUNT(DISTINCT a.fk_paciente) AS total_pacientes,
        COUNT(a.id_agendamento) AS total_agendamentos
    FROM fisioterapeuta f
    INNER JOIN usuario u
        ON u.id_usuario = f.fk_usuario
    LEFT JOIN agendamento a
        ON a.fk_fisioterapeuta = f.id_fisioterapeuta
        AND a.status_agendamento <> 1
    GROUP BY
        f.id_fisioterapeuta,
        u.nome
)
SELECT
    id_fisioterapeuta,
    fisioterapeuta,
    total_pacientes,
    total_agendamentos,
    -- Percentual de pacientes na carteira
    ROUND(
        total_pacientes * 100.0 /
        NULLIF(SUM(total_pacientes) OVER (), 0),
        2
    ) AS percentual_carteira,
    -- Percentual de participação nos agendamentos
    ROUND(
        total_agendamentos * 100.0 /
        NULLIF(SUM(total_agendamentos) OVER (), 0),
        2
    ) AS percentual_consultas

FROM distribuicao;

-- CONSULTA DA VIEW

SELECT *
FROM vw_concentracao_fisioterapeuta;

-- /////////////////////////////////////////////////////////////////////////////////////

-- 4. Satisfação & Renovação de Pacotes


CREATE OR REPLACE VIEW vw_satisfacao_renovacao AS

WITH indicadores_paciente AS (

    SELECT
        p.id_paciente,
        u.nome AS nome_paciente,

        -- Quantidade total de serviços contratados
        COUNT(sc.id_servico_contratado) AS total_servicos,

        -- Quantidade de serviços concluídos
        SUM(
            CASE
                WHEN sc.status_servico = 'CONCLUÍDO'
                THEN 1
                ELSE 0
            END
        ) AS servicos_concluidos,

        -- Quantidade de serviços em andamento
        SUM(
            CASE
                WHEN sc.status_servico = 'EM ANDAMENTO'
                THEN 1
                ELSE 0
            END
        ) AS servicos_em_andamento,

        -- Quantidade de serviços cancelados
        SUM(
            CASE
                WHEN sc.status_servico = 'CANCELADO'
                THEN 1
                ELSE 0
            END
        ) AS servicos_cancelados,

        -- Verifica se o paciente possui algum serviço concluído
        MAX(
            CASE
                WHEN sc.status_servico = 'CONCLUÍDO'
                THEN 1
                ELSE 0
            END
        ) AS possui_servico_concluido

    FROM paciente p

    INNER JOIN usuario u
        ON u.id_usuario = p.fk_usuario

    INNER JOIN servico_contratado sc
        ON sc.fk_paciente = p.id_paciente

    GROUP BY
        p.id_paciente,
        u.nome
),

classificacao AS (

    SELECT
        id_paciente,
        nome_paciente,
        total_servicos,
        servicos_concluidos,
        servicos_em_andamento,
        servicos_cancelados,

        -- Serviços positivos:
        -- Concluídos e em andamento quando existe
        -- pelo menos outro serviço concluído.
        servicos_concluidos
        +
        CASE
            WHEN possui_servico_concluido = 1
            THEN servicos_em_andamento
            ELSE 0
        END AS servicos_positivos,

        -- Serviços negativos: cancelados
        servicos_cancelados AS servicos_negativos,

        -- Serviços em andamento sem histórico concluído
        CASE
            WHEN possui_servico_concluido = 0
            THEN servicos_em_andamento
            ELSE 0
        END AS servicos_neutros,

        -- Considera renovação quando existem
        -- pelo menos dois serviços não cancelados
        -- e pelo menos um deles foi concluído.
        CASE
            WHEN total_servicos - servicos_cancelados > 1
                 AND possui_servico_concluido = 1
            THEN 1
            ELSE 0
        END AS realizou_renovacao

    FROM indicadores_paciente
)

SELECT

    COUNT(*) AS total_pacientes,
    SUM(total_servicos) AS total_servicos_contratados,
    SUM(servicos_positivos) AS total_servicos_positivos,
    SUM(servicos_negativos) AS total_servicos_negativos,
    SUM(servicos_neutros) AS total_servicos_neutros,
    SUM(realizou_renovacao) AS pacientes_com_renovacao,

    -- Percentual de renovação entre os pacientes
    ROUND(
        SUM(realizou_renovacao) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS percentual_renovacao,

    -- Percentual de serviços positivos
    ROUND(
        SUM(servicos_positivos) * 100.0
        / NULLIF(SUM(total_servicos), 0),
        2
    ) AS percentual_servicos_positivos,

    -- Percentual de serviços negativos
    ROUND(
        SUM(servicos_negativos) * 100.0
        / NULLIF(SUM(total_servicos), 0),
        2
    ) AS percentual_servicos_negativos

FROM classificacao;

select * from vw_satisfacao_renovacao;