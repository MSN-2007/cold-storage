import os
import re

lib_dir = r"c:\work\cold_v1.0.1\mobile\lib"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    content = re.sub(r'Colors\.emerald', 'Colors.green', content)
    content = re.sub(r'MainAxisAlignment\.between', 'MainAxisAlignment.spaceBetween', content)
    content = re.sub(r'BorderSide\(color:\s*severityColor\.withOpacity\(0\.3\)\)', 'Border.all(color: severityColor.withOpacity(0.3))', content)
    content = re.sub(r"textAlign:\s*Center,", "textAlign: TextAlign.center,", content)
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done advanced replacements.")
