# 📖 Diccionario de Datos — Televisa Ratings Intelligence

## Tabla Principal: `televisa_ratings`

| Campo | Tipo | Descripción | Ejemplo |
|-------|------|-------------|---------|
| `semana` | INT | Número de semana del año (1–52) | 27 |
| `fecha_inicio_semana` | DATE | Lunes de inicio de la semana analizada | 2024-07-01 |
| `trimestre` | VARCHAR | Trimestre fiscal (Q1–Q4) | Q3 |
| `programa` | VARCHAR | Nombre del programa televisivo | La Rosa de Guadalupe |
| `genero` | VARCHAR | Género del contenido | Drama, Telenovela, Reality... |
| `canal` | VARCHAR | Señal de transmisión | Las Estrellas, TUDN, Unicable |
| `horario` | VARCHAR | Hora de inicio de transmisión | 20:00 |
| `franja_horaria` | VARCHAR | Clasificación de franja | Prime Time, Matutino, Vespertino, Late Night |
| `temporada` | INT | Número de temporada en curso | 2 |
| `episodio` | INT | Número de episodio dentro de la temporada | 8 |
| `rating` | NUMERIC(5,2) | % de hogares con TV sintonizados | 8.35 |
| `share_pct` | NUMERIC(5,2) | % de TV encendida viendo el programa | 46.18 |
| `audiencia_millones` | NUMERIC(5,2) | Estimado de televidentes en millones | 11.53 |
| `rating_azteca` | NUMERIC(5,2) | Rating de Azteca Uno en la misma franja | 5.80 |
| `rating_canal5` | NUMERIC(5,2) | Rating de Canal 5 en la misma franja | 2.10 |
| `demo_18_34_pct` | NUMERIC(5,2) | % de audiencia entre 18 y 34 años | 20.5 |
| `demo_35_54_pct` | NUMERIC(5,2) | % de audiencia entre 35 y 54 años | 29.1 |
| `demo_55plus_pct` | NUMERIC(5,2) | % de audiencia de 55 años o más | 50.4 |

---

## Franjas Horarias

| Franja | Horario | Descripción |
|--------|---------|-------------|
| **Matutino** | 06:00–12:00 | Magazines, noticias de la mañana |
| **Vespertino** | 12:00–18:30 | Telenovelas, programas de tarde |
| **Prime Time** | 18:30–22:30 | Máxima audiencia del día |
| **Late Night** | 22:30–01:00 | Noticias noche, entretenimiento adulto |

---

## Estándares de Medición

- **Fuente de referencia**: IBOPE Media / Nielsen México (metodología estándar para TV abierta en México)
- **Universo de medición**: Hogares con TV en zonas metropolitanas de cobertura nacional
- **Rating 1.0** = 1% de hogares con TV sintonizados al canal
- **Share**: Rating del programa / Suma de ratings de todos los canales con TV encendida × 100

---

## Clasificación de Performance

| Categoría | Rango de Rating |
|-----------|----------------|
| ⭐ Estrella | ≥ 7.0 |
| ✅ Sólido | 5.0 – 6.9 |
| 🔄 Regular | 3.0 – 4.9 |
| ⚠️ Bajo Rendimiento | < 3.0 |
