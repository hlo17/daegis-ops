import re
from pathlib import Path
import sys

# [[Wikilink]] 形式の正規表現パターン
WIKILINK_PATTERN = re.compile(r"\[\[([^\]|]+)(?:\|[^\]]+)?\]\]")

def resolve_links(start_file: Path, base_dir: Path, processed_files: set) -> str:
    """
    Markdownファイル内のWikilinkを再帰的に解決して内容を展開する。
    """
    if start_file.name in processed_files:
        return ""
    
    processed_files.add(start_file.name)
    
    if not start_file.exists():
        return f"\n--- [ERROR: File not found: {start_file.name}] ---\n"
    
    content = start_file.read_text(encoding='utf-8')
    
    output = f"\n--- [START: {start_file.name}] ---\n"
    output += content
    
    for match in WIKILINK_PATTERN.finditer(content):
        link_name = match.group(1)
        # --- 変更点：.mdを付けずに、リンク名のままでファイルを探す ---
        linked_file = base_dir / link_name
        output += resolve_links(linked_file, base_dir, processed_files)
        
    output += f"\n--- [END: {start_file.name}] ---\n"
    return output

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 link_resolver_v2.py <start_file.md> [notes_directory]")
        sys.exit(1)
        
    start_filename = sys.argv[1]
    notes_directory = Path(sys.argv[2] if len(sys.argv) > 2 else ".").resolve()
    
    start_file_path = Path(start_filename).resolve()
    
    processed = set()
    
    full_context = resolve_links(start_file_path, start_file_path.parent, processed)
    
    output_filename = "context_bundle_v2.txt"
    with open(output_filename, "w", encoding='utf-8') as f:
        f.write(full_context)
        
    print(f"✅ Successfully created '{output_filename}' in {Path.cwd()}")
