from http.server import SimpleHTTPRequestHandler, HTTPServer
import json

class S(SimpleHTTPRequestHandler):
#    def do_GET(self):
#        self._set_headers()
#        self.wfile.write("""
#<html>
#<form action='/' method='post'><textarea name='foo'></textarea><input type='submit'></form>
#</html>
#""".encode())

    def do_POST(self):
        len = int(self.headers.get('content-length', 0))
        body = self.rfile.read(len)

        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(('POST ' + self.path + '\n\n').encode() + body)

#    def do_HEAD(self):
#        self._set_headers()

def run(server_class=HTTPServer, handler_class=S, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting httpd...')
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
