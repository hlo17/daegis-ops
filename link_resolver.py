import re
from pathlib import Path
import sys

# [[Wikilink]] 形式の正規表現パターン
WIKILINK_PATTERN = re.compile(r"\[\[([^\]|]+)(?:\|[^\]]+)?\]\]")

def resolve_links(start_file: Path, base_dir: Path, processed_files: set) -> str:
    """
    Markdownファイル内のWikilinkを再帰的に解決して内容を展開する。
    """
    # 循環参照を防ぐため、一度処理したファイルはスキップ
    if start_file.name in processed_files:
        return ""
    
    processed_files.add(start_file.name)
    
    if not start_file.exists():
        return f"\n--- [ERROR: File not found: {start_file.name}] ---\n"
    
    content = start_file.read_text(encoding='utf-8')
    
    # ファイルの区切りとファイル名を明記
    output = f"\n--- [START: {start_file.name}] ---\n"
    output += content
    
    # ファイル内のWikilinkを探して再帰的に解決
    for match in WIKILINK_PATTERN.finditer(content):
        link_name = match.group(1)
        linked_file = base_dir / f"{link_name}.md"
        output += resolve_links(linked_file, base_dir, processed_files)
        
    output += f"\n--- [END: {start_file.name}] ---\n"
    return output

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 link_resolver.py <start_file.md> [notes_directory]")
        sys.exit(1)
        
    start_filename = sys.argv[1]
    notes_directory = Path(sys.argv[2] if len(sys.argv) > 2 else ".")
    
    start_file_path = notes_directory / start_filename
    
    # 処理済みファイル名を保持するセット
    processed = set()
    
    # リンクを解決して全コンテンツを結合
    full_context = resolve_links(start_file_path, notes_directory, processed)
    
    # 結果をファイルに出力
    output_filename = "context_bundle.txt"
    with open(output_filename, "w", encoding='utf-8') as f:
        f.write(full_context)
        
    print(f"✅ Successfully created '{output_filename}' in {Path.cwd()}")
