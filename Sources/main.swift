
import Foundation
import SwiftyJSON
import CouchDB
import Kitura

let connProperties = ConnectionProperties(
    host: "127.0.0.1",
    port: 5984,
    secured: false
)

let couchDBClient = CouchDBClient(connectionProperties: connProperties)
let database = couchDBClient.database("kitura_test_db")
let router = Router()



//let dateString = Date()
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
//let dateObj = dateFormatter.date(from: dateString)


func createRecord(userName: String) {
    let jsonDict: [String: AnyObject] = [
        "created_at": dateFormatter.string(from: Date()),
        "userName": userName
    ]
    let json = JSON(jsonDict as AnyObject)
    database.create(json, callback: {
        (id: String?, rev: String?, record: JSON?, error: NSError?) in
        if let error = error {
            print(">> Oops something went wrong; could not persist document.")
            print("Error: \(error.localizedDescription) Code: \(error.code)")
        } else {
            print(">> Successfully created the following JSON document in CouchDB:\n\t\(record)")
        }
    })
}

router.get("/adduser") {
    (request: RouterRequest, response: RouterResponse, next: () -> Void) in
    let inputUser = request.parsedURL.queryParameters["user"]
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    response.status(.OK).send("Add username,\n \(inputUser!)")
    createRecord(userName: inputUser!)
    next()
    print("receive request \(request)")
}

router.get("/fetchusers") {
    (request: RouterRequest, response: RouterResponse, next: () -> Void) in
    database.retrieveAll(includeDocuments: true, callback: {
        (record: JSON?, error: NSError?) in
        response.send((record! as JSON).rawString()!)
        next()
    })
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()


