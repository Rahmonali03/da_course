import pandas as pd
import plotly.express as px
from sqlalchemy import text
from sqlalchemy import engine, URL
import json
import streamlit as st 
from datetime import date


with open('credentials.json') as f:
    credentials = json.load(f)

connection_url = URL.create(
        drivername="postgresql+psycopg2",
        username = credentials['username'],
        password = credentials['password'],
        host = credentials['host'],
        port = credentials['port']
    )

def set_connection(): 
    eng = engine.create_engine(connection_url)
    pg = eng.connect()

    return pg
# Загрузка данных из таблицы invoice
query =text("SELECT * FROM invoice;")
with set_connection() as conn:
    df = pd.read_sql(query, conn)

def load_invoices(start_date, end_date):
    engine = set_connection()
    query = f"""
        SELECT i.invoice_date, i.total 
        FROM invoice i
        WHERE i.invoice_date BETWEEN '{start_date}' AND '{end_date}'
    """
    return pd.read_sql(query, engine)

@st.cache_data
def load_genres_data(start_date, end_date):
    engine = set_connection()
    query = f"""
        SELECT g.name AS genre, SUM(i.total) AS total
        FROM invoice i
        JOIN invoice_line il ON i.invoice_id = il.invoice_id
        JOIN track t ON il.track_id = t.track_id
        JOIN genre g ON t.genre_id = g.genre_id
        WHERE i.invoice_date BETWEEN '{start_date}' AND '{end_date}'
        GROUP BY g.name
    """
    return pd.read_sql(query, engine)

# Интерфейс
st.title('Анализ музыкальных продаж')
st.sidebar.header('Фильтры периода')

# Фильтры дат
today = date.today()
start_date = st.sidebar.date_input('Начальная дата', value=date(2009, 1, 1))
end_date = st.sidebar.date_input('Конечная дата', value=today)

# Загрузка данных
invoices_df = load_invoices(start_date, end_date)
genres_df = load_genres_data(start_date, end_date)

# Визуализация
st.header('Динамика продаж')
if not invoices_df.empty:
    fig1 = px.line(
        invoices_df.groupby('invoice_date')['total'].sum().reset_index(),
        x='invoice_date',
        y='total',
        labels={'invoice_date': 'Дата', 'total': 'Сумма продаж ($)'}
    )
    st.plotly_chart(fig1, use_container_width=True)
else:
    st.warning('Нет данных за выбранный период')

st.header('Распределение по жанрам')
if not genres_df.empty:
    fig2 = px.bar(
        genres_df,
        x='genre',
        y='total',
        labels={'genre': 'Музыкальный жанр', 'total': 'Сумма продаж ($)'}
    )
    st.plotly_chart(fig2, use_container_width=True)
else:
    st.warning('Нет данных за выбранный период')    