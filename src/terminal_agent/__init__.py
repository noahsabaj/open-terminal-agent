"""Terminal Agent - A coding agent for the terminal, powered by Ollama Cloud."""

from terminal_agent.agent import VERSION, run_agent

__version__ = VERSION
__all__ = ["run_agent", "__version__"]
