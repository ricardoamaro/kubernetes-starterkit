'use strict';

const Hapi = require('@hapi/hapi');
const axios = require('axios');

const server = Hapi.server({
    port: 4000,
    routes: { cors: { origin: ['*'] } },
    host: '0.0.0.0'
});

server.route({
    method: 'GET',
    path: '/api/happy/',
    handler: (request, h) => {
        return 'Hey folks, I am HAPI!';
    }
});

server.route({
    method: 'GET',
    path: '/api/happy/{name}',
    handler: (request, h) => {
        return 'Hello, ' + encodeURIComponent(request.params.name) + '!';
    }
});

server.route({  
  method: 'GET',
  path: '/api/happy/multiply',
  handler: (request, h) => {
    const params = request.query
    const result = params.num1 * params.num2;
    postToBootStorage(params.num1, params.num2, '*',result);
    return result;
  }
});

server.route({  
  method: 'GET',
  path: '/api/happy/divide',
  handler: (request, h) => {
    const params = request.query
    const result = params.num1 / params.num2;
    postToBootStorage(params.num1, params.num2, '/',result);
    return result;
  }
});

server.route({
    method: 'GET',
    path: '/api/happy/healthz',
    handler: (request, h) => {
        return 'I am healthy!';
    }
});

/*
  Method to send post request to Srping Boot microservice
*/
function postToBootStorage(num1, num2, operation, result){
  var data = {
        "num1": num1,
        "num2": num2,
        "op": operation,
        "result": result
         };
  
  console.log("Sending create operation request to Spring Boot service 'bootstorage'. Data = ", JSON.stringify(data));
  axios.post('http://bootstorage-svc:5000/api/bootstorage/create', data)
    .then(response => {
      console.log("Received response from Spring Boot service 'bootstorage'");
      if(process.env.LOG_LEVEL == 'DEBUG'){
        console.log("body = " + JSON.stringify(response.data));
      }
    })
    .catch(error => {
      console.log("error = " + error.message);
    });
};

server.events.on('response', function (request) {
    console.log(request.info.remoteAddress + ': ' + request.method.toUpperCase() + ' ' + request.url.path + ' --> ' + request.response.statusCode);
});

const init = async () => {
    await server.start();
    console.log(`Server running at: ${server.info.uri}`);
};

process.on('unhandledRejection', (err) => {
    console.log(err);
    process.exit(1);
});

init();