import glob

path_list = glob.glob('application/dash/assets/PowerpointTemplates/*.pptx')
pptx_templates = [file[44:] for file in path_list]
print(pptx_templates)