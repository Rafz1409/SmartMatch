import pyodbc
import pandas as pd
from datetime import datetime

# ----- config -----
SERVER      = "localhost,1434"
DATABASE    = "SmartMatchDB"
DB_USER     = "sa"
DB_PASSWORD = "Localhost123!"
NIVEL_MAP   = {"Basico": 1, "Intermedio": 2, "Avancado": 3}

# ----- ligação -----
def get_connection():
    return pyodbc.connect(
        f"DRIVER={{ODBC Driver 18 for SQL Server}};"
        f"SERVER={SERVER};DATABASE={DATABASE};"
        f"UID={DB_USER};PWD={DB_PASSWORD};TrustServerCertificate=yes;"
    )

# ----- leitura da db -----
def carregar_dados(conn):
    return (
        pd.read_sql("SELECT ID_Estudante, Nome, Pref_Localizacao, Pref_ModeloTrabalho FROM Estudantes", conn),
        pd.read_sql("SELECT ID_Vaga, Empresa, Titulo_Vaga, Localizacao, ModeloTrabalho, Peso_HardSkills, Peso_SoftSkills, Peso_Logistica FROM Vagas", conn),
        pd.read_sql("SELECT ID_Competencia, Nome_Competencia, Tipo FROM Competencias", conn),
        pd.read_sql("SELECT ID_Estudante, ID_Competencia, Nivel FROM Estudante_Competencias", conn),
        pd.read_sql("SELECT ID_Vaga, ID_Competencia, Obrigatorio, Nivel_Minimo FROM Vaga_Competencias", conn),
    )

# ----- score logística -----
def calcular_logistica(el, em, vl, vm):
    loc    = 100 if el == vl else 30
    modelo = 100 if em == vm else (70 if vm == "Hibrido" or em == "Hibrido" else 20)
    return round((loc + modelo) / 2, 2)

# ----- score skills -----
def calcular_score_skills(id_est, id_vaga, tipo, est_comp, vaga_comp, comps):
    ids = set(comps[comps["Tipo"] == tipo]["ID_Competencia"])
    req = vaga_comp[(vaga_comp["ID_Vaga"] == id_vaga) & (vaga_comp["ID_Competencia"].isin(ids))]
    if req.empty:
        return 100.0, False
    est = {r["ID_Competencia"]: NIVEL_MAP.get(r["Nivel"], 0)
           for _, r in est_comp[est_comp["ID_Estudante"] == id_est].iterrows()}
    scores = []
    for _, r in req.iterrows():
        nmin = NIVEL_MAP.get(r["Nivel_Minimo"], 1)
        nest = est.get(r["ID_Competencia"], 0)
        if r["Obrigatorio"] == 1 and nest < nmin:
            return 0.0, True
        scores.append(100 if nest >= nmin else (50 if nest > 0 else 0))
    return round(sum(scores) / len(scores), 2), False

# ----- motor de recomendação -----
def calcular_recomendacoes(estudantes, vagas, comps, est_comp, vaga_comp):
    resultados = []
    for _, est in estudantes.iterrows():
        for _, vaga in vagas.iterrows():
            hs, elim = calcular_score_skills(est["ID_Estudante"], vaga["ID_Vaga"], "Hard Skill", est_comp, vaga_comp, comps)
            if elim: continue
            ss, elim = calcular_score_skills(est["ID_Estudante"], vaga["ID_Vaga"], "Soft Skill", est_comp, vaga_comp, comps)
            if elim: continue
            log = calcular_logistica(est["Pref_Localizacao"], est["Pref_ModeloTrabalho"], vaga["Localizacao"], vaga["ModeloTrabalho"])
            resultados.append({
                "ID_Estudante": est["ID_Estudante"], "ID_Vaga": vaga["ID_Vaga"],
                "Score_Total":  round(hs * float(vaga["Peso_HardSkills"]) + ss * float(vaga["Peso_SoftSkills"]) + log * float(vaga["Peso_Logistica"]), 2),
                "Score_HardSkills": hs, "Score_SoftSkills": ss, "Score_Logistica": log,
                "Data_Calculo": datetime.now()
            })
        print(f"  {est['Nome']:<25} — {len([r for r in resultados if r['ID_Estudante'] == est['ID_Estudante']])} vagas")
    return resultados

# ----- guardar na db -----
def guardar(conn, resultados):
    cur = conn.cursor()
    cur.execute("DELETE FROM Recomendacoes")
    cur.executemany(
        "INSERT INTO Recomendacoes (ID_Estudante,ID_Vaga,Score_Total,Score_HardSkills,Score_SoftSkills,Score_Logistica,Data_Calculo) VALUES (?,?,?,?,?,?,?)",
        [(r["ID_Estudante"], r["ID_Vaga"], r["Score_Total"], r["Score_HardSkills"], r["Score_SoftSkills"], r["Score_Logistica"], r["Data_Calculo"]) for r in resultados]
    )
    conn.commit()
    print(f"  {len(resultados)} recomendações inseridas.")

# ----- relatório terminal -----
def mostrar_relatorio(resultados, estudantes, vagas):
    df = pd.DataFrame(resultados).merge(estudantes[["ID_Estudante","Nome"]], on="ID_Estudante").merge(vagas[["ID_Vaga","Empresa","Titulo_Vaga"]], on="ID_Vaga")
    for _, est in estudantes.iterrows():
        top5 = df[df["ID_Estudante"] == est["ID_Estudante"]].sort_values("Score_Total", ascending=False).head(5)
        if top5.empty: continue
        print(f"\n  {est['Nome']}\n  {'-'*50}")
        for i, (_, r) in enumerate(top5.iterrows(), 1):
            print(f"  {i}. {r['Empresa']:<25} {r['Titulo_Vaga']:<35} Score: {r['Score_Total']:>6.2f}%  [HS:{r['Score_HardSkills']:.0f} SS:{r['Score_SoftSkills']:.0f} LOG:{r['Score_Logistica']:.0f}]")

# ----- main -----
def main():
    print(f"\n{'='*55}\n  SmartMatch — {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n{'='*55}")
    try:
        conn = get_connection()
        print("  Ligação estabelecida.")
    except Exception as e:
        print(f"  ERRO: {e}"); return

    estudantes, vagas, comps, est_comp, vaga_comp = carregar_dados(conn)
    print(f"  {len(estudantes)} estudantes | {len(vagas)} vagas | {len(comps)} competências\n")

    resultados = calcular_recomendacoes(estudantes, vagas, comps, est_comp, vaga_comp)
    guardar(conn, resultados)
    mostrar_relatorio(resultados, estudantes, vagas)
    conn.close()
    print(f"\n{'='*55}\n  Concluído! Tabela Recomendacoes pronta para Power BI.\n{'='*55}\n")

if __name__ == "__main__":
    main()