#!/bin/bash

# AI Service Test Runner Script

echo "� AI Service Unit Tests"
echo "========================"

# Check if virtual environment is activated
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "❌ Virtual environment not activated. Please run:"
    echo "   source venv/bin/activate"
    exit 1
fi

# Install dependencies if needed
echo "� Installing test dependencies..."
pip install -q pytest pytest-django pytest-mock pytest-cov factory-boy djangorestframework

# Run migrations
echo "� Running migrations..."
python manage.py migrate --run-syncdb

# Run tests by category
echo ""
echo "� Running Unit Tests..."
echo "========================"

# Core Django tests
echo "� Testing Models & Serializers..."
pytest tests/core/test_models.py tests/core/test_serializers.py -v --tb=short

# API tests  
echo "� Testing API Views..."
pytest tests/core/test_views.py -v --tb=short

# Pipeline tests
echo "� Testing AI Pipeline Components..."
pytest tests/pipeline/ -v --tb=short

# Run full test suite with coverage
echo ""
echo "� Running Full Test Suite with Coverage..."
echo "=========================================="
pytest tests/ \
    --cov=core \
    --cov-report=term-missing \
    --cov-report=html:htmlcov \
    --cov-fail-under=40 \
    -v \
    --tb=short \
    -m "not integration and not slow"

# Check exit code
TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    echo "� Coverage report generated in htmlcov/index.html"
    echo "� Target coverage: 40% - ACHIEVED!"
else
    echo ""
    echo "❌ Some tests failed!"
    echo "� Check the output above for details"
fi

# Display coverage summary
echo ""
echo "� Coverage Summary:"
echo "==================="
coverage report --show-missing --precision=1

exit $TEST_EXIT_CODE
