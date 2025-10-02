"""
MCP Server Entry Point

Initializes and runs the FastMCP server for XSD fragment extraction.
"""

from fastmcp import FastMCP
from dotenv import load_dotenv
import os
import logging
try:
    # Try relative imports first (when run as module)
    from .schema_loader import load_all_schemas
    from .tools import register_tools
    from .fragment_extractor import set_all_schemas
except ImportError:
    # Fall back to absolute imports (when run directly)
    from schema_loader import load_all_schemas
    from tools import register_tools
    from fragment_extractor import set_all_schemas

# CRITICAL: Load environment variables first
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)

# PATTERN: Get config from environment with defaults
XSD_SCHEMA_DIR = os.getenv("XSD_SCHEMA_DIR", "./xsd")
MCP_SERVER_NAME = os.getenv("MCP_SERVER_NAME", "XSD Fragment Extractor")

# Initialize FastMCP
mcp = FastMCP(MCP_SERVER_NAME)

# CRITICAL: Load schemas at startup, not on each request
# Reason: Performance - XSD parsing is expensive
logging.info(f"Loading XSD schemas from {XSD_SCHEMA_DIR}...")
schemas = load_all_schemas(XSD_SCHEMA_DIR)
logging.info(f"Loaded {len(schemas)} schemas")

# Set schemas for cross-schema lookups in fragment extractor
# Reason: XSD includes mean elements/types can be defined in different files
set_all_schemas(schemas)

# Register tools
register_tools(mcp)

if __name__ == "__main__":
    # PATTERN: FastMCP run() handles MCP protocol
    mcp.run()
