#!/bin/sh
echo "Serving HTTP on 127.0.0.1 port 3000 ..."
python -c 'import BaseHTTPServer as bhs, SimpleHTTPServer as shs; bhs.HTTPServer(("127.0.0.1", 3000), shs.SimpleHTTPRequestHandler).serve_forever()'

