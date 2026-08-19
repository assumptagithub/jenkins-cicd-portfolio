
#!/bin/bash

echo "Running portfolio tests..."

if [ ! -f index.html ]; then
    echo "ERROR: index.html not found"
    exit 1
fi

if ! grep -q "<html" index.html; then
    echo "ERROR: HTML document not found"
    exit 1
fi

if ! grep -q "<title>" index.html; then
    echo "ERROR: HTML title not found"
    exit 1
fi

echo "All portfolio tests passed!"
exit 0
