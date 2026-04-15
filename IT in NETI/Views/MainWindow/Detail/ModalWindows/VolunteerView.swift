import SwiftUI

struct VolunteerView: View {
    var section: Int
    var menu = MenuItem().section
    
    var messages: [String] // названия полей для ввода
    var tabledData: [[[String]]] //инфа для выбора
    var tabledName: [String]
    
    var tabledSection: [Int]
    
    var id_title_type =  [2, 3, 4, 5, 7, 8, 9, 10, 11, 12]
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var needsRefresh: Bool// ← для обновления данных в DetailView
    @Binding var SelectedItem: [String] // <- либо там ничего нет либо там есть данные для изменения
    @Binding var isEdited: Bool // изменение или добавление
    
    @State private var originalSelectedItem: [String] = []
    @State private var showAlertField: Bool = false
    @State var showAlertMaxChar: Bool = false
    
    // id     id_group     id_specialty       id_faculty      f_name      l_name      patron     course
    //  0         1            2                    3            4           5           6          7

    var body: some View {
        VStack {
            BaseView(title: "\(isEdited ? "Редактирование" : "Добавление"): \(menu[section])", dismiss: dismiss,  onCancel: isEdited ? {
                resetToOriginal()
            } : nil)
            ScrollView {
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите имя", text: $SelectedItem[4])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите фамилию", text: $SelectedItem[5])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите отчество", text: $SelectedItem[6])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    Picker(selection: $SelectedItem[7]) {
                        ForEach(["1", "2" ,"3" ,"4" ,"5", "6", "7", "8"], id: \.self) { item in
                            Text("\(item)").tag(item)
                        }
                    } label: {
                        Text("Курс обучения")
                    }
                    .pickerStyle(MenuPickerStyle()) // ← добавь это
                    .id("course_picker_\(SelectedItem[7])") // ← и это
                }
                .inputFieldStyle()
                
                ForEach(Array(messages.dropFirst(messages.count - tabledName.count).enumerated()), id: \.offset) { index, message in
                    HStack{
                        Image(systemName: "square.and.pencil")
                        Picker(selection: $SelectedItem[index+1]) {
                            ForEach(tabledData[index], id: \.self) { item in
                                Text("\(item[1])").tag(item[0])
                            }
                        } label: {
                            Text("\(tabledName[index])")
                        }
                    }
                    .inputFieldStyle()
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            .frame(width: 500, height: 250)
            .background(.black.opacity(0.1))
            .cornerRadius(20)
            .padding()
            
            VStack {
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
                .buttonStyle(.glass)
                .disabled(SelectedItem.enumerated()
                    .filter { $0.offset != 0 && $0.offset != 6 }
                    .contains { $0.element == "" })
            }
        }
        .onAppear {
            if isEdited {
                originalSelectedItem = SelectedItem
            }
        }
        .alert("Ошибка", isPresented: $showAlertField) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Заполните все поля!")
        }
        .alert("Ошибка", isPresented: $showAlertMaxChar) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ошибка сохранения! Проверьте количество символов!")
        }
        .frame(width: 550, height: 400)
        .padding(20)
    }
    
    private func saveData() {
        let dbManager = PostgreSQLManager()
        let tableName = MenuItem().table_names[section] ?? ""
        
        let safeFirstName = dbManager.escapeSQL(SelectedItem[4])
        let safeLastName = dbManager.escapeSQL(SelectedItem[5])
        let safePatronymic = dbManager.escapeSQL(SelectedItem[6])
        let safeId = dbManager.escapeSQL(SelectedItem[0])
        
        let cleanedFirstName = safeFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedLastName = safeLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedFirstName.isEmpty || cleanedLastName.isEmpty {
            showAlertField = true
            return
        }
        
        var query = ""

        if !isEdited {
            query = "INSERT INTO \(tableName) (first_name, last_name, patronymic, course, id_group, id_specialty, id_faculty) VALUES ('\(cleanedFirstName)', '\(cleanedLastName)', '\(safePatronymic)', '\(SelectedItem[7])', \(SelectedItem[2]), \(SelectedItem[3]), \(SelectedItem[1]))"
        } else {
            if SelectedItem == originalSelectedItem {
                dismiss()
                return
            }
            
            query = "UPDATE \(tableName) SET first_name='\(cleanedFirstName)', last_name='\(cleanedLastName)', patronymic='\(safePatronymic)', course='\(SelectedItem[7])', id_group=\(SelectedItem[2]), id_specialty=\(SelectedItem[3]), id_faculty=\(SelectedItem[1]) WHERE id=\(safeId)"
        }
        
        if dbManager.executeUpdate(query) {
            needsRefresh = true
            dismiss()
        } else {
            showAlertMaxChar = true
            print("Ошибка сохранения")
        }
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
    
    
    private func resetToOriginal() {
        SelectedItem = originalSelectedItem
        dismiss()
    }
}
