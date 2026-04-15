import SwiftUI

struct AssociationView: View {
    var section: Int
    var menu = MenuItem().section
    var id_title_type: [Int] = MenuItem().id_title_type
    
    var table1Data: [[String]] //инфа для первой части
    var table2Data: [[String]] //инфа для второй части
    
    var table1Name: String
    var table2Name: String
    
    var table1Section: Int
    var table2Section: Int

    var table_names = MenuItem().names
    
    @Environment(\.dismiss) var dismiss

    @Binding var needsRefresh: Bool// ← для обновления данных в DetailView
    @Binding var SelectedItem: [String] // <- либо там ничего нет либо там есть данные для изменения
    @Binding var isEdited: Bool // изменение или добавление

    @State var showAlertUnique: Bool = false
    @State var showAlertMaxPart: Bool = false
    @State private var originalSelectedItem: [String] = []
    
    @State var Selected: String = ""
    
    
    var body: some View {
        VStack {
            BaseView(title: "\(isEdited ? "Редактирование" : "Добавление"): \(menu[section])", dismiss: dismiss,  onCancel: isEdited ? {
                resetToOriginal()
            } : nil)

            VStack {
                HStack{
                    Image(systemName: "square.and.pencil")
                    Picker(selection: $SelectedItem[1]) {
                        ForEach(table1Data, id: \.self) { item in
                            Text("\(PrintInfo(item: item, section: table1Section))").tag(item[0])
                        }
                    } label: {
                        Text("\(table1Name)")
                    }

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.vertical, 20)
                HStack{
                    Image(systemName: "square.and.pencil")
                    Picker(selection: $SelectedItem[2]) {
                        ForEach(table2Data, id: \.self) { item in
                            Text("\(PrintInfo(item: item, section: table2Section))").tag(item[0])
                        }
                    } label: {
                        Text("\(table2Name)")
                    }

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 15)
                Spacer()
                Button(action:{
                    saveData()
                }) {
                    HStack{
                        Image(systemName: "square.and.arrow.down")
                        Text("Сохранить")
                            .font(.title3)
                    }
                    .foregroundStyle(.green)
                }
                .disabled(SelectedItem[1] == "" || SelectedItem[2] == "")
                .buttonStyle(.glass)
                
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            .frame(width: 500, height: 200)
            .background(.black.opacity(0.1))
            .cornerRadius(20)
            .padding()
        }
        .onAppear {
            if isEdited {
                originalSelectedItem = SelectedItem
            }
        }
        .alert("Ошибка", isPresented: $showAlertUnique) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Запись с таким названием уже существует")
        }
        .alert("Ошибка", isPresented: $showAlertMaxPart) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Максимальное количество участников достигнуто")
        }
        .frame(width: 550, height: 300)
        .padding(20)
    }
    
    private func resetToOriginal() {
        SelectedItem = originalSelectedItem
        dismiss()
    }
    
    private func saveData() {
        let dbManager = PostgreSQLManager()
        let tableName = MenuItem().table_names[section] ?? ""
        let names_id = MenuItem().table_id_name[section] ?? [""]
        var query = ""
        
        let isParticipantsMC = (section == table_names["participants_master_classes"])
        
        var checkItems = dbManager.executeTableQuery("\(tableName)", "SELECT * FROM \(tableName) WHERE \(names_id[0])=\(SelectedItem[1]) AND \(names_id[1])=\(SelectedItem[2])") ?? []
        
        if !checkItems.isEmpty && (!isEdited || SelectedItem != originalSelectedItem) {
            showAlertUnique = true
            return
        }
        
        // Проверка максимального количества участников
        if isParticipantsMC {
            let mcItems = dbManager.executeTableQuery("\(tableName)", "SELECT * FROM \(tableName) WHERE \(names_id[1])=\(SelectedItem[2])") ?? []
            let max_part_mc = Int(dbManager.executeTableQuery("\(tableName)", "SELECT * FROM master_classes WHERE id=\(SelectedItem[2])")![0]["column_4"] as? String ?? "0") ?? 0
            
            if mcItems.count >= max_part_mc && (!isEdited || SelectedItem[1] == originalSelectedItem[1]) {
                showAlertMaxPart = true
                return
            }
        }
        
        if (isEdited == false){
            query = "INSERT INTO \(tableName) (\(names_id[0]), \(names_id[1])) VALUES (\(SelectedItem[1]), \(SelectedItem[2]))"
        } else {
            if (SelectedItem == originalSelectedItem){
                dismiss()
                return
            }
            query = "UPDATE \(tableName) SET \(names_id[0])=\(SelectedItem[1]), \(names_id[1])=\(SelectedItem[2]) WHERE id=\(SelectedItem[0])"
        }
        
        if dbManager.executeUpdate(query) {
            needsRefresh = true
            dismiss()
        } else {
            print("Ошибка сохранения")
        }
    }
    
    
    func PrintInfo(item:[String], section: Int) -> String{
        if (id_title_type.contains(section)){
            return "\(item[1])"
        }
        else if (section == table_names["teachers"]){ //teachers
            return "\(item[2]) \(item[1]) \(item[3])"
        }
        else if (section == table_names["master_classes"]){ //master-classes
            return "\(item[1])"
        }
        else if (section == table_names["participants"]){ //participants 4 3 5
            return "\(item[4]) \(item[3]) \(item[5])"
        }
        else if (section == table_names["volunteers"]){ //volunteers 5 4 6
            return "\(item[5]) \(item[4]) \(item[6])"
        }
        return ""
    }
}

struct AssociationView_Previews: PreviewProvider {
    @State static private var needsRefresh = false
    @State static private var selectedItem = ["", "1", "2"]
    @State static private var isEdited = false
    
    static var previews: some View {
        AssociationView(
            section: 23,
            table1Data: [["1", "Иван"], ["2", "Петр"]],
            table2Data: [["3", "Математика"], ["4", "Физика"]],
            table1Name: "Участник",
            table2Name: "Мастер-класс",
            table1Section: 14,
            table2Section: 13,
            needsRefresh: $needsRefresh,
            SelectedItem: $selectedItem,
            isEdited: $isEdited
        )
    }
}
