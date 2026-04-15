import CryptoKit
import Foundation

final class authManager {
    
    static func hashPassword(_ password: String) -> String {
        let passwordData = Data(password.utf8)
        let hash = SHA256.hash(data: passwordData)
        return Data(hash).base64EncodedString()
    }
    
    static func login(login: String, password: String) -> User? {
        let dbManager = PostgreSQLManager()
        
        let hashedPassword = authManager.hashPassword(password)
        let safeHash = PostgreSQLManager().escapeSQL(hashedPassword)
        let safeLogin = PostgreSQLManager().escapeSQL(login)
        
        if let result = dbManager.executeTableQuery("users", "SELECT id_role FROM users WHERE login='\(safeLogin)' AND pass='\(safeHash)'") {
            if !result.isEmpty, let firstRow = result.first {
                if let roleId = firstRow["column_0"] as? Int {
                    return User(login: login, password: hashedPassword, id_role: roleId)
                } else if let roleString = firstRow["column_0"] as? String,
                          let roleId = Int(roleString) {
                    return User(login: login, password: hashedPassword, id_role: roleId)
                }
            }
        }
        return nil
    }
    
    static func signUp(login: String, password: String) -> User? {
        let dbManager = PostgreSQLManager()
        
        let safeLogin = PostgreSQLManager().escapeSQL(login)
        
        // Проверяем существование пользователя
        if let res = dbManager.executeTableQuery("users", "SELECT login FROM users WHERE login = '\(safeLogin)'") {
            if !res.isEmpty {
                return nil
            }
        }
        
        let hashedPassword = authManager.hashPassword(password)
        let safeHash = PostgreSQLManager().escapeSQL(hashedPassword)
        
        let success = dbManager.executeUpdate("INSERT INTO users (login, pass, id_role) VALUES ('\(safeLogin)', '\(safeHash)', 6)")
        
        return success ? User(login: login, password: hashedPassword, id_role: 6) : nil
    }
    
    static func SetPassword(login: String, password: String) -> Bool {
        let dbManager = PostgreSQLManager()
        
        let hashedPassword = authManager.hashPassword(password)
        let safeHash = PostgreSQLManager().escapeSQL(hashedPassword)
        let safeLogin = PostgreSQLManager().escapeSQL(login)
        
        return dbManager.executeUpdate("UPDATE users SET pass='\(safeHash)' WHERE login='\(safeLogin)'")
    }
}
