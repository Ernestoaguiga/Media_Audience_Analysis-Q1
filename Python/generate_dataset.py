"""
generate_dataset.py
═══════════════════════════════════════════════════════════════
Televisa Ratings Intelligence Dashboard — ETL Script
Autor   : Hugo Ernesto Aguilar Gallardo
GitHub  : github.com/Ernestoaguiga
LinkedIn: linkedin.com/in/hugo-ernesto-aguilar-gallardo-2359263a5

Descripción:
  Genera el dataset mock de ratings televisivos con estructura
  basada en métricas estándar IBOPE/Nielsen México.
  Output: ../data/televisa_ratings_mock.csv (520 filas · 18 cols)

Uso:
  pip install pandas numpy
  python Python/generate_dataset.py
═══════════════════════════════════════════════════════════════
"""

import pandas as pd
import numpy as np
from datetime import date, timedelta
import random
import os

# ── Reproducibilidad ──────────────────────────────────────────
random.seed(42)
np.random.seed(42)

# ── Catálogo de programas ─────────────────────────────────────
PROGRAMAS = [
    {"nombre": "La Rosa de Guadalupe", "genero": "Drama",
     "canal": "Las Estrellas", "horario": "20:00", "franja": "Prime Time"},
    {"nombre": "Hoy", "genero": "Magazine",
     "canal": "Las Estrellas", "horario": "09:00", "franja": "Matutino"},
    {"nombre": "Netas Divinas", "genero": "Talk Show",
     "canal": "Unicable", "horario": "21:00", "franja": "Prime Time"},
    {"nombre": "Exatlon Mexico", "genero": "Reality",
     "canal": "TUDN", "horario": "19:30", "franja": "Prime Time"},
    {"nombre": "Vencer el Pasado", "genero": "Telenovela",
     "canal": "Las Estrellas", "horario": "21:30", "franja": "Prime Time"},
    {"nombre": "Al Extremo", "genero": "Entretenimiento",
     "canal": "Las Estrellas", "horario": "23:00", "franja": "Late Night"},
    {"nombre": "Noticieros Televisa", "genero": "Noticias",
     "canal": "Las Estrellas", "horario": "22:30", "franja": "Late Night"},
    {"nombre": "Me Caigo de Risa", "genero": "Comedia",
     "canal": "Las Estrellas", "horario": "20:30", "franja": "Prime Time"},
    {"nombre": "Futbol Total", "genero": "Deportes",
     "canal": "TUDN", "horario": "21:00", "franja": "Prime Time"},
    {"nombre": "Disenando Tu Amor", "genero": "Telenovela",
     "canal": "Las Estrellas", "horario": "18:00", "franja": "Vespertino"},
]

# ── Rating base por programa ──────────────────────────────────
BASE_RATINGS = {
    "La Rosa de Guadalupe": 8.2,
    "Hoy": 5.1,
    "Netas Divinas": 3.4,
    "Exatlon Mexico": 6.8,
    "Vencer el Pasado": 7.3,
    "Al Extremo": 2.1,
    "Noticieros Televisa": 4.9,
    "Me Caigo de Risa": 6.1,
    "Futbol Total": 5.7,
    "Disenando Tu Amor": 4.3,
}

# ── Rating base competidores por franja ───────────────────────
COMPETIDORES = {
    "Prime Time": {"Azteca Uno": 5.8, "Canal 5": 2.1},
    "Matutino": {"Azteca Uno": 3.2, "Canal 5": 1.4},
    "Vespertino": {"Azteca Uno": 2.8, "Canal 5": 1.1},
    "Late Night": {"Azteca Uno": 1.5, "Canal 5": 0.8},
}


def generate_ratings(
    start_date: date = date(2024, 1, 1),
    weeks: int = 52
) -> pd.DataFrame:
    """Genera el dataset de ratings para el periodo especificado."""
    records = []

    for week in range(weeks):
        semana_inicio = start_date + timedelta(weeks=week)
        semana_num = week + 1
        trimestre = (week // 13) + 1

        for prog in PROGRAMAS:
            nombre = prog["nombre"]
            base = BASE_RATINGS[nombre]
            franja = prog["franja"]
            comp = COMPETIDORES[franja]

            tendencia = 1 + (week * 0.001) * random.choice([-1, 1])
            variacion = np.random.normal(0, 0.3)
            rating = round(max(0.5, base * tendencia + variacion), 2)

            total_mkt = rating + sum(comp.values()) + np.random.normal(0, 0.5)
            share = round((rating / max(total_mkt, 1)) * 100, 2)

            audiencia = round(rating * 1.35 + np.random.normal(0, 0.4), 2)

            d1834 = round(random.uniform(20, 40), 1)
            d3554 = round(random.uniform(25, 40), 1)
            d55plus = round(100 - d1834 - d3554, 1)

            r_azteca = round(
                max(0.1, comp["Azteca Uno"] + np.random.normal(0, 0.4)), 2
            )
            r_canal5 = round(
                max(0.1, comp["Canal 5"] + np.random.normal(0, 0.2)), 2
            )

            temporada = (week // 13) + 1
            episodio = (week % 13) + 1

            records.append({
                "semana": semana_num,
                "fecha_inicio_semana": semana_inicio.strftime("%Y-%m-%d"),
                "trimestre": f"Q{trimestre}",
                "programa": nombre,
                "genero": prog["genero"],
                "canal": prog["canal"],
                "horario": prog["horario"],
                "franja_horaria": franja,
                "temporada": temporada,
                "episodio": episodio,
                "rating": rating,
                "share_pct": share,
                "audiencia_millones": audiencia,
                "rating_azteca": r_azteca,
                "rating_canal5": r_canal5,
                "demo_18_34_pct": d1834,
                "demo_35_54_pct": d3554,
                "demo_55plus_pct": d55plus,
            })

    return pd.DataFrame(records)


if __name__ == "__main__":
    print("Generando dataset de ratings televisivos...")

    # ── Ruta relativa al script — funciona en cualquier entorno ──
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    out_dir = os.path.join(repo_root, "data")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "televisa_ratings_mock.csv")

    df = generate_ratings()
    df.to_csv(out_path, index=False)

    print("Dataset generado exitosamente")
    print(f"  Archivo  : {out_path}")
    print(f"  Filas    : {len(df)}")
    print(f"  Columnas : {len(df.columns)}")
    print(f"  Programas: {df['programa'].nunique()}")
    print(f"  Semanas  : {df['semana'].nunique()}")
    print("\nEstadisticas de rating:")
    print(
        df.groupby("programa")["rating"]
        .agg(["mean", "min", "max"])
        .round(2)
        .to_string()
    )
