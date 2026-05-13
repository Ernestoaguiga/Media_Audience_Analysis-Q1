-- ============================================================
-- TELEVISA RATINGS INTELLIGENCE — SQL Analytics Queries
-- Autor: Hugo Ernesto Aguilar Gallardo
-- Descripción: KPIs y análisis de audiencias para dashboard BI
-- Dataset: televisa_ratings_mock (520 registros, 52 semanas, 10 programas)
-- ============================================================

-- ─────────────────────────────────────────────────
-- SECCIÓN 1: SETUP — Crear tabla e importar datos
-- ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS televisa_ratings (
    semana              INT,
    fecha_inicio_semana DATE,
    trimestre           VARCHAR(5),
    programa            VARCHAR(100),
    genero              VARCHAR(50),
    canal               VARCHAR(50),
    horario             VARCHAR(10),
    franja_horaria      VARCHAR(30),
    temporada           INT,
    episodio            INT,
    rating              NUMERIC(5,2),
    share_pct           NUMERIC(5,2),
    audiencia_millones  NUMERIC(5,2),
    rating_azteca       NUMERIC(5,2),
    rating_canal5       NUMERIC(5,2),
    demo_18_34_pct      NUMERIC(5,2),
    demo_35_54_pct      NUMERIC(5,2),
    demo_55plus_pct     NUMERIC(5,2)
);

-- ─────────────────────────────────────────────────
-- SECCIÓN 2: KPIs EJECUTIVOS (Página 1 del Dashboard)
-- ─────────────────────────────────────────────────

-- KPI 1: Rating promedio general del año
SELECT 
    ROUND(AVG(rating), 2)               AS rating_promedio_anual,
    ROUND(AVG(share_pct), 2)            AS share_promedio_pct,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_promedio_mm,
    COUNT(DISTINCT programa)            AS total_programas,
    COUNT(DISTINCT canal)               AS total_canales
FROM televisa_ratings;

-- KPI 2: Top 5 programas por rating promedio
SELECT 
    programa,
    canal,
    genero,
    ROUND(AVG(rating), 2)               AS rating_promedio,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_promedio_mm,
    ROUND(AVG(share_pct), 2)            AS share_promedio
FROM televisa_ratings
GROUP BY programa, canal, genero
ORDER BY rating_promedio DESC
LIMIT 5;

-- KPI 3: Tendencia de rating por trimestre
SELECT 
    trimestre,
    ROUND(AVG(rating), 2)               AS rating_promedio,
    ROUND(AVG(share_pct), 2)            AS share_promedio,
    ROUND(SUM(audiencia_millones), 0)   AS audiencia_total_mm,
    COUNT(*)                            AS emisiones_totales
FROM televisa_ratings
GROUP BY trimestre
ORDER BY trimestre;

-- KPI 4: Comparativa mensual de rating (últimas 8 semanas simuladas)
SELECT 
    semana,
    fecha_inicio_semana,
    ROUND(AVG(rating), 2)               AS rating_semanal,
    ROUND(AVG(share_pct), 2)            AS share_semanal,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_semanal_mm
FROM televisa_ratings
WHERE semana >= 45
GROUP BY semana, fecha_inicio_semana
ORDER BY semana;

-- ─────────────────────────────────────────────────
-- SECCIÓN 3: RENDIMIENTO DE PROGRAMAS (Página 2)
-- ─────────────────────────────────────────────────

-- Q5: Evolución de rating por programa y temporada
SELECT 
    programa,
    temporada,
    episodio,
    fecha_inicio_semana,
    rating,
    share_pct,
    audiencia_millones,
    -- Promedio móvil 4 semanas
    ROUND(AVG(rating) OVER (
        PARTITION BY programa 
        ORDER BY semana 
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ), 2) AS rating_movil_4sem
FROM televisa_ratings
ORDER BY programa, semana;

-- Q6: Variación de rating vs semana anterior por programa
SELECT 
    programa,
    semana,
    fecha_inicio_semana,
    rating,
    LAG(rating) OVER (PARTITION BY programa ORDER BY semana) AS rating_semana_anterior,
    ROUND(rating - LAG(rating) OVER (PARTITION BY programa ORDER BY semana), 2) AS variacion_absoluta,
    ROUND(
        CASE WHEN LAG(rating) OVER (PARTITION BY programa ORDER BY semana) > 0 
        THEN ((rating - LAG(rating) OVER (PARTITION BY programa ORDER BY semana)) 
              / LAG(rating) OVER (PARTITION BY programa ORDER BY semana)) * 100
        ELSE NULL END
    , 2) AS variacion_pct
FROM televisa_ratings
ORDER BY programa, semana;

-- Q7: Rating máximo, mínimo y rango por programa
SELECT 
    programa,
    canal,
    ROUND(MAX(rating), 2)               AS rating_maximo,
    ROUND(MIN(rating), 2)               AS rating_minimo,
    ROUND(AVG(rating), 2)               AS rating_promedio,
    ROUND(MAX(rating) - MIN(rating), 2) AS rango_rating,
    ROUND(STDDEV(rating), 2)            AS desviacion_estandar
FROM televisa_ratings
GROUP BY programa, canal
ORDER BY rating_promedio DESC;

-- Q8: Comparativa temporada actual vs anterior
SELECT 
    programa,
    temporada,
    ROUND(AVG(rating), 2)               AS rating_promedio,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_promedio_mm,
    LAG(ROUND(AVG(rating), 2)) OVER (PARTITION BY programa ORDER BY temporada) AS rating_temporada_anterior,
    ROUND(
        AVG(rating) - LAG(AVG(rating)) OVER (PARTITION BY programa ORDER BY temporada)
    , 2) AS diferencia_vs_temporada_anterior
FROM televisa_ratings
GROUP BY programa, temporada
ORDER BY programa, temporada;

-- ─────────────────────────────────────────────────
-- SECCIÓN 4: INTELIGENCIA DE AUDIENCIA (Página 3)
-- ─────────────────────────────────────────────────

-- Q9: Rating promedio por franja horaria
SELECT 
    franja_horaria,
    horario,
    ROUND(AVG(rating), 2)               AS rating_promedio,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_mm,
    COUNT(DISTINCT programa)            AS num_programas
FROM televisa_ratings
GROUP BY franja_horaria, horario
ORDER BY rating_promedio DESC;

-- Q10: Distribución demográfica por género de programa
SELECT 
    genero,
    ROUND(AVG(demo_18_34_pct), 1)       AS demo_18_34_avg,
    ROUND(AVG(demo_35_54_pct), 1)       AS demo_35_54_avg,
    ROUND(AVG(demo_55plus_pct), 1)      AS demo_55plus_avg,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_mm,
    COUNT(DISTINCT programa)            AS programas
FROM televisa_ratings
GROUP BY genero
ORDER BY audiencia_mm DESC;

-- Q11: Top programa por franja horaria
SELECT DISTINCT ON (franja_horaria)
    franja_horaria,
    programa,
    canal,
    ROUND(AVG(rating) OVER (PARTITION BY programa), 2) AS rating_promedio,
    ROUND(AVG(audiencia_millones) OVER (PARTITION BY programa), 2) AS audiencia_mm
FROM televisa_ratings
ORDER BY franja_horaria, rating_promedio DESC;

-- Q12: Estacionalidad — rating promedio por mes del año
SELECT 
    TO_CHAR(fecha_inicio_semana, 'MM') AS mes_num,
    TO_CHAR(fecha_inicio_semana, 'Mon') AS mes,
    ROUND(AVG(rating), 2)               AS rating_promedio,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_mm
FROM televisa_ratings
GROUP BY mes_num, mes
ORDER BY mes_num;

-- ─────────────────────────────────────────────────
-- SECCIÓN 5: LANDSCAPE COMPETITIVO (Página 4)
-- ─────────────────────────────────────────────────

-- Q13: Televisa vs competencia por franja horaria
SELECT 
    franja_horaria,
    ROUND(AVG(rating), 2)           AS televisa_rating,
    ROUND(AVG(rating_azteca), 2)    AS azteca_rating,
    ROUND(AVG(rating_canal5), 2)    AS canal5_rating,
    ROUND(AVG(rating) - AVG(rating_azteca), 2)  AS ventaja_vs_azteca,
    ROUND(
        CASE WHEN AVG(rating_azteca) > 0 
        THEN ((AVG(rating) - AVG(rating_azteca)) / AVG(rating_azteca)) * 100
        ELSE NULL END
    , 1) AS ventaja_pct_vs_azteca
FROM televisa_ratings
GROUP BY franja_horaria
ORDER BY televisa_rating DESC;

-- Q14: Evolución semanal comparativa Televisa vs Azteca
SELECT 
    semana,
    fecha_inicio_semana,
    ROUND(AVG(rating), 2)           AS televisa_promedio,
    ROUND(AVG(rating_azteca), 2)    AS azteca_promedio,
    ROUND(AVG(rating) - AVG(rating_azteca), 2) AS diferencial
FROM televisa_ratings
GROUP BY semana, fecha_inicio_semana
ORDER BY semana;

-- Q15: Share total por canal
SELECT 
    canal,
    ROUND(AVG(share_pct), 2)            AS share_promedio,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_promedio_mm,
    COUNT(DISTINCT programa)            AS programas_en_cartel
FROM televisa_ratings
GROUP BY canal
ORDER BY share_promedio DESC;

-- Q16: Scatter — Rating vs Audiencia (para identificar outliers)
SELECT 
    programa,
    canal,
    genero,
    ROUND(AVG(rating), 2)               AS rating_promedio,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_promedio_mm,
    ROUND(AVG(share_pct), 2)            AS share_promedio,
    -- Clasificación de performance
    CASE 
        WHEN AVG(rating) >= 7 THEN 'Estrella'
        WHEN AVG(rating) >= 5 THEN 'Sólido'
        WHEN AVG(rating) >= 3 THEN 'Regular'
        ELSE 'Bajo Rendimiento'
    END AS categoria_performance
FROM televisa_ratings
GROUP BY programa, canal, genero
ORDER BY rating_promedio DESC;

-- ─────────────────────────────────────────────────
-- SECCIÓN 6: VISTAS ETL (para Power BI Direct Query)
-- ─────────────────────────────────────────────────

-- Vista 1: KPIs Ejecutivos Agregados
CREATE OR REPLACE VIEW vw_kpis_ejecutivos AS
SELECT 
    trimestre,
    canal,
    genero,
    franja_horaria,
    ROUND(AVG(rating), 2)               AS rating_promedio,
    ROUND(AVG(share_pct), 2)            AS share_promedio,
    ROUND(AVG(audiencia_millones), 2)   AS audiencia_promedio_mm,
    ROUND(MAX(rating), 2)               AS rating_maximo,
    COUNT(*)                            AS total_emisiones
FROM televisa_ratings
GROUP BY trimestre, canal, genero, franja_horaria;

-- Vista 2: Tendencia semanal por programa
CREATE OR REPLACE VIEW vw_tendencia_semanal AS
SELECT 
    programa,
    canal,
    semana,
    fecha_inicio_semana,
    rating,
    share_pct,
    audiencia_millones,
    ROUND(AVG(rating) OVER (
        PARTITION BY programa ORDER BY semana ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ), 2) AS rating_ma4,
    LAG(rating) OVER (PARTITION BY programa ORDER BY semana) AS rating_prev,
    ROUND(rating - LAG(rating) OVER (PARTITION BY programa ORDER BY semana), 2) AS delta_rating
FROM televisa_ratings;

-- Vista 3: Análisis Competitivo
CREATE OR REPLACE VIEW vw_competencia AS
SELECT 
    semana,
    fecha_inicio_semana,
    franja_horaria,
    canal,
    programa,
    rating                              AS televisa_rating,
    rating_azteca,
    rating_canal5,
    share_pct,
    ROUND(rating - rating_azteca, 2)    AS ventaja_vs_azteca,
    CASE 
        WHEN rating > rating_azteca THEN 'Televisa Lidera'
        WHEN rating < rating_azteca THEN 'Azteca Lidera'
        ELSE 'Empate'
    END AS posicion_competitiva
FROM televisa_ratings;

