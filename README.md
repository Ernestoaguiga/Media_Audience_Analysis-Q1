<div align="center">

<img src="assets/header_banner.svg" alt="Televisa Ratings Intelligence Dashboard" width="100%"/>

# 📺 Televisa · Ratings Intelligence Dashboard

**Plataforma analítica de audiencias, rendimiento de contenido y posicionamiento competitivo**  
*Construida con PostgreSQL · Python · Power BI · DAX*

<br/>

[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Python](https://img.shields.io/badge/Python-ETL%20Pipeline-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![DAX](https://img.shields.io/badge/DAX-20%2B%20Measures-FF6B00?style=for-the-badge)](https://learn.microsoft.com/en-us/dax/)
[![Dataset](https://img.shields.io/badge/Dataset-520%20rows%20·%2018%20cols-132040?style=for-the-badge)](data/televisa_ratings_mock.csv)

<br/>

> *"En televisión abierta, cada décima de rating representa millones de pesos en inversión publicitaria.  
> Este dashboard centraliza las decisiones editoriales, comerciales y de programación en un solo lugar."*

</div>

---

## 🎯 Contexto del Proyecto

El equipo de **Inteligencia Operativa y Visualización de Datos** de una cadena televisiva necesita monitorear en tiempo real el comportamiento de sus audiencias frente a la competencia. Las decisiones de programación — qué contenido estrenar, en qué franja, con qué frecuencia — dependen directamente de la capacidad de leer los datos de rating de forma rápida y confiable.

Este proyecto simula esa infraestructura analítica completa: desde la ingesta y transformación de datos hasta el dashboard ejecutivo de 4 páginas con métricas de industria estándar (IBOPE/Nielsen México).

---

## 📊 Dashboard — 4 Páginas

| Página | Nombre | Pregunta de negocio que responde |
|--------|--------|----------------------------------|
| **P1** | Executive Overview | ¿Cómo cerramos la semana? ¿Qué tendencia lleva el año? |
| **P2** | Program Performance | ¿Cómo evoluciona cada programa episodio a episodio? |
| **P3** | Audience Intelligence | ¿Quién nos ve, cuándo, y qué tan leales son? |
| **P4** | Competitive Landscape | ¿Dónde lidera Televisa y dónde pierde terreno vs Azteca? |

<br/>

<div align="center">
<img src="assets/dashboard_preview.png" alt="Dashboard Preview" width="90%"/>
<br/><sub><i>Power BI Dashboard — Paleta corporativa Televisa · Navy #0D1B3E · Naranja #FF6B00</i></sub>
</div>

---

## 🏗️ Arquitectura

```
📥 FUENTE DE DATOS
   Python ETL (generate_dataset.py)
   └── 10 programas · 52 semanas · 18 métricas
           │
           ▼
📦 ALMACENAMIENTO
   PostgreSQL — tabla televisa_ratings (520 filas)
   ├── vw_kpis_ejecutivos      → agregados por trimestre/canal/franja
   ├── vw_tendencia_semanal    → serie temporal + promedio móvil MA4
   └── vw_competencia         → Televisa vs Azteca vs Canal 5
           │
           ▼
📊 VISUALIZACIÓN
   Power BI Desktop
   ├── Modelo de datos importado
   ├── 20+ medidas DAX
   └── 4 páginas · 20+ visuals · 4 slicers cruzados
```

---

## 🔢 Métricas Implementadas

| Métrica | Definición | Estándar |
|---------|-----------|----------|
| **Rating** | % de hogares con TV sintonizados al canal | IBOPE/Nielsen MX |
| **Share** | % de TV encendida viendo el programa | IBOPE/Nielsen MX |
| **Audiencia (MM)** | Millones de televidentes estimados | Rating × cobertura |
| **Rating MA4** | Promedio móvil 4 semanas — suaviza ruido | Calculado en DAX |
| **Var. Semanal %** | Cambio porcentual vs semana anterior | Window function SQL / LAG DAX |
| **MktShare** | Televisa / (Televisa + Azteca + Canal5) × 100 | Calculado en DAX |
| **Índice Fidelidad** | Rating promedio / Rating pico × 100 | Calculado en DAX |
| **Demo 18–34 / 35–54 / 55+** | Distribución porcentual de audiencia por edad | Segmentación estándar |

---

## 🗄️ SQL Analytics — 16 Queries + 3 ETL Views

```sql
-- Ejemplo: Variación de rating vs semana anterior con LAG
SELECT
    programa,
    semana,
    rating,
    LAG(rating) OVER (PARTITION BY programa ORDER BY semana) AS rating_semana_anterior,
    ROUND(rating - LAG(rating) OVER (PARTITION BY programa ORDER BY semana), 2) AS variacion,
    ROUND(
        CASE WHEN LAG(rating) OVER (PARTITION BY programa ORDER BY semana) > 0
        THEN ((rating - LAG(rating) OVER (PARTITION BY programa ORDER BY semana))
              / LAG(rating) OVER (PARTITION BY programa ORDER BY semana)) * 100
        ELSE NULL END
    , 2) AS variacion_pct
FROM televisa_ratings
ORDER BY programa, semana;
```

| Sección SQL | Queries | Técnicas utilizadas |
|-------------|---------|---------------------|
| KPIs Ejecutivos | Q1–Q4 | `AVG`, `COUNT DISTINCT`, `GROUP BY` |
| Rendimiento de Programas | Q5–Q8 | `LAG`, `Window functions`, `STDDEV` |
| Inteligencia de Audiencia | Q9–Q12 | `TO_CHAR`, `DISTINCT ON`, `CASE WHEN` |
| Landscape Competitivo | Q13–Q16 | `DIVIDE`, subqueries, `CASE WHEN` |
| ETL Views | 3 vistas | `CREATE OR REPLACE VIEW`, window frames |

---

## ⚡ DAX Measures Destacadas

```dax
-- Promedio Móvil 4 semanas (suaviza variaciones semanales)
Rating MA4 =
AVERAGEX(
  FILTER(ALL(ratings),
    ratings[programa] = MAX(ratings[programa]) &&
    ratings[semana] >= MAX(ratings[semana]) - 3 &&
    ratings[semana] <= MAX(ratings[semana])
  ),
  ratings[rating]
)

-- Market Share vs competencia directa
MktShare Televisa =
DIVIDE(
  [Rating Promedio],
  [Rating Promedio] + [Azteca Rating] + [Canal5 Rating]
) * 100
```

---

## 📁 Estructura del Repositorio

```
televisa-ratings-dashboard/
│
├── 📁 data/
│   ├── televisa_ratings_mock.csv     # Dataset principal (520 filas · 18 cols)
│   └── data_dictionary.md           # Diccionario de métricas con estándares IBOPE
│
├── 📁 sql/
│   └── televisa_queries.sql         # 16 queries analíticos + 3 ETL views (310 líneas)
│
├── 📁 python/
│   └── generate_dataset.py          # ETL script — genera el dataset mock
│
├── 📁 powerbi/
│   └── televisa_dashboard.pbix      # Dashboard Power BI (4 páginas · 20+ visuals)
│
├── 📁 assets/
│   ├── header_banner.svg            # Banner del repositorio
│   └── dashboard_preview.png        # Screenshot del dashboard
│
└── 📄 README.md
```

---

## 🚀 Cómo Reproducir

### 1. Generar el dataset
```bash
pip install pandas numpy
python python/generate_dataset.py
# Output: data/televisa_ratings_mock.csv (520 filas)
```

### 2. Cargar en PostgreSQL
```sql
-- Crear la tabla (incluida en sql/televisa_queries.sql, Sección 1)
-- Luego importar:
\copy televisa_ratings FROM 'data/televisa_ratings_mock.csv' CSV HEADER;

-- Crear las 3 vistas ETL (Sección 6 del archivo SQL)
-- vw_kpis_ejecutivos · vw_tendencia_semanal · vw_competencia
```

### 3. Conectar Power BI
```
Get Data → PostgreSQL
Server: localhost
Database: [tu_db]
Importar: televisa_ratings + las 3 vistas vw_*
```

---

## 💡 Insights Clave del Análisis

- **La Rosa de Guadalupe** lidera con rating promedio **8.2** — el programa más consistente del portafolio
- **Prime Time (18:30–22:30)** concentra el **68% de la audiencia** acumulada anual
- Televisa mantiene ventaja de **+2.4 puntos** sobre Azteca Uno en Prime Time como promedio anual
- El segmento **55+** representa el **46%** del perfil demográfico — audiencia leal y predecible
- **Q4 (oct–dic)** registra el pico de rating estacional, consistente con el ciclo televisivo mexicano
- **Fútbol Total** presenta la mayor **volatilidad** semana a semana (σ = 0.8) — dependiente de fixtures relevantes

---

## 👤 Autor

<table>
<tr>
<td>

**Hugo Ernesto Aguilar Gallardo**  
Data Analyst Jr. en formación  
Ciudad de México, México

</td>
<td>

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Conectar-0077B5?style=flat&logo=linkedin)](https://linkedin.com/in/hugo-ernesto-aguilar-gallardo-2359263a5)
[![GitHub](https://img.shields.io/badge/GitHub-Portfolio-181717?style=flat&logo=github)](https://github.com/Ernestoaguiga)

</td>
</tr>
</table>

**Stack principal:** SQL/PostgreSQL · Python (pandas, psycopg2) · Power BI · DAX · Excel Advanced

---

<div align="center">

*Dataset simulado con estructura basada en métricas estándar de medición de audiencias televisivas (IBOPE/Nielsen México).  
Los valores son representativos del comportamiento del mercado televisivo mexicano de TV abierta.*

<br/>

⭐ **Si este proyecto te resultó útil, considera darle una estrella al repositorio**

</div>
