
# hw1_on_st.py
import pandas as pd
import plotly.express as px
from sqlalchemy import text
from sqlalchemy import engine, URL
import json
import streamlit as st 


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


# app.py
import streamlit as st
import pandas as pd
import plotly.express as px


# Заголовок приложения
st.title("Chinook Sales Report")

# Функция загрузки данных
@st.cache_data
def load_data():
    engine = set_connection()
    query = "SELECT * FROM invoice"
    df = pd.read_sql(query, engine)
    df['invoice_date'] = pd.to_datetime(df['invoice_date'])
    return df

df = load_data()


with st.sidebar:
    st.header("Фильтры данных")
    selected_countries = st.multiselect(
        "Выберите страны",
        options=df['billing_country'].unique(),
        default=df['billing_country'].unique()
    )
    
    start_date, end_date = st.date_input(
        "Диапазон дат",
        value=[df['invoice_date'].min(), df['invoice_date'].max()]
    )
    
  
    min_amount = st.slider(
        "Минимальная сумма заказа",
        min_value=float(df['total'].min()),
        max_value=float(df['total'].max()),
        value=float(df['total'].min())
    )


filtered_df = df[
    (df['billing_country'].isin(selected_countries)) &
    (df['invoice_date'].dt.date.between(start_date, end_date)) &
    (df['total'] >= min_amount)
]

col1, col2 = st.columns(2)

with col1:
    time_series = filtered_df.groupby('invoice_date')['total'].sum().reset_index()
    fig1 = px.line(
        time_series, 
        x='invoice_date', 
        y='total',
        title="Динамика продаж",
        labels={'invoice_date': 'Дата', 'total': 'Сумма продаж ($)'}
    )
    st.plotly_chart(fig1, use_container_width=True)

with col2:
    country_data = filtered_df.groupby('billing_country')['total'].sum().reset_index()
    fig2 = px.bar(
        country_data,
        x='billing_country',
        y='total',
        title="Распределение по странам",
        labels={'billing_country': 'Страна', 'total': 'Сумма продаж ($)'}
    )
    st.plotly_chart(fig2, use_container_width=True)

st.dataframe(
    filtered_df,
    use_container_width=True,
    height=400,
    hide_index=True,
    column_order=["invoice_date", "billing_country", "total", "billing_city"],
    column_config={
        "invoice_date": st.column_config.DatetimeColumn('дата'
        ),
        "billing_country": "Страна",
        "billing_city": "Город",
        "total": st.column_config.NumberColumn(
            "Сумма ($)",
            format="$%.2f",
            help="Общая сумма заказа"
        )
    }
) 