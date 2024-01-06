import pyodbc
import pandas as pd
from sqlalchemy import create_engine

# Configurações do SQLServer
server = 'SERVIDOR SQLSERVER'
database = 'DATABASE SQLSERVER'


# Criação da string de conexão para autenticação do Windows // Adicionei o Driver ODBC17 para ser compatível com SQLAlchemy
conn_str = f'DRIVER=ODBC Driver 17 for SQL Server;SERVER={server};DATABASE={database};Trusted_Connection=yes;'

# Criação da conexão com o banco de dados usando a lib pyodbc
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Criação da engine usando SQLAlchemy para migração dos dados
engine = create_engine(f'mssql+pyodbc:///?odbc_connect={conn_str}', fast_executemany=True)


# Query para criação da tabela filtrando as colunas interessantes para o estudo
cursor.execute('''
    CREATE TABLE PNAD_COVID (
        Ano INT,
        UF INT,
        V1013 INT,
        A002 INT,
        A003 INT,
        A004 INT,
        A005 INT,
        B0011 INT,
        B0012 INT,
        B0013 INT,
        B0014 INT,
        B0015 INT,
        B0016 INT,
        B0017 INT,
        B0018 INT,
        B0019 INT,
        B00110 INT,
        B00111 INT,
        B00112 INT,
        B002 INT,
        B0031 INT,
        B0032 INT,
        B0033 INT,
        B0034 INT,
        B0035 INT,
        B0036 INT,
        B0037 INT,
        B0041 INT,
        B0042 INT,
        B0043 INT,
        B0044 INT,
        B0045 INT,
        B0046 INT,
        B005 INT,
        B006 INT,
        B007 INT
    );
''')

conn.commit()

# Colunas para serem filtradas no dataframe do pandas
columns_to_insert = [
    'Ano', 'UF', 'V1013', 'A002', 'A003', 'A004', 'A005',
    'B0011', 'B0012', 'B0013', 'B0014', 'B0015', 'B0016',
    'B0017', 'B0018', 'B0019', 'B00110', 'B00111', 'B00112',
    'B002', 'B0031', 'B0032', 'B0033', 'B0034', 'B0035',
    'B0036', 'B0037', 'B0041', 'B0042', 'B0043', 'B0044',
    'B0045', 'B0046', 'B005', 'B006', 'B007'
]

# função que migra os dados
def insert_data(df):

    # transforma os dados em INT e espaços vazios em NULL
    df[columns_to_insert] = df[columns_to_insert].astype('Int32')
    
    # função em pandas para adicionar o csv em sql
    df[columns_to_insert].to_sql('PNAD_COVID', schema='dbo', con=engine.connect(), index=False, if_exists='append')

# lista de arquivos
base = ['PNAD_COVID_052020.csv', 'PNAD_COVID_062020.csv', 'PNAD_COVID_072020.csv', 'PNAD_COVID_082020.csv', 'PNAD_COVID_092020.csv', 'PNAD_COVID_102020.csv', 'PNAD_COVID_112020.csv']

# iteração dos arquivos, leitura do *.csv em pandas e a migração para o banco SQL
for file in base:
    df = pd.read_csv(file)
    insert_data(df)
    print(f'Inserido no banco arquivo {file}')

