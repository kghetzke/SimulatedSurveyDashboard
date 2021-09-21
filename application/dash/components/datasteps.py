from pathlib import Path
import pandas as pd

#Use "Path" to make the app work with different operating systems
source_folder = Path("application/dash/assets/StataFiles")
datafile = source_folder / "ProcessedSurveyData.dta"

def get_data(file = datafile, text_columns = ['month','company','audience']):
    df = pd.read_stata(file, convert_categoricals=False)
    text_df = pd.read_stata(file, columns = text_columns)
    text_df = text_df.rename(columns = dict((col, col.title()) for col in text_columns))
    df = text_df.join(df)
    return df

def get_meta(file = datafile):
    meta_data = pd.read_stata(file, iterator=True)
    dm_vars = meta_data.variable_labels()
    dm_vals = meta_data.value_labels()
    return dm_vars, dm_vals

if __name__=='__main__':
    df = get_data()
    print(df.head())
    vars, vals = get_meta()
    
    