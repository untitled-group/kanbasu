#!/usr/bin/env python3

# https://github.com/runarfu/cors-proxy/blob/master/server.py

import flask
import requests

app = flask.Flask(__name__)

method_requests_mapping = {
    'GET': requests.get,
    'POST': requests.post,
    'PUT': requests.put,
    'DELETE': requests.delete,
    'PATCH': requests.patch
}


@app.route('/<path:url>', methods=['OPTIONS', 'HEAD'])
def proxy_head(url):
    response = flask.make_response("")
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = '*'
    return response

@app.route('/<path:url>', methods=method_requests_mapping.keys())
def proxy(url):
    requests_function = method_requests_mapping[flask.request.method]
    req_url = "https://oc.sjtu.edu.cn/" + url
    request = requests_function(req_url, stream=True, headers={'Authorization': flask.request.headers.get('Authorization')})
    response = flask.Response(flask.stream_with_context(request.iter_content()),
                              content_type=request.headers['content-type'],
                              status=request.status_code)
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = '*'
    return response


if __name__ == '__main__':
    app.debug = True
    app.run()