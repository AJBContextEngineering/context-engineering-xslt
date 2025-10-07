"""
Pytest and Behave configuration for XSLT transformation tests.
Provides shared fixtures and setup for test execution.
"""

import os
import sys

# Add project root to Python path for imports
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)


def pytest_configure(config):
    """
    Configure pytest settings.

    Args:
        config: Pytest configuration object
    """
    # Set up any pytest-specific configuration
    pass


def before_all(context):
    """
    Behave hook: Runs once before all tests.

    Args:
        context: Behave context object
    """
    # Reason: Store project paths for easy access in steps
    context.project_root = project_root
    context.src_dir = os.path.join(project_root, 'src')
    context.tests_dir = os.path.join(project_root, 'tests')
    context.fixtures_dir = os.path.join(context.tests_dir, 'fixtures')


def before_scenario(context, scenario):
    """
    Behave hook: Runs before each scenario.

    Args:
        context: Behave context object
        scenario: Current scenario being executed
    """
    # Reset output variables for each scenario
    context.output_xml = None
    context.output_doc = None
    context.source_path = None
    context.xslt_path = None


def after_scenario(context, scenario):
    """
    Behave hook: Runs after each scenario.

    Args:
        context: Behave context object
        scenario: Completed scenario
    """
    # Clean up any temporary resources
    pass


def after_all(context):
    """
    Behave hook: Runs once after all tests.

    Args:
        context: Behave context object
    """
    # Perform any final cleanup
    pass
