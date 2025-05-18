import os
import jinja2
import dotenv
import subprocess

dotenv.load_dotenv()

templates = [
    "repo.template.yaml.j2",
    "project.template.yaml.j2",
    "application.template.yaml.j2"
]

environment = jinja2.Environment(loader=jinja2.FileSystemLoader("templates"))

variables = [
    {
        "env_var": "REPO_URL",
        "template_var": "repo_url",
        "description": "the URL of the repository",
    },
    {
        "env_var": "REPO_NAME",
        "template_var": "repo_name",
        "description": "the name of the repository",
    },
    {
        "env_var": "REPO_USERNAME",
        "template_var": "repo_username",
        "description": "the username for the repository",
    },
    {
        "env_var": "REPO_TOKEN",
        "template_var": "repo_token",
        "description": "the access token for the repository",
    },
    {
        "env_var": "PROJECT_NAME",
        "template_var": "project_name",
        "description": "the name of the ArgoCD project",
    },
    {
        "env_var": "APP_NAME",
        "template_var": "app_name",
        "description": "the name of the ArgoCD application",
    },
    {
        "env_var": "DEST_NAMESPACE",
        "template_var": "dest_namespace",
        "description": "the destination Kubernetes namespace",
    },
    {
        "env_var": "DEST_SERVER",
        "template_var": "dest_server",
        "description": "the destination Kubernetes server",
    },
    {
        "env_var": "PATH_IN_REPO",
        "template_var": "path_in_repo",
        "description": "the path in the repository for the application",
    },
    {
        "env_var": "IMAGE_REGISTRY_SERVER",
        "template_var": "image_registry_server",
        "description": "the server hosting the image",
    },
    {
        "env_var": "ENVIRONMENT",
        "template_var": "environment",
        "description": "the deployment environment",
    },
]

template_vars = {}

for var in variables:
    var_value = os.getenv(var["env_var"])

    if var_value is None:
        var_value = input(f"Please input {var['description']}: ")
    else:
        print(f"Using {var['env_var']} from environment.")

    template_vars[var["template_var"]] = var_value

print("\nRendering templates with the following variables:")
for k, v in template_vars.items():
    print(f"  {k}: {v}")

input("\nPress Enter to proceed with rendering the templates...")

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
