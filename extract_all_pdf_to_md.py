import os
from unstructured.partition.pdf import partition_pdf

input_dir = "knowledge/gen系列"
output_dir = input_dir  # 输出到同一目录

for filename in os.listdir(input_dir):
    if filename.lower().endswith(".pdf"):
        pdf_path = os.path.join(input_dir, filename)
        md_name = filename.rsplit('.', 1)[0] + "_unstructured.md"
        md_path = os.path.join(output_dir, md_name)
        print(f"正在处理: {pdf_path} -> {md_path}")
        elements = partition_pdf(filename=pdf_path)
        with open(md_path, "w", encoding="utf-8") as f:
            for el in elements:
                # 智能结构化为Markdown
                if el.category == "Title":
                    f.write(f"# {el.text}\n\n")
                elif el.category == "Section Header":
                    f.write(f"## {el.text}\n\n")
                elif el.category == "List Item":
                    f.write(f"- {el.text}\n")
                elif el.category == "Table":
                    f.write(f"{el.text}\n\n")
                else:
                    f.write(f"{el.text}\n\n")
        print(f"完成: {md_path}")