import os
import jinja2
import dotenv
import subprocess
import json

dotenv.load_dotenv()

templates = [
    "repo.template.yaml.j2",
    "project.template.yaml.j2",
    "application.template.yaml.j2"
]

environment = jinja2.Environment(loader=jinja2.FileSystemLoader("templates"))

variables = [
    {
        "template_var": "repo_url",
        "description": "the URL of the repository",
    },
    {
        "template_var": "repo_name",
        "description": "the name of the repository",
    },
    {
        "template_var": "repo_username",
        "description": "the username for the repository",
    },
    {
        "template_var": "repo_token",
        "description": "the access token for the repository",
    },
    {
        "template_var": "project_name",
        "description": "the name of the ArgoCD project",
    },
    {
        "template_var": "app_name",
        "description": "the name of the ArgoCD application",
    },
    {
        "template_var": "destination_namespace",
        "description": "the destination Kubernetes namespace",
    },
    {
        "template_var": "environments",
        "description": "the deployment environments",
    },
]

template_vars = {}

print("This script will generate ArgoCD YAML files from Jinja2 templates using variables from input.json or user input.")
print("Make sure your templates are in the 'templates' directory and your variables are in 'input.json'.")
print("Rendered files will be saved in the 'output' directory.")

with open("input.json") as f:
    input_data = json.load(f)

for var in variables:
    key = var["template_var"]
    if key in input_data:
        template_vars[key] = input_data[key]
    else:
        template_vars[key] = input(f"Enter {var['description']} ({key}): ")

os.makedirs("output", exist_ok=True)
for template in templates:
    print(f"\nRendering template: {template}")
    template_obj = environment.get_template(template)
    rendered = template_obj.render(template_vars)

    output_filename = template.replace(".template.yaml.j2", ".yaml")
    output_path = f"output/{output_filename}"

    with open(output_path, "w") as f:
        f.write(rendered)

    print(f"Apply with: kubectl apply -f {output_path}")
