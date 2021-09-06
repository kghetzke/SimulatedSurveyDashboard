import os

import pandas as pd
import dash_html_components as html
import dash_core_components as dcc
import dash_bootstrap_components as dbc
from application.dash.app import app
from application.dash.components.callbacks import callbacks

from application.dash.components.datasteps import get_data, get_meta
vars, vals = get_meta()

space = html.Div('  ', style = {'width': "25%", 'color':"#000000"})
head1 = html.Div('Select Metric', style = {'width': "95%", 'color':"#000000"})
head2 = html.Div('Select Company', style = {'width': "95%", 'color':"#000000"})
head3 = html.Div('Select Audience', style = {'width': "95%", 'color':"#000000"})
dropdown_titles = html.Div([space, head1, head2, head3], style={'display': 'flex'})

dropdown_container = html.Div(id = "dropdown_container", children=[])
add_series_button = html.Div([html.Button("Add Series", id="add_button")])


download_data_button = html.Div([html.Button("Download CSV", id="download_data_button"), dcc.Download(id="download_csv")])
download_pptx_button = html.Div([html.Button("Download Powerpoint", id="download_pptx_button"), dcc.Download(id="download_pptx")])
download_buttons = html.Div([download_data_button, download_pptx_button], style={'display': 'flex'})

initial_logic = pd.DataFrame([[list(vars.keys())[5],1,1]], columns = ['alpha','beta','gamma']).to_json()


def make_layout():
    layout = html.Div([
        dcc.Store(id="queried_series",data = initial_logic),
        dcc.Store(id="df_memory"),
        dcc.Location(id="url"),
        dropdown_titles,
        dropdown_container,
        add_series_button,
        dcc.Graph(id='main_graph',figure = {}),
        download_buttons
    ])
    return layout