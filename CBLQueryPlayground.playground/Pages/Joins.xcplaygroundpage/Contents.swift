/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 THIS PLAYGROUND IS WIP. Examples specified here will not work with DB021 of CBL release.
 
 Examples that demonstrate basic JOIN capabilities. Unlike the other examples, the JOIN examples will
 NOT use the travel-sample DB . Instead we will use the jointest sample DB.
 
 We will insert some test documents in a "jointest" DB and use that as examples
 - The "department" type document
 {
 "type": "department",
 "name": "Engineering",
 "code": "1000",
 "head":{
 "firstname":"John",
 "lastname":"Smith"
 }
 
 }
 
 - "employee" type documents. Every employee will have their own document
 /** Document 1 **/
 {
 "type":"employee",
 "firstname":"John",
 "lastname":"Smith",
 "department":"1000"
 }
 
 The following examples will demonstrate
 - Inner Join / Join
 - Left Outer Join/ Left Join
 - Cross Join
 
 */

import UIKit
import CouchbaseLiteSwift
import Foundation
import PlaygroundSupport

/*:
 ## Definition of a Document object returned by the Couchbase Lite query.
 Note that in an actual application, you would probably define a native object instead of a generic map type of the kind defined below
 
 */

typealias Data = [String:Any?]
/*:
 ## Opens Couchbase Lite Database.
 The opens the database from prebuilt travel-sample database in `playgroundSharedDataDirectory`. Make sure that you have the "joindb.cblite2" folder copied over to the ~/Documents/Shared\ Playground\ Data/ folder
 - returns: Handle to CBLite database
 - throws exception if failure to create/open database
 
 */
func createOrOpenDatabase() throws -> Database? {
    let sharedDocumentDirectory = playgroundSharedDataDirectory.resolvingSymlinksInPath()
    let kDBName:String = "joindb"
    let fileManager:FileManager = FileManager.default
    
    var options =  DatabaseConfiguration()
    let appSupportFolderPath = sharedDocumentDirectory.path
    options.fileProtection = .noFileProtection
    options.directory = appSupportFolderPath
    
    // Uncomment the line below  if you want details of the SQLite query equivalent
    // Database.setLogLevel(.verbose, domain: .all)
    return try Database(name: kDBName, config: options)
    
}

/*:
 ## Close database
 - parameter db : The database to close
 - throws exception if failure to close
 */

func closeDatabase(_ db:Database) throws  {
    try db.close()
}

/*:
 ## Do an inner Join on "employee" type documents with "department" type documents based
 on the department code
 The "firstname", "lastname" properties from "employee" document are returned along with the
 department "name" from the "department" document
 - parameter db : The database to query
 - returns: Documents matching the query
 
 */

func queryForDocumentsFromDatabasePerformingInnerJoin(_ db:Database) throws -> [Data]? {
    
    let employeeDS = DataSource.database(db).as("employeeDS")
    let departmentDS = DataSource.database(db).as("departmentDS")

    let employeeDeptExpr = Expression.property("department").from("employeeDS")
    let departmentCodeExpr = Expression.property("code").from("departmentDS")

    // Join where the "department" field of employee documents is equal to the department "code" of
    // "department" documents
    let joinExpr = employeeDeptExpr.equalTo(departmentCodeExpr)
        .and(Expression.property("type").from("employeeDS").equalTo("employee"))
        .and(Expression.property("type").from("departmentDS").equalTo("department"))

    // join expression
    let join = Join.join(departmentDS).on(joinExpr)

    let searchQuery = Query.select(SelectResult.expression(Expression.property("firstname").from("employeeDS")),
                        SelectResult.expression(Expression.property("lastname").from("employeeDS")),
                        SelectResult.expression(Expression.property("name").from("departmentDS")))
        .from(employeeDS)
        .join(join)


   // print(try searchQuery.explain())
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
            let r = row.toDictionary()
            print(r)

            matches.append(row.toDictionary())
        }
    }
    return matches
}

/*:
 ## Do an left Join on "employee" type documents with "department" type documents based
 on the department code. In this case, even employee documents that have no departments
 are returned
 The "firstname", "lastname" properties from "employee" document are returned along with the
 department "name" from the "department" document.

 - parameter db : The database to query
 - returns: Documents matching the query
 
 */

func queryForDocumentsFromDatabasePerformingLeftJoin(_ db:Database) throws -> [Data]? {
    // join key cannot be missing. cannot hsve employee doc with department missing
    let employeeDS = DataSource.database(db).as("employeeDS")
    let departmentDS = DataSource.database(db).as("departmentDS")

    let employeeDeptExpr = Expression.property("department").from("employeeDS")
    let departmentCodeExpr = Expression.property("code").from("departmentDS")

    // Join where the "department" field of employee documents is equal to the department "code" of
    // "department" documents
    let joinExpr = employeeDeptExpr.equalTo(departmentCodeExpr)
        .and(Expression.property("type").from("employeeDS").equalTo("employee"))
        .and(Expression.property("type").from("departmentDS").equalTo("department"))

    // join expression
    let join = Join.leftJoin(departmentDS).on(joinExpr)

    let searchQuery = Query.select(SelectResult.expression(Expression.property("firstname").from("employeeDS")),
                                   SelectResult.expression(Expression.property("lastname").from("employeeDS")),
                                   SelectResult.expression(Expression.property("name").from("departmentDS")))
        .from(employeeDS)
        .join(join)
    
   
    // print(try searchQuery.explain())
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
        
            let r = row.toDictionary()
            print(r)

            matches.append(row.toDictionary())
        }
    }
    return matches
}



/*:
 ## Run the queries defined in the above functions
 */


do {
    // Open or Create Couchbase Lite Database
    if let db:Database = try createOrOpenDatabase() {
        
        let results1 = try queryForDocumentsFromDatabasePerformingInnerJoin(db)
        print("\n*****\nResponse to queryForDocumentsFromDatabasePerformingInnerJoin :\n\(results1)")

        let results2 = try queryForDocumentsFromDatabasePerformingLeftJoin(db)
        print("\n*****\nResponse to queryForDocumentsFromDatabasePerformingLeftJoin :\n\(results2)")

        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}




