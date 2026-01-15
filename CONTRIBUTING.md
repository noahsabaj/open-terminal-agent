# Contributing to Terminal Agent

Thanks for your interest in contributing! All contributions are welcome - bug fixes, features, docs, tests.

## Quick Start

1. **Fork and clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/open-terminal-agent.git
   cd open-terminal-agent
   ```

2. **Set up development environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -e .
   ```

3. **Run locally**
   ```bash
   terminal-agent
   ```

## Making Changes

1. Create a branch for your work
   ```bash
   git checkout -b my-feature
   ```

2. Make your changes

3. Test that the agent still works
   ```bash
   terminal-agent  # Manual testing
   python -m pytest tests/  # Run tests
   ```

4. Commit and push
   ```bash
   git add .
   git commit -m "Add my feature"
   git push origin my-feature
   ```

5. Open a pull request against `main`

## What to Work On

- Check [open issues](https://github.com/noahsabaj/open-terminal-agent/issues) for ideas
- Bug fixes are always appreciated
- New tools or features - go for it
- Documentation and test coverage improvements welcome

If you're planning something big, consider opening an issue first to discuss the approach.

## Code Style

No strict rules. Just try to match the existing code:
- Type hints where it makes sense
- f-strings for formatting
- `pathlib.Path` over `os.path`
- Clear function and variable names

## Running Tests

```bash
python -m pytest tests/
```

Test coverage is minimal right now - adding tests is a great way to contribute!

## Questions?

Open an issue or reach out. Happy to help.
