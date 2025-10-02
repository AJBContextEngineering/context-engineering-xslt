"""
XSD Schema Loader Module

Loads and parses XSD schema files at server startup for performance.
"""

from lxml import etree
from pathlib import Path
from typing import Dict, Optional
import logging

XSD_NAMESPACE = "http://www.w3.org/2001/XMLSchema"
NSMAP = {"xs": XSD_NAMESPACE}

# Global schema storage
# Reason: Store loaded schemas to avoid re-parsing on each request
_schemas: Dict[str, etree._ElementTree] = {}


def load_all_schemas(schema_dir: str) -> Dict[str, etree._ElementTree]:
    """
    Load all XSD files from directory.

    Args:
        schema_dir: Path to directory containing XSD files

    Returns:
        Dict mapping filename to parsed ElementTree
    """
    # PATTERN: Use pathlib.Path for cross-platform paths
    schema_path = Path(schema_dir)

    if not schema_path.exists():
        logging.warning(f"Schema directory does not exist: {schema_dir}")
        return _schemas

    # PATTERN: glob for all .xsd files recursively
    for xsd_file in schema_path.glob("**/*.xsd"):
        try:
            tree = etree.parse(str(xsd_file))
            filename = xsd_file.name
            _schemas[filename] = tree
            logging.info(f"Loaded schema: {filename}")
        except Exception as e:
            # GOTCHA: Some XSD files may be malformed
            logging.warning(f"Failed to load {xsd_file}: {e}")

    return _schemas


def get_schema(filename: str) -> Optional[etree._ElementTree]:
    """
    Get loaded schema by filename.

    Args:
        filename: Name of the XSD file

    Returns:
        Parsed ElementTree or None if not found
    """
    return _schemas.get(filename)


def get_all_schemas() -> Dict[str, etree._ElementTree]:
    """
    Get all loaded schemas.

    Returns:
        Dict mapping filename to parsed ElementTree
    """
    return _schemas
