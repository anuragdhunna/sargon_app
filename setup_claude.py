#!/usr/bin/env python3
import os
import json
import re

def clean_json_comments(text):
    # Remove single line comments
    text = re.sub(r'//.*?\n', '\n', text)
    # Remove multi-line comments
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    return text

def update_vscode_settings(file_path):
    print(f"Checking VS Code settings file at: {file_path}")
    
    # Ensure directory exists
    dir_path = os.path.dirname(file_path)
    if not os.path.exists(dir_path):
        try:
            os.makedirs(dir_path)
            print(f"Created directory: {dir_path}")
        except Exception as e:
            print(f"Error creating directory {dir_path}: {e}")
            return False

    settings = {}
    if os.path.exists(file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            cleaned_content = clean_json_comments(content)
            # Handle empty/whitespace file
            if cleaned_content.strip():
                settings = json.loads(cleaned_content)
                print(f"Successfully loaded existing settings from {file_path}")
        except Exception as e:
            print(f"Warning: Could not parse {file_path} as JSON ({e}). Backing up file.")
            backup_path = file_path + ".bak"
            try:
                if os.path.exists(backup_path):
                    os.remove(backup_path)
                os.rename(file_path, backup_path)
                print(f"Backed up corrupted settings to {backup_path}")
            except Exception as backup_err:
                print(f"Backup failed: {backup_err}")
            settings = {}

    # 1. Update terminal integrated env so CLI works in VS Code Terminal
    for os_key in ["terminal.integrated.env.osx", "terminal.integrated.env.linux", "terminal.integrated.env.windows"]:
        if os_key not in settings:
            settings[os_key] = {}
        settings[os_key]["ANTHROPIC_BASE_URL"] = "http://localhost:8082"
        settings[os_key]["ANTHROPIC_AUTH_TOKEN"] = "freecc"
        print(f"  - Updated variables for {os_key}")

    # 2. Update extension configurations
    env_vars_list = [
        {"name": "ANTHROPIC_BASE_URL", "value": "http://localhost:8082"},
        {"name": "ANTHROPIC_AUTH_TOKEN", "value": "freecc"}
    ]
    
    settings["claudeCode.environmentVariables"] = env_vars_list
    settings["claude-code.environmentVariables"] = env_vars_list
    print("  - Updated claudeCode.environmentVariables and claude-code.environmentVariables lists")

    # Save settings back
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(settings, f, indent=4)
        print(f"Successfully updated settings in {file_path}\n")
        return True
    except Exception as e:
        print(f"Error writing settings to {file_path}: {e}\n")
        return False

def update_claude_settings(file_path):
    print(f"Checking Claude configuration settings at: {file_path}")
    
    # Ensure directory exists
    dir_path = os.path.dirname(file_path)
    if not os.path.exists(dir_path):
        try:
            os.makedirs(dir_path)
            print(f"Created directory: {dir_path}")
        except Exception as e:
            print(f"Error creating directory {dir_path}: {e}")
            return False

    settings = {}
    if os.path.exists(file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            cleaned_content = clean_json_comments(content)
            if cleaned_content.strip():
                settings = json.loads(cleaned_content)
                print(f"Successfully loaded existing settings from {file_path}")
        except Exception as e:
            print(f"Warning: Could not parse {file_path} as JSON ({e}). Backing up file.")
            backup_path = file_path + ".bak"
            try:
                if os.path.exists(backup_path):
                    os.remove(backup_path)
                os.rename(file_path, backup_path)
                print(f"Backed up corrupted settings to {backup_path}")
            except Exception as backup_err:
                print(f"Backup failed: {backup_err}")
            settings = {}

    # Setup the env dictionary
    if "env" not in settings:
        settings["env"] = {}
    
    settings["env"]["ANTHROPIC_BASE_URL"] = "http://localhost:8082"
    settings["env"]["ANTHROPIC_AUTH_TOKEN"] = "freecc"
    print("  - Set env ANTHROPIC_BASE_URL and ANTHROPIC_AUTH_TOKEN")

    # Save settings back
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(settings, f, indent=4)
        print(f"Successfully updated settings in {file_path}\n")
        return True
    except Exception as e:
        print(f"Error writing settings to {file_path}: {e}\n")
        return False

def main():
    print("==================================================")
    print("       VS Code & Claude Proxy Setup Script        ")
    print("==================================================\n")
    
    # Find current directory
    current_dir = os.path.dirname(os.path.abspath(__file__))
    home_dir = os.path.expanduser("~")

    # Define targets
    workspace_vscode = os.path.join(current_dir, ".vscode", "settings.json")
    global_vscode = os.path.join(home_dir, "Library", "Application Support", "Code", "User", "settings.json")
    project_claude = os.path.join(current_dir, ".claude", "settings.json")
    global_claude = os.path.join(home_dir, ".claude", "settings.json")

    results = {}

    # 1. Update VS Code Workspace settings
    results["Workspace VS Code Settings"] = update_vscode_settings(workspace_vscode)

    # 2. Update VS Code Global settings (optional/best effort)
    results["Global VS Code Settings"] = update_vscode_settings(global_vscode)

    # 3. Update Claude Project settings
    results["Project .claude Settings"] = update_claude_settings(project_claude)

    # 4. Update Claude Global settings
    results["Global .claude Settings"] = update_claude_settings(global_claude)

    # Output final status board
    print("==================================================")
    print("                 SETUP STATUS BOARD               ")
    print("==================================================")
    for key, success in results.items():
        unicode_status = "[✓] SUCCESS" if success else "[✗] FAILED (or Skipped)"
        print(f"{key:<30} : {unicode_status}")
    print("==================================================\n")
    print("👉 Action Required:")
    print("1. Restart VS Code (or run 'Developer: Reload Window' in palette).")
    print("2. Launch your terminal sessions within VS Code so they inherit the new environment variables.")
    print("3. Run 'claude' or use the Claude Code extension to enjoy the free high-speed proxy setup!")
    print("==================================================")

if __name__ == "__main__":
    main()
