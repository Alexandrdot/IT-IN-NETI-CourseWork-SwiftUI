import SwiftUI

//admin - вынесли отдельно для удобства дополнения и обновления

struct AdminView: View {
    
    @Binding var isAuthenticated: Bool
    @Binding var user: User?
    
    @State private var searchText = ""
    @State private var needsRefresh = false
    @State var SelectedItem: [String] = [""]
    @State var showEditUser: Bool = false
    
    @State private var list_users: [[String]] = []
    @State private var list_roles: [[String]] = []
    
    @State var showDeleteAlert = false
    @State var showDeleteThisUserAlert = false
    
    
    var body: some View {
        List(list_users.filter { item in
            if searchText.isEmpty { return true }
            return matchesSearchAssociation(item: item, searchText: searchText)}, id: \.self) { item in
            HStack{
               
                ZStack(alignment: .leading) {
                    Button(action: {
                        self.SelectedItem = item
                    }) {
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    
                    HStack {
                        Image(systemName: "person.circle")
                        Text("Пользователь: \(item[1]) \nРоль: \(list_roles.first(where: { $0[0] == item[2] })?[1] ?? "") ")
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(SelectedItem[0] == item[0] ? Color.blue.opacity(1) : Color.clear)
                    .cornerRadius(8)
                    .allowsHitTesting(false)
                }
                   
            }
            .padding(.horizontal, 4)
             .background(SelectedItem[0] == item[0] ? Color.blue : Color.clear)
        }
        .onAppear {
            if list_users.isEmpty {
                list_users = loadData("users", "SELECT id, login, id_role FROM users") as? [[String]] ?? []
            }
            if list_roles.isEmpty {
                list_roles = loadData("roles", "SELECT id, title FROM roles") as? [[String]] ?? []
            }
        }
        .onChange(of: needsRefresh) { newValue in
            if newValue {
                list_users = loadData("users", "SELECT id, login, id_role FROM users") as? [[String]] ?? []
                needsRefresh = false
            }
        }
        .sheet(isPresented: $showEditUser) {
            EditUserView(list_roles: list_roles, needsRefresh: $needsRefresh, SelectedItem: $SelectedItem, user: $user)
        }
        .alert("Удаление записи", isPresented: $showDeleteAlert) {
            Button("Удалить", role: .destructive) {
                if user!.login == SelectedItem[1]{
                    showDeleteThisUserAlert = true
                }
                else{
                    DeleteSelectedItem()
                }
                
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы уверены, что хотите удалить эту запись?")
        }
        .alert("Внимание! 🚨", isPresented: $showDeleteThisUserAlert) {
            Button("Удалить", role: .destructive) {
                DeleteSelectedItem()
                isAuthenticated = false
                
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы удаляете текущего пользователя. \n Подумайте несколько раз!")
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showEditUser = true
                } label: {
                    Image(systemName: "pencil")
                }
                .disabled(SelectedItem.contains(""))
            }
            ToolbarSpacer()
            ToolbarItem {
                Button {
                    showDeleteAlert = true // Показываем алерт
                } label: {
                    Image(systemName: "person.slash")
                }
                .disabled(SelectedItem.contains(""))
            }
        }
        .searchable(text: $searchText, placement: .toolbar)
        
    }
    
    func loadData(_ table_name: String, _ query: String) -> [[Any]]{
        let one_data_dict: [[String: Any]] = PostgreSQLManager().executeTableQuery(table_name, query) ?? []
        let one_data = one_data_dict.map { dict in
            Array(dict.sorted {
                // Извлекаем числа из "column_1", "column_2" и сравниваем как Int
                let num1 = Int($0.key.replacingOccurrences(of: "column_", with: "")) ?? 0
                let num2 = Int($1.key.replacingOccurrences(of: "column_", with: "")) ?? 0
                return num1 < num2
            }.map { $0.value })
        }
        print(one_data)
        return one_data
    }
    
    func matchesSearchAssociation(item: [String], searchText: String) -> Bool {
        let searchText = searchText.lowercased()
        let user_login = item[1].lowercased()
        let user_role = list_roles.first(where: { $0[0] == item[2] })?[1].lowercased() ?? ""
        if user_login.contains(searchText) || user_role.contains(searchText) {
            return true
        }

        return false
    }
    
    func DeleteSelectedItem(){
        let query = "DELETE FROM users WHERE id=\(SelectedItem[0])"
        if PostgreSQLManager().executeUpdate(query) {
           needsRefresh = true
        } else {
           print("Ошибка сохранения")
        }
    }
}

struct AdminView_Previews: PreviewProvider {
    @State static private var isAuthenticated = true
    @State static private var user: User? = User(login: "admin", password: "123", id_role: 1)
    
    static var previews: some View {
        AdminView(
            isAuthenticated: $isAuthenticated,
            user: $user
        )
    }
}
