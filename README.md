# SmartMatch

> Intelligent Decision Support System for matching students with internship opportunities.

> Fictional dataset created for academic purposes

SmartMatch is an academic project built with **SQL Server**, **Python**, and **Power BI** that automates the compatibility scoring between student profiles and job vacancies, using a weighted algorithm based on Hard Skills, Soft Skills, and logistics preferences.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Database | SQL Server 2022 (Docker) |
| Recommendation Engine | Python 3 · pyodbc · pandas |
| Dashboards | Power BI Desktop |
| Container | Docker |

---

## Project Structure

```
SmartMatch/
├── assets/            # Dashboard screenshots
├── dashboard/         # Power BI dashboard (.pbix)
├── database/          # SQL scripts — schema + seed data
└── engine/            # Python recommendation engine
```

---

## How It Works

The engine calculates a compatibility score for every student × vacancy pair:

```
Score = (HardSkills × weight_hs) + (SoftSkills × weight_ss) + (Logistics × weight_log)
```

Default weights: **Hard Skills 65%** · **Soft Skills 25%** · **Logistics 10%**

Weights are configurable per vacancy. Mandatory skills act as eliminatory filters — if a student lacks a required skill at the minimum level, the vacancy is excluded from their recommendations.

---

## ⚠️ Environment-Specific Configuration

This project was developed and tested on a specific local setup. The components below require reconfiguration to run on a different machine.

### 1. Recommendation Engine (`motor_recomendacao.py`)

The script connects to SQL Server using credentials defined at the top of the file:

```python
SERVER      = "localhost,1433"
DATABASE    = "SmartMatchDB"
DB_USER     = "sa"
DB_PASSWORD = "Localhost123!"
```

**Why it only runs here:**
- SQL Server runs inside a Docker container on this machine with port `1433` mapped to `localhost`
- The password was set specifically when creating the container (`SA_PASSWORD`)
- Requires **ODBC Driver 18 for SQL Server** installed at the OS level

**To run on another machine:**
1. Install Docker and start the SQL Server container (see below)
2. Update `SERVER`, `DB_USER`, and `DB_PASSWORD` in the script
3. Install ODBC Driver 18 — `pip install pyodbc` alone is not enough
4. Install Python dependencies:
```bash
pip install pyodbc pandas
```

---

### 2. Database — Docker

SQL Server runs in a Docker container configured as follows:

```bash
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Localhost123!" \
  -p 1433:1433 --name smartmatch-sql \
  -d mcr.microsoft.com/mssql/server:2022-latest
```

After starting the container, run the SQL script in `database/` to recreate the schema and seed data from scratch.

---

### 3. Power BI Dashboard

The dashboard connects to the database using:

- **Server:** `localhost,1433`
- **Database:** `SmartMatchDB`
- **Authentication:** Database (user `sa`)
- **Encryption:** Disabled (required with Docker's self-signed certificate)

Credentials are stored locally in Power BI Desktop. Opening the `.pbix` on another machine will prompt for credentials — and `localhost,1433` will only resolve if the Docker container is also running on that machine.

---

## What Needs Reconfiguration on Another Machine

| File / Component | What to change |
|---|---|
| `motor_recomendacao.py` | `SERVER`, `DB_USER`, `DB_PASSWORD` |
| Docker | Recreate the container with `docker run` |
| ODBC Driver 18 | Install at the OS level |
| Power BI (`.pbix`) | Re-enter database credentials |

---

## What Is Portable (Works on Any Machine)

- **SQL script** (`database/`) — recreates the full database from scratch on any SQL Server instance
- **Recommendation logic** — the scoring algorithm is environment-independent
- **Power BI structure** — visuals, relationships, and measures are reusable; only the data source connection needs to be reconfigured

---

## Note

> This project was developed in Portuguese as part of an academic assignment (Gestão de Sistemas de Informação, 2025/2026). All code, documentation, and database scripts reflect that context.
