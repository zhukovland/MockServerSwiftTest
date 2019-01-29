//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectHTTPServer
import Foundation

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(request: HTTPRequest, response: HTTPResponse) {
	// Respond with a simple message.
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
	// Ensure that response.completed() is called when your processing is done.
	response.completed()
}

// Configure one server which:
//	* Serves the hello world message at <host>:<port>/
//	* Serves static files out of the "./webroot"
//		directory (which must be located in the current working directory).
//	* Performs content compression on outgoing data when appropriate.
var routes = Routes()

routes.add(method: .get, uri: "/catalog") { request, responce in
    
    let responceCatalogData = ["pageNumber" : 1, "products": [["id_product": 1, "product_name" : "testProduct1", "price" : 666 ], ["id_product": 2, "product_name" : "testProduct2", "price" : 666 ]]] as [String : Any]
    
    try! responce.setBody(json: responceCatalogData, skipContentType: true)
    responce.completed()
}


routes.add(method: .post, uri: "/login") { request, responce in
    
    guard request.param(name: "username") != nil || request.param(name: "password") != nil else {
        responce.completed(status: HTTPResponseStatus.custom(code: 500, message: "TestError"))
        return
    }
//
    
    let responceLoginData = ["result" : 1 , "user": ["id_user": 1, "user_login": "testUser", "user_name": "testUserName", "user_lastname": "testUserLastName"]] as [String : Any]
    
    
     try! responce.setBody(json: responceLoginData, skipContentType: true)
    responce.completed()
    
}
routes.add(method: .get, uri: "/**",
		   handler: StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest)

try HTTPServer.launch(name: "localhost",
					  port: 8181,
					  routes: routes,
					  responseFilters: [
						(PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

