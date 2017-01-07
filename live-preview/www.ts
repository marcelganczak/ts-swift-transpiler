import app = require('./app');
import http = require('http');
const port = 8081;

app.set('port', port);

var server = http.createServer(app);
server.listen(port);
server.on('listening', function(){ console.log('Listening on ' + port) });