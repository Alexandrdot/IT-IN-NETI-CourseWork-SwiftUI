import SwiftUI

struct DetailView: View {
    var access: [[String: Any]] //для кнопок
    let title_section: String // общий тайтл
    
    @State private var searchText = ""
    @State var showDetailItem = false
    @State var showAssociationView = false
    @State var showGroupView = false
    @State var showTeacherView = false
    @State var showMasterClassView = false
    @State var showDeleteAlert = false
    @State var isEditing: Bool = false
    @State var showSimpleView = false
    @State private var needsRefresh = false
    @State var SelectedItem: [String] = [""]
    @State private var goodItem: [String] = []
    
    let section: Int //номер меню
    var table_names = MenuItem().table_names
    var table_names_reversed = MenuItem().names
    var reference_books = MenuItem().reference_books
    var menu_sections = MenuItem().section
    var id_id_table: [Int: [Int]] = MenuItem().table_id_id
    var id_title_type =  MenuItem().id_title_type
    var id_id_type: [Int] = Array(MenuItem().table_id_id.keys)
    
    //остались 6, 13, 14, 15, 23 <- отдельно нада рассмотреть
    
    @Binding var data: [Int: [Any]]
    
    var body: some View {

        List((data[section] as? [[String]] ?? []).filter { item in
            if searchText.isEmpty { return true }
            return matchesSearchAssociation(item: item, section: section, searchText: searchText)
            
        }, id: \.self) { item in
            HStack{
               
                    ZStack(alignment: .leading) {
                        // Основная кнопка на ВСЮ область
                        Button(action: {
                            self.SelectedItem = item
                            print("Selected item: \(item)")
                            // self.showSetSimpleView = true
                        }) {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            Image(systemName: "circle.fill")
                            
                            if (id_id_type.contains(section)){
                                let sect1 = id_id_table[section]![0]
                                let sect2 = id_id_table[section]![1]
                                
                                let table1Data = data[sect1] as! [[String]]
                                let table2Data = data[sect2] as! [[String]]
                                
                                let row1 = table1Data.first { $0[0] == item[1] }!
                                let row2 = table2Data.first { $0[0] == item[2] }!
                                
                                Text("\(menu_sections[sect1]): ")+Text(PrintInfo(item: row1, section: sect1))+Text("\n")+Text("\(menu_sections[sect2]): ")+Text(PrintInfo(item: row2, section: sect2))
                            }
                            else {
                                Text(PrintInfo(item: item, section: section))
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(SelectedItem[0] == item[0] ? Color.blue.opacity(1) : Color.clear)
                        .cornerRadius(8)
                        .allowsHitTesting(false) // ← ВАЖНО: пропускает нажатия сквозь контент к кнопке
                    }
                    if (!(id_title_type.contains(section) || id_id_type.contains(section) || section == 6)){
                        Button {
                            self.goodItem = GoodItem(item: item, section: section)
                            self.showDetailItem = true
                        } label: {
                            Image(systemName: "info.circle").symbolEffect(.pulse.byLayer, options: .repeat(.continuous))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
            }
            .padding(.horizontal, 4)
             .background(SelectedItem[0] == item[0] ? Color.blue : Color.clear)
        }
        .sheet(isPresented: $showDetailItem) {
            DetailItemView(item:$goodItem, section: section)  // Показываем модальное окно
        }

        .sheet(isPresented: $showSimpleView) {
            SimpleView(section: section, needsRefresh: $needsRefresh, SelectedItem: $SelectedItem, isEdited: $isEditing)  // Показываем модальное окно
        }
        .sheet(isPresented: $showTeacherView) {
            
            TeacherView(section: section, needsRefresh: $needsRefresh, SelectedItem: $SelectedItem, isEdited: $isEditing)  // Показываем модальное окно
        }
        .sheet(isPresented: $showMasterClassView) {
            
            MasterClassView(section: section, needsRefresh: $needsRefresh, SelectedItem: $SelectedItem, isEdited: $isEditing)  // Показываем модальное окно
        }
        .sheet(isPresented: $showAssociationView) {
            let sect1 = id_id_table[section]![0]
            let sect2 = id_id_table[section]![1]
            
            let table1Data = data[sect1] as! [[String]] // таблицы точно есть, так как они подгрузились когда открыли окно
            let table2Data = data[sect2] as! [[String]]
            
            let table1Name = menu_sections[sect1]
            let table2Name = menu_sections[sect2]
            
            AssociationView(
                section: section,
                table1Data: table1Data,
                table2Data: table2Data,
                table1Name: table1Name,
                table2Name: table2Name,
                table1Section: sect1,
                table2Section: sect2,
                needsRefresh: $needsRefresh,
                SelectedItem: $SelectedItem,
                isEdited: $isEditing
            )
        }
        
        .sheet(isPresented: $showGroupView) {
            var mutableData = data // создаем копию
            let result = PrepareDataForGrup(section: section, data: &mutableData)
            let messages = result[0] as? [String] ?? []
            let tabledData = result[1] as? [[[String]]] ?? []
            //print(tabledData)
            let tabledName = result[2] as? [String] ?? []
            let tabledSection = result[3] as? [Int] ?? []
            if section == 14{
                ParticipantView(
                    section: section,
                    messages: messages,
                    tabledData: tabledData,
                    tabledName: tabledName,
                    tabledSection: tabledSection,
                    needsRefresh: $needsRefresh,
                    SelectedItem: $SelectedItem,
                    isEdited: $isEditing
                    
                )
            }
            else{
                VolunteerView(
                    section: section,
                    messages: messages,
                    tabledData: tabledData,
                    tabledName: tabledName,
                    tabledSection: tabledSection,
                    needsRefresh: $needsRefresh,
                    SelectedItem: $SelectedItem,
                    isEdited: $isEditing
                )
            }
            
       }
        .alert("Удаление записи", isPresented: $showDeleteAlert) {
            Button("Удалить", role: .destructive) {
                DeleteSelectedItem()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы уверены, что хотите удалить эту запись? Это действие приведет к утере всех данных, связанных с ней.")
        }
        
        .navigationTitle("\(title_section)")
        .toolbar {
            ToolbarItem {
                Button {
                    self.isEditing = false
                    // действие -> модальное окно
                    if (id_title_type.contains(section)){
                        SelectedItem = ["", "", ""]
                        self.showSimpleView = true
                    }
                    if (id_id_type.contains(section)){
                        SelectedItem = ["", "", ""]
                        self.showAssociationView = true
                    }
                    if (section == table_names_reversed["participants"]! || section == table_names_reversed["volunteers"]!){
                        if (section == table_names_reversed["participants"]!){
                            SelectedItem = Array(repeating: "", count: 13) //14 - part
                        }
                        else{
                            SelectedItem = Array(repeating: "", count: 8)
                        }
                        self.showGroupView = true
                    }
                    
                    if (section == table_names_reversed["teachers"]!){
                        SelectedItem = Array(repeating: "", count: 4)
                        self.showTeacherView = true
                    }
                    if (section == table_names_reversed["master_classes"]!){
                        SelectedItem = Array(repeating: "", count: 7)
                        self.showMasterClassView = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            .hidden(!AccessManager.isAccessForAction(action: "w", access: access, id_menu: section+1))
            
            ToolbarItem {
                Button {
                    self.isEditing = true

                    if (id_title_type.contains(section)){
                        self.showSimpleView = true
                    }
                    if (id_id_type.contains(section)){
                        self.showAssociationView = true
                    }
                    if (section == table_names_reversed["participants"]! || section == table_names_reversed["volunteers"]!){
                        self.showGroupView = true
                    }
                    if (section == table_names_reversed["teachers"]!){
                        self.showTeacherView = true
                    }
                    if (section == table_names_reversed["master_classes"]!){
                        self.showMasterClassView = true
                    }
                } label: {
                    Image(systemName: "pencil")
                }
                .disabled(SelectedItem[0] == "")
            }
            
            .hidden(!AccessManager.isAccessForAction(action: "e", access: access, id_menu: section+1))
            
            ToolbarSpacer()
            ToolbarItem {
                Button {
                    showDeleteAlert = true // Показываем алерт
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(SelectedItem[0] == "")
            }
            .hidden(!AccessManager.isAccessForAction(action: "d", access: access, id_menu: section+1))
            ToolbarSpacer()
        }

        .searchable(text: $searchText, placement: .toolbar)
        .onAppear {
            if data[section] == nil {
                
                data[section] = loadData(section: section)
                
                if id_id_type.contains(section){
                    //print(data[id_id_table[section]![0]])
                    if (data[id_id_table[section]![0]] == nil){
                        data[id_id_table[section]![0]] = loadData(section: id_id_table[section]![0])
                        
                    }
                    if (data[id_id_table[section]![1]] == nil){
                        data[id_id_table[section]![1]] = loadData(section: id_id_table[section]![1])
                    }
                }
                
                //print(one_data_dict)
                print("-------")
                print("-------")
                print("-------")
                //print(one_data)
            }
        }
        .onChange(of: section) {
            self.SelectedItem = [""]
            if data[section] == nil {
                //разложили список списков словарей на список списков Any
                data[section] = loadData(section: section)
                //print(one_data_dict)
                if id_id_type.contains(section) {
                    if (data[id_id_table[section]![0]] == nil){
                        data[id_id_table[section]![0]] = loadData(section: id_id_table[section]![0])
                        
                    }
                    if (data[id_id_table[section]![1]] == nil){
                        data[id_id_table[section]![1]] = loadData(section: id_id_table[section]![1])
                    }
                }
            }

        }
        .onChange(of: needsRefresh) { newValue in
                   if newValue {
                       data[section] = loadData(section: section)
                       needsRefresh = false
                   }
               }
        
    }
    func loadData(section: Int) -> [[Any]]{
        let one_data_dict: [[String: Any]] = PostgreSQLManager().executeTableQuery( table_names[section] ?? "") ?? []
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
    
    func PrepareDataForGrup(section: Int, data: inout [Int: [Any]]) -> [Any] {
        //тут надо подгрузить данные из связанных таблиц если в дате их нет, собрать в список их и их имена и секции и отправить
        print(1)
        let tabledSect: [Int] = (section == 14) ? [11, 12] : [7, 8, 9]
        let sect_menu = MenuItem().sections
        print(2)
        var tabledName: [String] = [sect_menu[tabledSect[0]], sect_menu[tabledSect[1]]]
        if (section != 14) {
            tabledName.append(sect_menu[tabledSect[2]])
        }
        print(3)
        var tabledData: [ [ [String] ] ] = []
        
        
            if (data[tabledSect[0]] == nil){
                data[tabledSect[0]] = loadData(section: tabledSect[0])
            }
            if (data[tabledSect[1]] == nil){
                data[tabledSect[1]] = loadData(section: tabledSect[1])
            }
//            print("-----")
//            print(data[tabledSect[0]])
//            print("-----")
            tabledData.append(data[tabledSect[0]] as! [[String]])
            tabledData.append(data[tabledSect[1]] as! [[String]])
            print(5)
        
        
        if (section == 15) {
            print(6)
            if (data[tabledSect[2]] == nil){
                data[tabledSect[2]] = loadData(section: tabledSect[2])
            }
            print(7)
            tabledData.append(data[tabledSect[2]] as! [[String]])
            print(8)
        }
        print(tabledData)
        return [Messages().messages[section] ?? [], tabledData, tabledName, tabledSect]
    }
    
    func PrintInfo(item:[String], section: Int) -> String{
        if (id_title_type.contains(section)){
            return "\(item[1])"
        }
        else if (section == 6){ //teachers
            return "\(item[2]) \(item[1]) \(item[3])"
        }
        else if (section == 13){ //master-classes
            return "\(item[1])"
        }
        else if (section == 14){ //participants 4 3 5
            return "\(item[4]) \(item[3]) \(item[5])"
        }
        else if (section == 15){ //volunteers 5 4 6
            return "\(item[5]) \(item[4]) \(item[6])"
        }

        return ""
    }
    
    func GoodItem(item:[String], section: Int) -> [String]{
        var good_item: [String] = []
        
        if section == 14{ //participants
            var name_city: String = ""
            var name_insitut: String = ""
            if (data[11] == nil){
                let city = PostgreSQLManager().executeTableQuery( table_names[11] ?? "", "SELECT title FROM \(table_names[11] ?? "") WHERE id=\(item[1])")?[0] ?? [:] //запись город
                name_city = city["column_0"] as? String ?? "Неизвестно" // название города
            }
            else{
                let cities = data[11] as? [[String]] ?? []
                name_city = cities.first { $0[0] == item[1] }?[1] ?? "Неизвестно"
            }
            
            if (data[12] == nil){
                let insitut = PostgreSQLManager().executeTableQuery( table_names[12] ?? "", "SELECT title FROM \(table_names[12] ?? "") WHERE id=\(item[2])")?[0] ?? [:] //запись института
                name_insitut = insitut["column_0"]  as? String ?? "Неизвестно" // название института
            }
            
            else{
                let insitus = data[12] as? [[String]] ?? []
                name_insitut = insitus.first { $0[0] == item[2] }?[1] ?? "Неизвестно"
            }
            
            for i in 3..<item.count{
                good_item.append(item[i])
            }
            good_item.append(name_city)
            good_item.append(name_insitut)
        }
        else if (section == 13){
            for i in 1..<item.count{
                good_item.append(item[i])
            }
        }
        else {
            var name_faculty: String = ""
            var name_group: String = ""
            var name_spec: String = ""
            
            if (data[9] == nil){
                let faculty = PostgreSQLManager().executeTableQuery( table_names[9] ?? "", "SELECT title FROM \(table_names[9] ?? "") WHERE id=\(item[3])")?[0] ?? [:] //запись город
                name_faculty = faculty["column_0"] as? String ?? "Неизвестно" // название города
            }
            else{
                let faculty = data[9] as? [[String]] ?? []
                name_faculty = faculty.first { $0[0] == item[3] }?[1] ?? "Неизвестно"
            }
            
            if (data[7] == nil){
                let group = PostgreSQLManager().executeTableQuery( table_names[7] ?? "", "SELECT title FROM \(table_names[7] ?? "") WHERE id=\(item[1])")?[0] ?? [:] //запись института
                name_group = group["column_0"]  as? String ?? "Неизвестно" // название института
            }
            
            else{
                let group = data[7] as? [[String]] ?? []
                name_group = group.first { $0[0] == item[1] }?[1] ?? "Неизвестно"
            }
            
            if (data[8] == nil){
                let spec = PostgreSQLManager().executeTableQuery( table_names[8] ?? "", "SELECT title FROM \(table_names[8] ?? "") WHERE id=\(item[2])")?[0] ?? [:] //запись института
                name_spec = spec["column_0"]  as? String ?? "Неизвестно" // название института
            }
            
            else{
                let insitus = data[8] as? [[String]] ?? []
                name_spec = insitus.first { $0[0] == item[2] }?[1] ?? "Неизвестно"
            }
            
            for i in 4..<item.count{
                good_item.append(item[i])
            }
            good_item.append(name_group)
            good_item.append(name_spec)
            good_item.append(name_faculty)
        }
        
        return good_item
    }
    
    func DeleteSelectedItem(){
        let tableName = MenuItem().table_names[section] ?? ""
        let query = "DELETE FROM \(tableName) WHERE id=\(SelectedItem[0])"
        if PostgreSQLManager().executeUpdate(query) {
           needsRefresh = true
            SelectedItem = [""]
        } else {
           print("Ошибка сохранения")
        }
        if reference_books.keys.contains(section){
            let need_update_section = reference_books[section] ?? []
            
            for sect in need_update_section{
                data[sect] = loadData(section: sect)
            }
        }
    }
    
    func matchesSearchAssociation(item: [String], section: Int, searchText: String) -> Bool {
        let searchText = searchText.lowercased()
        if (id_id_type.contains(section)){
            let sect1 = id_id_table[section]![0]
            let sect2 = id_id_table[section]![1]
            
            let table1Data = data[sect1] as! [[String]]
            let table2Data = data[sect2] as! [[String]]
            
            let row1 = table1Data.first { $0[0] == item[1] }!
            let row2 = table2Data.first { $0[0] == item[2] }!
            
            //сейчас у меня есть два обьекта верх и низ
            let search1text = PrintInfo(item: row1, section: sect1).lowercased()
            let search2text = PrintInfo(item: row2, section: sect2).lowercased()
            
            if search1text.contains(searchText) || search2text.contains(searchText){
                return true
            }
            
        }
        let search1text = PrintInfo(item: item, section: section).lowercased()
        if search1text.contains(searchText){
            return true
        }
        return false
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var access = AccessManager.GetAccess(user: User(login: "123", password: "123", id_role: 5))
//    
//    static var previews: some View {
//        DetailView(access: access, title_section: "ede", section: 1)
//    }
//}
