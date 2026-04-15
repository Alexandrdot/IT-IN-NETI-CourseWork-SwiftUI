
import SwiftUI

struct ParticipantView: View {
    var section: Int
    var menu = MenuItem().section
    var id_title_type: [Int] = MenuItem().id_title_type
    
    var messages: [String] // названия полей для ввода
    var tabledData: [[[String]]] //инфа для выбора
    var tabledName: [String]
    var tabledSection: [Int]
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var needsRefresh: Bool// ← для обновления данных в DetailView
    @Binding var SelectedItem: [String] // <- либо там ничего нет либо там есть данные для изменения
    @Binding var isEdited: Bool // изменение или добавление
    
    // id   id_city  id_institut  f_name  l_name   patron   train_class   part_format   email   phone   link_copy   test_res   certificate
    //  0     1             2       3        4        5          6            7          8        9         10         11          12
    
    @State private var originalSelectedItem: [String] = []
    @State private var test_result: Double = 0.0
    @State private var showAlertField: Bool = false
    @State private var showAlertUnique: Bool = false
    @State var showAlertMaxChar: Bool = false

    var body: some View {
        VStack {
            BaseView(title: "\(isEdited ? "Редактирование" : "Добавление"): \(menu[section])", dismiss: dismiss,  onCancel: isEdited ? {
                resetToOriginal()
            } : nil)
            ScrollView {
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите имя", text: $SelectedItem[3])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите фамилию", text: $SelectedItem[4])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите отчество", text: $SelectedItem[5])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    Picker(selection: $SelectedItem[6]) {
                        ForEach(["1", "2" ,"3" ,"4" ,"5", "6", "7", "8", "9", "10", "11"], id: \.self) { item in
                            Text("\(item)").tag(item)
                        }
                    } label: {
                        Text("Класс обучения")
                    }
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    Picker(selection: $SelectedItem[7]) {
                        ForEach(["очный", "онлайн"], id: \.self) { item in
                            Text("\(item)").tag(item)
                        }
                    } label: {
                        Text("Формат обучения")
                    }
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите почту", text: $SelectedItem[8])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите телефон", text: $SelectedItem[9])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите ссылку на согласие", text: $SelectedItem[10])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    Text("Результат диктанта: \(Int(test_result))")
                    Slider(
                        value: $test_result,
                        in: 0...100,
                        step: 1
                    )
                    .onAppear {
                        test_result = Double(SelectedItem[11]) ?? 1
                    }
                    .onChange(of: test_result) { newValue in
                        SelectedItem[11] = String(Int(newValue))
                    }
                    .glassEffect()
                    .tint(test_result > 75 ? .green : (test_result > 50 ? .orange : .red))
                }
                .inputFieldStyle()
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите ссылку на сертификат", text: $SelectedItem[12])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
            .frame(width: 500, height: 300)
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
                //.disabled(SelectedItem.contains(""))       .......edit this........
                
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
        .alert("Ошибка", isPresented: $showAlertUnique) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Запись с таким телефоном или почтой уже существует")
        }
        .alert("Ошибка", isPresented: $showAlertMaxChar) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ошибка сохранения! Проверьте количество символов!")
        }
        
        .frame(width: 550, height: 450)
        .padding(20)
    }
    
    private func saveData() {
        let dbManager = PostgreSQLManager()
        let tableName = MenuItem().table_names[section] ?? ""
        
        // Экранируем текстовые поля
        let safeFirstName = dbManager.escapeSQL(SelectedItem[3])
        let safeLastName = dbManager.escapeSQL(SelectedItem[4])
        let safePatronymic = dbManager.escapeSQL(SelectedItem[5])
        let safeEmail = dbManager.escapeSQL(SelectedItem[8])
        let safePhone = dbManager.escapeSQL(SelectedItem[9])
        let safeCopy = dbManager.escapeSQL(SelectedItem[10])
        let safeCertificate = dbManager.escapeSQL(SelectedItem[12])
        let safeId = dbManager.escapeSQL(SelectedItem[0])
        
        let cleanedFirstName = safeFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedLastName = safeLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = safeEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPhone = safePhone.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedCopy = safeCopy.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if [cleanedFirstName, cleanedLastName, cleanedEmail, cleanedPhone, cleanedCopy].contains("") {
            showAlertField = true
            return
        }
        if !isEdited {
            let items = dbManager.executeTableQuery(tableName, "SELECT * FROM \(tableName) WHERE phone='\(cleanedPhone)' or email='\(cleanedEmail)'") ?? []
            if !items.isEmpty {
                showAlertUnique = true
                return
            }
        } else {
            if cleanedPhone != originalSelectedItem[9] {
                let items = dbManager.executeTableQuery(tableName, "SELECT * FROM \(tableName) WHERE phone='\(cleanedPhone)'") ?? []
                if !items.isEmpty {
                    showAlertUnique = true
                    return
                }
            }
            
            if cleanedEmail != originalSelectedItem[8] {
                let items = dbManager.executeTableQuery(tableName, "SELECT * FROM \(tableName) WHERE email='\(cleanedEmail)'") ?? []
                if !items.isEmpty {
                    showAlertUnique = true
                    return
                }
            }
        }
        
        var query = ""
        
        if !isEdited {
            query = "INSERT INTO \(tableName) (first_name, last_name, patronymic, email, phone, link_copy_consent, certificate, training_class, participation_format, test_result, id_city, id_edu_institut) VALUES ('\(cleanedFirstName)', '\(cleanedLastName)', '\(safePatronymic)', '\(cleanedEmail)', '\(cleanedPhone)', '\(cleanedCopy)','\(safeCertificate)', '\(SelectedItem[6])', '\(SelectedItem[7])', '\(Int(SelectedItem[11])!)', \(SelectedItem[1]), \(SelectedItem[2]))"
        } else {
            if SelectedItem == originalSelectedItem {
                dismiss()
                return
            }
            query = "UPDATE \(tableName) SET first_name='\(cleanedFirstName)', last_name='\(cleanedLastName)', patronymic='\(safePatronymic)', email='\(cleanedEmail)', phone='\(cleanedPhone)', link_copy_consent='\(cleanedCopy)', certificate='\(safeCertificate)', training_class='\(SelectedItem[6])', participation_format='\(SelectedItem[7])', test_result='\(Int(SelectedItem[11])!)', id_city=\(SelectedItem[1]), id_edu_institut=\(SelectedItem[2]) WHERE id=\(safeId)"
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
