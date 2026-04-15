import SwiftUI


struct MainWindowView: View{
    
    @Binding var isAuthenticated: Bool
    @Binding var user: User?
    @State private var selectedItem: Int? = nil
    @State var data: [Int: [Any]] = [:]
    @State private var expandedGroups: [Bool] = Array(repeating: false, count: 7)
    @State private var access: [[String : Any]] = []
    
    var menu: MenuItem = MenuItem()
    
    var body: some View{
        /*
            Главное окно приложения, отображаем пункты меню, если есть доступ к ним
            Передаем в функцию id_menu = section+1 из-за того, что в базе данных PK начинается с 1
         */
        
        NavigationSplitView {
            List(selection: $selectedItem) {
        
                DisclosureGroup(isExpanded: $expandedGroups[0]) {
                    if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 1)){
                        NavigationLink("Содержание", value: 0)
                    }
                    if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 2)){
                        NavigationLink("О Программе", value: 1)
                    }
                } label: {
                    Label("Справка", systemImage: "info.circle")
                }

                if shouldShowGroup(menuIds: Array(3...14)) {
                    DisclosureGroup(isExpanded: $expandedGroups[1]) {
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 3)){
                            NavigationLink("Места работы", value: 2)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 4)){
                            NavigationLink("Должности", value: 3)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 5)){
                            NavigationLink("Ученые степени", value: 4)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 6)){
                            NavigationLink("Ученые звания", value: 5)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 7)){
                            NavigationLink("Преподаватели", value: 6)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 8)){
                            NavigationLink("Группы", value: 7)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 9)){
                            NavigationLink("Специальности", value: 8)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 10)){
                            NavigationLink("Факультеты", value: 9)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 11)){
                            NavigationLink("Призы", value: 10)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 12)){
                            NavigationLink("Города", value: 11)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 13)){
                            NavigationLink("Уч. Заведения", value: 12)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 14)){
                            NavigationLink("Мастер классы", value: 13)
                        }
                        
                    } label: {
                        Label("Справочники", systemImage: "document.on.document")
                    }
                }
                if shouldShowGroup(menuIds: [15, 16]) {
                    DisclosureGroup(isExpanded: $expandedGroups[2]) {
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 15)){
                            NavigationLink("Участники", value: 14)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 16)){
                            NavigationLink("Волонтеры", value: 15)
                        }
                    } label: {
                        Label("Группы", systemImage: "person.2")
                    }
                }
                if shouldShowGroup(menuIds: Array(17...24)) {
                    DisclosureGroup(isExpanded: $expandedGroups[3]) {
                        
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 17)){
                            NavigationLink("Места работы преподавателя", value: 16)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 18)){
                            NavigationLink("Должности преподавателя", value: 17)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 19)){
                            NavigationLink("Ученые степени преподавателя", value: 18)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 20)){
                            NavigationLink("Ученые звания преподавателя", value: 19)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 21)){
                            NavigationLink("Преподаватели на мастер классах", value: 20)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 22)){
                            NavigationLink("Волонтеры на мастер классах", value: 21)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 23)){
                            NavigationLink("Призы участника", value: 22)
                        }
                        if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 24)){
                            NavigationLink("Участники на мастер классах", value: 23)
                        }
                        
                    } label: {
                        Label("Ассоциации", systemImage: "icloud")
                    }
                }
                
                DisclosureGroup(isExpanded: $expandedGroups[4]) {
                    if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 25)){
                        NavigationLink("Экспорт данных", value: 24)
                    }
                } label: {
                    Label("Документы", systemImage: "square.and.arrow.up.on.square")
                }
                
                DisclosureGroup(isExpanded: $expandedGroups[5]) {
                    if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 26)){
                        NavigationLink("Настройка", value: 25)
                    }
                    if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 27)){
                        NavigationLink("Смена пароля", value: 26)
                    }
                    if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 28)){
                        NavigationLink("Админ-зона", value: 27)
                    }
                } label: {
                    Label("Разное", systemImage: "bookmark.circle")
                }
                
                DisclosureGroup(isExpanded: $expandedGroups[6]) {
                   // if (AccessManager.isAccessForAction(action: "r", access: access, id_menu: 26)){
                    NavigationLink("Диаграмма данных", value: 28)
                    NavigationLink("Диаграмма изменений", value: 29)
                    NavigationLink("Диаграмма записей на мастер-классы", value: 30)

                } label: {
                    Label("Аналитика", systemImage: "graph.2d")
                }
            }
            .navigationSplitViewColumnWidth(ideal: 150, max: 300)

            .onAppear{
                access = AccessManager.GetAccess(user: user!)
            }
            .listStyle(.sidebar)
            .navigationTitle("Finder")
            VStack {
                HStack {
                    Image(systemName: "person.circle")
                        .foregroundColor(.secondary)
                    Text("\(user?.login ?? "Гость")")
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(5)
                .background(
                    Capsule()
                        .fill(Color.primary.opacity(0.05))
                        .glassEffect()
                )
            }
            .padding(7)
        }
        
        detail: {
            // Правая панель - содержимое
            Group {
                if let selectedItem = selectedItem {
                    switch selectedItem {
                    case 0:
                        InformationView()
                        //HappyView()
                    case 1:
                        AboutView()
                    case 24:
                        DocumentView(user: user!)
                    case 25:
                        SettingsView()
                    case 26:
                        SetPasswordView(user: $user)
                    case 27:
                        AdminView(isAuthenticated: $isAuthenticated, user: $user)
                    case 28, 29, 30:
                        //HappyView()
                        AnalyticsView(section: selectedItem)
                    default:
                        DetailView(access: access, title_section: menu.sections[selectedItem], section: selectedItem, data: $data)
                    }
                } else {
                    WelcomeView()
                }
            }
            .navigationTitle(selectedItem.flatMap { menu.sections[$0] } ?? "")
        }
        .navigationSplitViewStyle(.balanced)
        //.navigationSplitViewColumnWidth(.max: 200)
    }
    
    private func shouldShowGroup(menuIds: [Int]) -> Bool {
        for menuId in menuIds {
            if AccessManager.isAccessForAction(action: "r", access: access, id_menu: menuId) {
                return true
            }
        }
        return false
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView(
            isAuthenticated: .constant(true),
            user: .constant(User(login: "testuser", password: "testpass", id_role: 1))
        )
    }
}
