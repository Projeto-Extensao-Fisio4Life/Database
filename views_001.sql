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

-- 2. % Usuários Ativos Agendando

-- /////////////////////////////////////////////////////////////////////////////////////

-- 3. Índice de Concentração por Fisioterapeuta

-- /////////////////////////////////////////////////////////////////////////////////////

-- 4. Satisfação & Renovação de Pacotes

-- /////////////////////////////////////////////////////////////////////////////////////