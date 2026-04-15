import PostgresClientKit
import Foundation

class PostgreSQLManager {
    private var configuration: ConnectionConfiguration
    
    init(host: String = "127.0.0.1",
             port: Int = 5432,
             database: String = "it_nstu",
             user: String = "aleksandr") {
            
            var config = ConnectionConfiguration()
            config.host = host
            config.port = port
            config.database = database
            config.user = user
            config.credential = .trust
            config.ssl = false
            
            self.configuration = config
        }
    
    func executeTableQuery(_ tableName: String, _ customQuery: String? = nil) -> [[String: Any]]? {
        do {
            print("🔐 Using credential: \(configuration.credential)")
            let connection = try Connection(configuration: configuration)
            defer { connection.close() }
            
            let query = customQuery ?? "SELECT * FROM \(tableName)"
            print("📝 Executing: \(query)")
            
            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            var results: [[String: Any]] = []
            
            for row in cursor {
                let columns = try row.get().columns
                var rowDict: [String: Any] = [:]
                
                for (index, column) in columns.enumerated() {
                    let columnName = "column_\(index)"
                    
                    if let stringValue = try? column.string() {
                        rowDict[columnName] = stringValue
                    } else if let intValue = try? column.int() {
                        rowDict[columnName] = intValue
                    } else if let doubleValue = try? column.double() {
                        rowDict[columnName] = doubleValue
                    } else if let boolValue = try? column.bool() {
                        rowDict[columnName] = boolValue
                    } else if let dateValue = try? column.date() {
                        rowDict[columnName] = dateValue
                    } else {
                        rowDict[columnName] = nil
                    }
                }
                results.append(rowDict)
            }
            
            print("✅ Success! Rows: \(results.count)")
            return results
            
        } catch {
            print("❌ Error: \(error)")
            return nil
        }
    }
    
    func getTableColumnNames(_ tableName: String) -> [String] {
        do {
            print("🔐 Using credential: \(configuration.credential)")
            let connection = try Connection(configuration: configuration)
            defer { connection.close() }
            
            let metaQuery = """
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = '\(tableName)' 
            ORDER BY ordinal_position
            """
            
            print("📝 Getting column names for: \(tableName)")
            
            let metaStatement = try connection.prepareStatement(text: metaQuery)
            defer { metaStatement.close() }
            
            let metaCursor = try metaStatement.execute()
            defer { metaCursor.close() }
            
            var names: [String] = []
            for row in metaCursor {
                if let name = try row.get().columns.first?.string() {
                    names.append(name)
                }
            }
            
            print("✅ Column names: \(names)")
            return names
            
        } catch {
            print("❌ Error getting column names: \(error)")
            return []
        }
    }
    
    func executeUpdate(_ sql: String) -> Bool {
        do {
            let connection = try Connection(configuration: configuration)
            defer { connection.close() }
            
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }
            
            _ = try statement.execute()
            
           
            var eventType = ""
            if sql.uppercased().contains("INSERT") {
                eventType = "add"
            } else if sql.uppercased().contains("UPDATE") {
                eventType = "set"
            } else if sql.uppercased().contains("DELETE") {
                eventType = "delete"
            }
            if !eventType.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let currentDate = formatter.string(from: Date())

                let logSQL = """
                INSERT INTO logs (event_date, event_type)
                VALUES ('\(currentDate)', '\(eventType)')
                """
                
                do {
                    let logStatement = try connection.prepareStatement(text: logSQL)
                    defer { logStatement.close() }
                    _ = try logStatement.execute()
                    print("✅ Log added: \(eventType) event")
                } catch {
                    print("⚠️ Failed to log event: \(error)")
                }
            }
            
            return true
            
        } catch {
            print("❌ Update error: \(error)")
            return false
        }
    }
    
    func escapeSQL(_ input: String) -> String {
        return input.replacingOccurrences(of: "'", with: "''")
    }
    
}
