import os
import re

lib_dir = r"c:\work\cold_v1.0.1\mobile\lib"

replacements = {
    # Imports
    r"import 'core/network/dio_client.dart';": "",
    r"import '../../../../core/theme/cs_colors.dart';": "",
    
    # Method names
    r"toIso8String": "toIso8601String",
    r"authNotifierProvider": "authStateProvider",
    r"\.verifyOTP\(": ".verifyOtp(",
    r"\.requestOTP\(": ".loginWithPhone(",  # verifyOtp expects phone, password for loginWithPhone
    
    # Flutter constants
    r"Colors\.emerald": "Colors.green",
    r"MainAxisAlignment\.between": "MainAxisAlignment.spaceBetween",
    r"textAlign: Center,": "textAlign: TextAlign.center,",
    r"border: BorderSide\(": "border: Border.all(",
    r"CSColors\.forDeviceStatus\(device\.status\)": "device.status == 'online' ? Colors.green : Colors.red",
    r"border: Border\.all\(color: severityColor\.withOpacity\(0\.3\)\)": "border: Border.all(color: severityColor.withOpacity(0.3))", # This was actually replacing BorderSide with BoxBorder correctly, wait let me use regex properly
}

# Advanced regex replacements
regex_replacements = [
    (r"border:\s*BorderSide\(", r"border: Border.all("),
    (r"CSColors\.forDeviceStatus\(([^)]+)\)", r"(\1 == 'online' ? Colors.green : Colors.red)"),
]

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    for old, new in replacements.items():
        content = content.replace(old, new)
        
    for pattern, repl in regex_replacements:
        content = re.sub(pattern, repl, content)
        
    # Specific fixes
    # Fix onKeyEvent in TextFormField
    content = re.sub(r"onKeyEvent:\s*\(event\)\s*\{[^}]+\},?", "", content, flags=re.MULTILINE)
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done replacements.")
