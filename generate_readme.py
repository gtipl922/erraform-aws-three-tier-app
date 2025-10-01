import os
import requests
import json
import subprocess

# --- Configuration ---
API_KEY = os.getenv("GEMINI_API_KEY")
API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent"
README_FILE = "README.md"

# --- Functions ---

def get_project_description():
    """
    Analyzes the repository to gather information for the AI prompt.
    This version reads file names and simulates reading a package.json for dependencies.
    """
    # Get a list of all files in the repository
    file_list = []
    for root, dirs, files in os.walk("."):
        # Exclude common directories like .git, node_modules, etc.
        dirs[:] = [d for d in dirs if d not in ['.git', 'node_modules', '__pycache__', '.github']]
        for file in files:
            file_list.append(os.path.join(root, file))

    # Simulate reading a package.json or requirements.txt
    project_metadata = {
        "files": file_list,
        "dependencies": {},
        "scripts": {}
    }

    try:
        with open("package.json", "r") as f:
            package_json = json.load(f)
            if "dependencies" in package_json:
                project_metadata["dependencies"] = package_json["dependencies"]
            if "scripts" in package_json:
                project_metadata["scripts"] = package_json["scripts"]
    except FileNotFoundError:
        # Fallback if no package.json is found
        pass
    except json.JSONDecodeError:
        print("Warning: Could not parse package.json. Skipping.")
        pass

    # Build a concise text description from the gathered data
    description = "The project has the following file structure:\n"
    for file in project_metadata["files"]:
        description += f"- {file}\n"
    
    if project_metadata["dependencies"]:
        description += "\nIt has the following dependencies:\n"
        for dep, version in project_metadata["dependencies"].items():
            description += f"- {dep}: {version}\n"
    
    if project_metadata["scripts"]:
        description += "\nIt has the following scripts:\n"
        for script, command in project_metadata["scripts"].items():
            description += f"- {script}: {command}\n"

    return description

def generate_readme_content(project_description):
    """
    Calls the Gemini API to generate the README content.
    """
    if not API_KEY:
        raise ValueError("GEMINI_API_KEY environment variable is not set.")
    
    headers = {
        "Content-Type": "application/json"
    }

    system_prompt = """
    You are a professional README file generator. Your task is to create a comprehensive, well-structured, and visually appealing README.md in Markdown format. The README should be based on the provided project description. The README must include the following sections:
    1. A placeholder for a professional logo at the top.
    2. A clear title and a concise, engaging project description.
    3. Badges for key project metrics (e.g., build status, version) with placeholders.
    4. A comprehensive Features section with clear explanations and relevant emojis or icons.
    5. A Technologies Used section with a list of key technologies and frameworks.
    6. Detailed Installation and Usage instructions, with code blocks where appropriate.
    Do NOT include sections for Contributing, Acknowledgements, Contact, or License.
    Use appropriate headings, lists, and code blocks to make the file look polished and professional.
    """

    user_query = f"Generate a README file for the following project: {project_description}"
    
    payload = {
        "contents": [{"parts": [{"text": user_query}]}],
        "systemInstruction": {"parts": [{"text": system_prompt}]},
    }

    try:
        response = requests.post(f"{API_URL}?key={API_KEY}", headers=headers, data=json.dumps(payload))
        response.raise_for_status()
        
        result = response.json()
        generated_text = result['candidates'][0]['content']['parts'][0]['text']
        return generated_text
        
    except requests.exceptions.RequestException as e:
        print(f"API call failed: {e}")
        return None

def update_and_commit_readme(content):
    """
    Writes the content to the README file and commits the changes.
    """
    with open(README_FILE, "w", encoding="utf-8") as f:
        f.write(content)
        
    subprocess.run(["git", "config", "user.name", "github-actions[bot]"])
    subprocess.run(["git", "config", "user.email", "github-actions[bot]@users.noreply.github.com"])
    
    subprocess.run(["git", "add", README_FILE])
    
    commit_message = "docs: Auto-generate README using AI"
    result = subprocess.run(["git", "commit", "-m", commit_message], capture_output=True)
    
    if "nothing to commit" in result.stdout.decode("utf-8"):
        print("No changes to README.md. Nothing to commit.")
    else:
        subprocess.run(["git", "push"])
        print("Successfully updated and committed README.md.")

# --- Main Execution ---
if __name__ == "__main__":
    print("Starting README generation...")
    
    project_description = get_project_description()
    if not project_description:
        print("Could not get project description. Exiting.")
    else:
        readme_content = generate_readme_content(project_description)
        if readme_content:
            update_and_commit_readme(readme_content)
        else:
            print("Failed to generate README content.")
