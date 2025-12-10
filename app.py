import mysql.connector
from mysql.connector import Error
from datetime import datetime

DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'database': 'HospitalDB',
    'user': 'root',
    'password': 'LucasPlay123'
}

def get_conn():
    return mysql.connector.connect(**DB_CONFIG)

def realizar_consulta(sql, params=None):
    conn = None
    try:
        conn = get_conn()
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        if cur.with_rows:
            rows = cur.fetchall()
            for r in rows:
                print(r)
            return rows
        else:
            conn.commit()
            print("Executado com sucesso.")
    except Error as e:
        print("Erro:", e)
        if conn:
            conn.rollback()
    finally:
        if conn:
            cur.close()
            conn.close()

def listar_pacientes():
    realizar_consulta("SELECT * FROM Paciente ORDER BY id")

def listar_funcionarios():
    realizar_consulta("""
        SELECT f.*, m.crm, m.especialidade_id
        FROM Funcionario f
        LEFT JOIN Medico m ON f.cpf = m.cpf
    """)

def listar_consultas():
    realizar_consulta("""
        SELECT c.id, c.datahora, p.nome AS paciente, f.nome AS medico
        FROM Consulta c
        LEFT JOIN Paciente p ON c.paciente_id = p.id
        LEFT JOIN Medico m ON c.medico_cpf = m.cpf
        LEFT JOIN Funcionario f ON m.cpf = f.cpf
        ORDER BY c.datahora
    """)

def listar_exames():
    realizar_consulta("SELECT * FROM Exame ORDER BY datahora")

def buscar_paciente_nome():
    nome = input("Digite parte do nome: ")
    realizar_consulta("SELECT * FROM Paciente WHERE nome LIKE %s", (f"%{nome}%",))

def atualizar_email():
    pid = input("ID do paciente: ")
    novo = input("Novo email: ")
    realizar_consulta("UPDATE Paciente SET email = %s WHERE id = %s", (novo, pid))

def cancelar_agendamento():
    aid = input("ID do agendamento: ")
    realizar_consulta("DELETE FROM Agendamento WHERE id = %s", (aid,))

def internar():
    pid = input("ID do paciente: ")
    leito = input("ID do leito: ")
    motivo = input("Motivo: ")
    dataEntrada = datetime.now()
    realizar_consulta("""
        INSERT INTO Internacao (paciente_id, leito_id, dataEntrada, motivo)
        VALUES (%s,%s,%s,%s)
    """, (pid, leito, dataEntrada, motivo))
    realizar_consulta("UPDATE Leito SET ocupado = TRUE WHERE id = %s", (leito,))

def dar_alta():
    iid = input("ID da internação: ")
    dataAlta = datetime.now()
    rows = realizar_consulta("SELECT leito_id FROM Internacao WHERE id = %s", (iid,))
    if not rows:
        print("Internação não encontrada.")
        return
    leito = rows[0]["leito_id"]
    realizar_consulta("UPDATE Internacao SET dataAlta = %s WHERE id = %s", (dataAlta, iid))
    realizar_consulta("UPDATE Leito SET ocupado = FALSE WHERE id = %s", (leito,))

def listar_internacoes():
    realizar_consulta("""
        SELECT i.id, p.nome AS paciente, l.numero AS leito, s.nome AS setor,
               i.dataEntrada, i.dataAlta
        FROM Internacao i
        LEFT JOIN Paciente p ON i.paciente_id = p.id
        LEFT JOIN Leito l ON i.leito_id = l.id
        LEFT JOIN Setor s ON l.setor_id = s.id
        ORDER BY i.dataEntrada
    """)

def menu():
    while True:
        print("\n--- MENU HOSPITAL ---")
        print("1. Listar pacientes")
        print("2. Listar funcionários")
        print("3. Listar consultas")
        print("4. Listar exames")
        print("5. Buscar paciente por nome")
        print("6. Atualizar email do paciente")
        print("7. Cancelar agendamento")
        print("8. Internar paciente")
        print("9. Dar alta")
        print("10. Listar internações")
        print("11. Sair")

        op = input("Opção: ")
        match (op):
            case '1': 
                listar_pacientes()
                
            case '2':
                listar_funcionarios()
                
            case '3': 
                listar_consultas()
                
            case '4': 
                listar_exames()
                
            case '5': 
                buscar_paciente_nome()
                
            case '6': 
                atualizar_email()
                
            case '7': 
                cancelar_agendamento()
                
            case '8': 
                internar()
                
            case '9': 
                dar_alta()
                
            case '10': 
                listar_internacoes()
                
            case '11': 
                break
            case _: 
                print("Opção inválida.")

menu()
