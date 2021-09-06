#from application import app_settings as config
from application.dash.app import app
from application.dash.components.layouts.layout import make_layout

app.layout = make_layout()

if __name__ == '__main__':
    # app.run_server(host='localhost', port=config.PORT, debug=True)
    app.run_server(host='localhost', debug=True)