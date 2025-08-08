"""
BDD Test Configuration for XSLT Field Mappings

This module provides pytest and behave configuration for XSLT testing
using SaxonHE processor and Python unittest framework.
"""

import pytest
import os
from pathlib import Path

# Configure test paths
TEST_ROOT = Path(__file__).parent
PROJECT_ROOT = TEST_ROOT.parent
SOURCE_XSL_PATH = PROJECT_ROOT / "src" / "mapping.xsl"
TEST_DATA_PATH = TEST_ROOT / "test_data"

@pytest.fixture
def xsl_file_path():
    """Fixture to provide path to XSLT mapping file."""
    return str(SOURCE_XSL_PATH)

@pytest.fixture
def source_xml_path():
    """Fixture to provide path to source sample XML."""
    return str(TEST_DATA_PATH / "source_sample.xml")

@pytest.fixture
def expected_output_path():
    """Fixture to provide path to expected output XML."""
    return str(TEST_DATA_PATH / "expected_output.xml")

def pytest_configure(config):
    """Configure pytest for XSLT testing."""
    # Ensure required paths exist
    assert SOURCE_XSL_PATH.exists(), f"XSLT file not found: {SOURCE_XSL_PATH}"
    assert TEST_DATA_PATH.exists(), f"Test data directory not found: {TEST_DATA_PATH}"