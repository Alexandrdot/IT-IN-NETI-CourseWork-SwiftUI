class AccessManager {
    
    static let items = ["r": 1, "e": 2, "w": 3, "d": 4] //действия и сотв. номера столбцов
    
    static func GetAccess(user: User) -> [[String : Any]] {
        let dbManager = PostgreSQLManager()
        let result = dbManager.executeTableQuery("accesses","SELECT id_menu, r, e, w, d FROM accesses WHERE id_role=\(user.id_role)") ?? []
        
        return result
    }
    
    static func isAccessForAction(action: String, access: [[String: Any]], id_menu: Int) -> Bool {
        for item in access {
            if let menuIdString = item["column_0"] as? String,
               let menuId = Int(menuIdString) {
                let actionColumn = "column_\(items[action]!)"
                if let accessValue = item[actionColumn] as? String {
                    if menuId == id_menu && accessValue == "t" {
                        return true
                    }
                }
            }
        }
        return false
    }
}
