import os
import glob
import pandas as pd
import dash_html_components as html
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import application.app_settings as config
from application.dash.app import app
from application.dash.components.callbacks import callbacks

### Load in some meta-data about the data-set to define the layout ###
from application.dash.components.datasteps import get_data, get_meta
vars, vals = get_meta()

### Header ###
header = html.Div([
    html.H3("Simple Dashboard for a Tracker Survey", id = "primary_heading", style = {'text-align': 'center'}),
    html.Div(["Click ",html.A("here",href='https://github.com/kghetzke/SimulatedSurveyDashboard')," to view repository on GitHub"], style = {'text-align': 'center'}),
    html.Br()
])

### Dropdown Menus ###

# space = html.Div('  ', style = {'width': "25%", 'color':config.FONT_COLOR_ALPHA})
# head1 = html.Div('Select Metric', style = {'width': "95%", 'color':config.FONT_COLOR_ALPHA})
# head2 = html.Div('Select Company', style = {'width': "95%", 'color':config.FONT_COLOR_ALPHA})
# head3 = html.Div('Select Audience', style = {'width': "95%", 'color':config.FONT_COLOR_ALPHA})
# dropdown_titles = html.Div([space, head1, head2, head3], style={'display': 'flex'})

dropdown_titles = html.Div([
    html.Div(' ',style = {'width': "25%"}),
    html.Div('Select Metric', style = {'width': "95%"}),
    html.Div('Select Company', style = {'width': "95%"}),
    html.Div('Select Audience', style = {'width': "95%"})    
], style = {'display': 'flex'})

dropdown_container = html.Div(id = "dropdown_container", children=[])
add_series_button = html.Div([html.Button("Add Series", id="add_button")])

### Download Data Buttons ###

download_data_button = html.Div([html.Button("Download CSV", id="download_data_button"), dcc.Download(id="download_csv")],style={'width': "15%"})

# Fill the download-powerpoint dropdown menu with options from all the .pptx files in the templates folder
pptx_templates = [file[44:] for file in glob.glob('application/dash/assets/PowerpointTemplates/*.pptx')]
download_pptx_button = html.Div([html.Div('Download PPTX from Template', style = {'width': "95%"}), 
    dcc.Dropdown(id="download_pptx_button", 
    options = [{'label': template, 'value': template} for idx, template in enumerate(pptx_templates)], 
    value = None, style = {'width': '35%'}),
    dcc.Download(id="download_pptx")])

download_buttons = html.Div([download_data_button, download_pptx_button], style={'display': 'flex'})

initial_logic = pd.DataFrame([[list(vars.keys())[5],1,1]], columns = ['alpha','beta','gamma']).to_json()


def make_layout():
    layout = html.Div([
        dcc.Store(id="queried_series", data = initial_logic),
        dcc.Store(id="df_memory"),
        dcc.Location(id="url"),
        header,
        dropdown_titles,
        dropdown_container,
        add_series_button,
        dcc.Graph(id='main_graph',figure = {}),
        download_data_button,
        download_pptx_button,
    ], style = {'backgroundColor': config.MAIN_BACKGROUND_COLOR})
    return layout