--====================================================================
-- **** Query para ser consumida no PBI e ter panorama dos sinomas mais frequentes ****

SELECT
    sintoma,
    -- soma quando os pacientes responderam sim a pergunta se foram entubados
    SUM(CASE WHEN B006 = 1 AND valor = 1 THEN 1 ELSE 0 END) AS quantidade_entubado
FROM
    PNAD_COVID
-- deixa os sintomas em linhas
CROSS APPLY (
    VALUES
        ('Febre', B0011),
        ('Tosse', B0012),
        ('Dor de garganta', B0013),
        ('Dificuldade para respirar', B0014),
        ('Dor de cabeça', B0015),
        ('Dor no peito', B0016),
        ('Náusea', B0017),
        ('Nariz entupido/coriza', B0018),
        ('Fadiga', B0019),
        ('Dor nos olhos', B00110),
        ('Perda de olfato/paladar', B00111),
        ('Dor muscular', B00112)
) AS SINTOMAS (sintoma, valor)
GROUP BY
    sintoma;

--====================================================================
-- **** Query para ser consumida no PBI e ter agrupamento de idade de pacientes entubados ****

SELECT
    -- função agrupar por idades
    CASE
        WHEN A002 BETWEEN 15 AND 24 THEN '15-24'
        WHEN A002 BETWEEN 25 AND 34 THEN '25-34'
        WHEN A002 BETWEEN 35 AND 44 THEN '35-44'
        WHEN A002 BETWEEN 45 AND 54 THEN '45-54'
        WHEN A002 BETWEEN 55 AND 64 THEN '55-64'
        WHEN A002 >= 65 THEN '65+'
        WHEN A002 < 15 THEN '< 15'
    END AS faixa_etaria,

    --coluna com o total de pacientes que responderam sim a pergunta B006
    SUM(CASE WHEN B006 = 1 THEN 1 ELSE 0 END) AS quantidade_entubado
FROM
    PNAD_COVID
WHERE B006 = 1
GROUP BY
    CASE
        WHEN A002 BETWEEN 15 AND 24 THEN '15-24'
        WHEN A002 BETWEEN 25 AND 34 THEN '25-34'
        WHEN A002 BETWEEN 35 AND 44 THEN '35-44'
        WHEN A002 BETWEEN 45 AND 54 THEN '45-54'
        WHEN A002 BETWEEN 55 AND 64 THEN '55-64'
        WHEN A002 >= 65 THEN '65+'
        WHEN A002 < 15 THEN '< 15'
    END
--====================================================================
-- **** Query para ser consumida no PBI e segmentar por estados os entrevistados que buscaram e não buscaram ajuda****

SELECT
    --- traduz coluna UF
    CASE UF
        WHEN 11 THEN 'Rondônia'
        WHEN 12 THEN 'Acre'
        WHEN 13 THEN 'Amazonas'
        WHEN 14 THEN 'Roraima'
        WHEN 15 THEN 'Pará'
        WHEN 16 THEN 'Amapá'
        WHEN 17 THEN 'Tocantins'
        WHEN 21 THEN 'Maranhão'
        WHEN 22 THEN 'Piauí'
        WHEN 23 THEN 'Ceará'
        WHEN 24 THEN 'Rio Grande do Norte'
        WHEN 25 THEN 'Paraíba'
        WHEN 26 THEN 'Pernambuco'
        WHEN 27 THEN 'Alagoas'
        WHEN 28 THEN 'Sergipe'
        WHEN 29 THEN 'Bahia'
        WHEN 31 THEN 'Minas Gerais'
        WHEN 32 THEN 'Espírito Santo'
        WHEN 33 THEN 'Rio de Janeiro'
        WHEN 35 THEN 'São Paulo'
        WHEN 41 THEN 'Paraná'
        WHEN 42 THEN 'Santa Catarina'
        WHEN 43 THEN 'Rio Grande do Sul'
        WHEN 50 THEN 'Mato Grosso do Sul'
        WHEN 51 THEN 'Mato Grosso'
        WHEN 52 THEN 'Goiás'
        WHEN 53 THEN 'Distrito Federal'
    END AS Estado,

    COUNT(*) AS Totals,
    --- soma quem respondeu sim a pergunta B002
    SUM(CASE WHEN B002 = 1 THEN 1 ELSE 0 END) AS procurou_sitema,
    --- soma quem respondeu não a pergunta B002
    SUM(CASE WHEN B002 = 2 THEN 1 ELSE 0 END) AS nao_procurou_sistema,

    --- calculo para encontrar porcentagem de quem respondeu sim e não nas colunas anteriores
    CAST(CAST(SUM(CASE WHEN B002 = 2 THEN 1 ELSE 0 END) AS DECIMAL) / CAST(COUNT(*) AS DECIMAL) * 100 AS DECIMAL(10, 2)) AS porcentagem_naoprocurou,
	CAST(CAST(SUM(CASE WHEN B002 = 1 THEN 1 ELSE 0 END) AS DECIMAL) / CAST(COUNT(*) AS DECIMAL) * 100 AS DECIMAL(10, 2)) AS porcentagem_procurou
FROM PNAD_COVID
---- filtra quem respondem sim aos sintomas B011, B0012 e B0014
WHERE B0011 = 1
      AND B0012 = 1
      AND B0014 = 1

GROUP BY UF

--====================================================================
-- **** Query para ser consumida no PBI para calcular os totais usados no dashboard****
SELECT
	SUM(CASE WHEN B006 = 1 THEN 1 ELSE 0 END) AS quantidade_entubado,
	SUM(CASE WHEN B005 = 1 THEN 1 ELSE 0 END) AS quantidade_internados,
	SUM(CASE WHEN A002 >= 45 AND B006=1 THEN 1 ELSE 0 END) AS quantidade_idaderisco
FROM
    PNAD_COVID


