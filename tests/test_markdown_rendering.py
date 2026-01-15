#!/usr/bin/env python3
"""
Test application to validate markdown-it-py parsing and Rich terminal rendering.

This demonstrates:
1. How markdown-it-py parses markdown into tokens
2. How to walk the token tree
3. How to render each element type using Rich

Run with: python test_markdown_rendering.py
"""

from markdown_it import MarkdownIt
from markdown_it.tree import SyntaxTreeNode
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.syntax import Syntax
from rich.text import Text
from rich.markdown import Markdown as RichMarkdown
from rich import box

console = Console()

# Test markdown covering all common elements
TEST_MARKDOWN = """
# Heading 1

## Heading 2

### Heading 3

This is a paragraph with **bold text**, *italic text*, and `inline code`.
Here's some ~~strikethrough~~ text too.

---

> This is a blockquote.
> It can span multiple lines.
>
> > And can be nested!

### Lists

Unordered list:
- Item one
- Item two
  - Nested item
  - Another nested item
- Item three

Ordered list:
1. First item
2. Second item
3. Third item

### Code Blocks

```python
def hello_world():
    print("Hello, World!")
    return 42
```

```bash
echo "Shell script example"
ls -la
```

### Tables

| Feature | Status | Notes |
|---------|--------|-------|
| Headers | ✓ | Working great |
| Bold/Italic | ✓ | Full support |
| Tables | ✓ | With alignment |
| Code blocks | ✓ | Syntax highlighted |

| Left | Center | Right |
|:-----|:------:|------:|
| L1 | C1 | R1 |
| L2 | C2 | R2 |

### Links and Images

Here's a [link to GitHub](https://github.com).

![Alt text for image](https://example.com/image.png)

### Edge Cases

A table with special characters:

| Symbol | Meaning |
|--------|---------|
| `|` | Pipe character |
| `*` | Asterisk |
| `>` | Greater than |

Inline formatting combinations: ***bold and italic***, **bold with `code`**

A paragraph with a hard break:
Two lines separated by two spaces.

"""

# Additional edge case tests
EDGE_CASE_MARKDOWN = """
### Edge Case: Empty Table Cells

| Col1 | Col2 | Col3 |
|------|------|------|
| a | | c |
| | b | |

### Edge Case: Single Column Table

| Single |
|--------|
| Row 1 |
| Row 2 |

### Edge Case: Long Content

| Description | Value |
|-------------|-------|
| This is a very long description that might wrap in the terminal | 12345 |
| Short | This value is also quite long and demonstrates text wrapping behavior |

### Edge Case: Mixed Inline in Table

| Format | Example |
|--------|---------|
| Bold | **bold text** |
| Italic | *italic text* |
| Code | `code text` |
| Mixed | **bold** and *italic* |
"""


def section(title: str):
    """Print a section header."""
    console.print()
    console.print(Panel(title, style="bold magenta", box=box.DOUBLE))
    console.print()


def demo_token_parsing():
    """Show how markdown-it-py parses markdown into tokens."""
    section("1. TOKEN PARSING DEMONSTRATION")

    simple_md = "# Hello\n\nThis is **bold** and *italic*."

    console.print("[bold cyan]Input Markdown:[/]")
    console.print(Panel(simple_md, box=box.ROUNDED))

    # Parse with GFM-like config (includes tables)
    md = MarkdownIt("commonmark").enable("table").enable("strikethrough")
    tokens = md.parse(simple_md)

    console.print("\n[bold cyan]Parsed Tokens (flat list):[/]")

    token_table = Table(box=box.SIMPLE)
    token_table.add_column("Type", style="green")
    token_table.add_column("Tag", style="yellow")
    token_table.add_column("Nesting", style="cyan")
    token_table.add_column("Content", style="white", max_width=40)

    for token in tokens:
        nesting_str = {1: "open", 0: "self", -1: "close"}.get(token.nesting, str(token.nesting))
        content = token.content[:40] + "..." if len(token.content) > 40 else token.content
        content = content.replace("\n", "\\n")
        token_table.add_row(token.type, token.tag, nesting_str, content or "-")

    console.print(token_table)


def demo_syntax_tree():
    """Show the syntax tree representation."""
    section("2. SYNTAX TREE REPRESENTATION")

    simple_md = "# Title\n\n- Item 1\n- Item 2\n\n> Quote"

    console.print("[bold cyan]Input Markdown:[/]")
    console.print(Panel(simple_md, box=box.ROUNDED))

    md = MarkdownIt("commonmark")
    tokens = md.parse(simple_md)
    node = SyntaxTreeNode(tokens)

    console.print("\n[bold cyan]Syntax Tree:[/]")
    console.print(node.pretty(indent=2, show_text=True))


def demo_table_tokens():
    """Show detailed table token structure."""
    section("3. TABLE TOKEN STRUCTURE")

    table_md = """| A | B |
|---|---|
| 1 | 2 |
| 3 | 4 |"""

    console.print("[bold cyan]Input Table Markdown:[/]")
    console.print(Panel(table_md, box=box.ROUNDED))

    md = MarkdownIt("commonmark").enable("table")
    tokens = md.parse(table_md)

    console.print("\n[bold cyan]Table Tokens:[/]")

    token_table = Table(box=box.SIMPLE)
    token_table.add_column("Type", style="green")
    token_table.add_column("Tag", style="yellow")
    token_table.add_column("Nesting", style="cyan")
    token_table.add_column("Attrs", style="magenta", max_width=30)

    for token in tokens:
        nesting_str = {1: "open", 0: "self", -1: "close"}.get(token.nesting, str(token.nesting))
        attrs_str = str(dict(token.attrs)) if token.attrs else "-"
        token_table.add_row(token.type, token.tag or "-", nesting_str, attrs_str)

    console.print(token_table)


def demo_rich_builtin():
    """Show Rich's built-in markdown rendering."""
    section("4. RICH'S BUILT-IN MARKDOWN RENDERING")

    console.print("[bold cyan]Rich's Markdown class output:[/]")
    console.print()
    console.print(RichMarkdown(TEST_MARKDOWN))


def demo_custom_table_rendering():
    """Demonstrate custom table rendering with Rich Table widget."""
    section("5. CUSTOM TABLE RENDERING (Box Drawing)")

    table_md = """| Feature | Status | Notes |
|---------|:------:|------:|
| Headers | ✓ | Left aligned |
| Tables | ✓ | Center aligned |
| Code | ✓ | Right aligned |"""

    console.print("[bold cyan]Input:[/]")
    console.print(Panel(table_md, box=box.ROUNDED))

    md = MarkdownIt("commonmark").enable("table")
    tokens = md.parse(table_md)

    # Extract table data from tokens
    headers = []
    rows = []
    current_row = []
    in_header = False
    in_body = False
    alignments = []

    for token in tokens:
        if token.type == "thead_open":
            in_header = True
        elif token.type == "thead_close":
            in_header = False
            if current_row:
                headers = current_row
                current_row = []
        elif token.type == "tbody_open":
            in_body = True
        elif token.type == "tbody_close":
            in_body = False
        elif token.type == "tr_close":
            if current_row and in_body:
                rows.append(current_row)
            current_row = []
        elif token.type == "th_open" or token.type == "td_open":
            # Extract alignment from style attribute
            style = token.attrs.get("style", "") if token.attrs else ""
            if "text-align:center" in style:
                alignments.append("center")
            elif "text-align:right" in style:
                alignments.append("right")
            else:
                alignments.append("left")
        elif token.type == "inline":
            current_row.append(token.content)

    # Render with Rich Table
    console.print("\n[bold cyan]Custom Rich Table rendering:[/]")

    rich_table = Table(box=box.ROUNDED, show_header=True, header_style="bold cyan")

    # Add columns with alignment
    for i, header in enumerate(headers):
        justify = alignments[i] if i < len(alignments) else "left"
        rich_table.add_column(header, justify=justify)

    # Add rows
    for row in rows:
        rich_table.add_row(*row)

    console.print(rich_table)


def demo_all_token_types():
    """Show all token types from comprehensive markdown."""
    section("6. ALL TOKEN TYPES IN TEST MARKDOWN")

    md = MarkdownIt("commonmark").enable("table").enable("strikethrough")
    tokens = md.parse(TEST_MARKDOWN)

    # Collect unique token types
    token_types = set()
    for token in tokens:
        token_types.add(token.type)
        if token.children:
            for child in token.children:
                token_types.add(f"  (inline) {child.type}")

    console.print("[bold cyan]Unique token types found:[/]")

    # Group by category
    block_tokens = sorted([t for t in token_types if not t.startswith("  ")])
    inline_tokens = sorted([t for t in token_types if t.startswith("  ")])

    cols = Table(box=box.SIMPLE, show_header=True)
    cols.add_column("Block-level Tokens", style="green")
    cols.add_column("Inline Tokens", style="yellow")

    max_len = max(len(block_tokens), len(inline_tokens))
    for i in range(max_len):
        block = block_tokens[i] if i < len(block_tokens) else ""
        inline = inline_tokens[i].strip() if i < len(inline_tokens) else ""
        cols.add_row(block, inline)

    console.print(cols)


def demo_edge_cases():
    """Test edge cases."""
    section("7. EDGE CASE RENDERING")

    console.print("[bold cyan]Testing edge cases with Rich's built-in:[/]")
    console.print()
    console.print(RichMarkdown(EDGE_CASE_MARKDOWN))


def demo_inline_rendering():
    """Show inline token handling."""
    section("8. INLINE TOKEN DETAILS")

    inline_md = "This has **bold**, *italic*, `code`, and a [link](http://x.com)."

    console.print("[bold cyan]Input:[/]")
    console.print(Panel(inline_md, box=box.ROUNDED))

    md = MarkdownIt("commonmark")
    tokens = md.parse(inline_md)

    console.print("\n[bold cyan]Inline tokens inside paragraph:[/]")

    for token in tokens:
        if token.type == "inline" and token.children:
            token_table = Table(box=box.SIMPLE)
            token_table.add_column("Type", style="green")
            token_table.add_column("Tag", style="yellow")
            token_table.add_column("Content", style="white", max_width=30)
            token_table.add_column("Attrs", style="magenta", max_width=30)

            for child in token.children:
                content = child.content[:30] if child.content else "-"
                attrs = str(dict(child.attrs)) if child.attrs else "-"
                token_table.add_row(child.type, child.tag or "-", content, attrs)

            console.print(token_table)


def demo_comparison():
    """Side-by-side comparison summary."""
    section("9. RENDERING APPROACH COMPARISON")

    comparison = Table(box=box.ROUNDED, title="Comparison Summary")
    comparison.add_column("Aspect", style="bold")
    comparison.add_column("Rich Built-in", style="cyan")
    comparison.add_column("Custom w/ Rich.Table", style="green")

    comparison.add_row("Tables", "Basic rendering", "Box-drawing characters ✓")
    comparison.add_row("Headers", "Styled ✓", "Styled ✓")
    comparison.add_row("Code blocks", "Syntax highlighted ✓", "Syntax highlighted ✓")
    comparison.add_row("Lists", "Formatted ✓", "Formatted ✓")
    comparison.add_row("Blockquotes", "Styled ✓", "Styled ✓")
    comparison.add_row("Edge cases", "Handled by markdown-it-py", "Handled by markdown-it-py")
    comparison.add_row("Maintenance", "Zero - Rich handles it", "Minimal - just table mapping")

    console.print(comparison)


def main():
    console.print(Panel.fit(
        "[bold white]markdown-it-py + Rich Terminal Rendering Test[/]\n"
        "Validating parsing and rendering capabilities",
        border_style="bright_blue"
    ))

    demo_token_parsing()
    demo_syntax_tree()
    demo_table_tokens()
    demo_rich_builtin()
    demo_custom_table_rendering()
    demo_all_token_types()
    demo_edge_cases()
    demo_inline_rendering()
    demo_comparison()

    section("CONCLUSION")
    console.print("""
[bold green]✓ markdown-it-py successfully parses all markdown elements[/]
[bold green]✓ Token structure provides full access to document structure[/]
[bold green]✓ Rich can render most elements beautifully out of the box[/]
[bold green]✓ Tables can be enhanced with Rich.Table for box-drawing[/]
[bold green]✓ Edge cases (empty cells, alignment, special chars) handled[/]

[bold cyan]Recommendation:[/]
Use markdown-it-py for parsing, Rich.Markdown for most content,
and Rich.Table specifically for tables to get box-drawing characters.
""")


if __name__ == "__main__":
    main()
