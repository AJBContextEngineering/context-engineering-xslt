"""
Behave configuration for DispatchSync XSLT mapping tests
Provides hooks and shared fixtures
"""


def before_all(context):
    """
    Hook that runs before all tests
    Setup any global configuration here
    """
    context.config.setup_logging()


def after_scenario(context, scenario):
    """
    Hook that runs after each scenario
    Cleanup resources
    """
    # Cleanup saxonche processor if it exists
    if hasattr(context, 'proc'):
        delattr(context, 'proc')
    if hasattr(context, 'xslt_proc'):
        delattr(context, 'xslt_proc')
    if hasattr(context, 'result'):
        delattr(context, 'result')
