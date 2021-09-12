import dash
import dash_bootstrap_components as dbc

#from application import app_settings as config

stylesheets = [dbc.themes.BOOTSTRAP]

app = dash.Dash(
        __name__,
        external_stylesheets=stylesheets,
        suppress_callback_exceptions=True
        #url_base_pathname = config.URL_BASE_PATHNAME
)
server = app.server