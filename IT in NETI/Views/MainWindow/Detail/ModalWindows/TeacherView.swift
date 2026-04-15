import SwiftUI

struct TeacherView: View {
    var section: Int
    var menu = MenuItem().section
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var needsRefresh: Bool// ← для обновления данных в DetailView
    @Binding var SelectedItem: [String] // <- либо там ничего нет либо там есть данные для изменения
    @Binding var isEdited: Bool // изменение или добавление
    
    @State private var originalSelectedItem: [String] = []
    @State var showAlert: Bool = false
    @State var showAlertMaxChar: Bool = false
    
    var body: some View {
        VStack {
            BaseView(title: "\(isEdited ? "Редактирование" : "Добавление"): \(menu[section])", dismiss: dismiss,  onCancel: isEdited ? {
                resetToOriginal()
            } : nil)
            VStack {
                VStack(spacing: 20){
                    HStack{
                        Image(systemName: "square.and.pencil")
                        TextField("Введите имя", text: $SelectedItem[1])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack{
                        Image(systemName: "square.and.pencil")
                        TextField("Введите фамилию", text: $SelectedItem[2])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack{
                        Image(systemName: "square.and.pencil")
                        TextField("Введите отчество", text: $SelectedItem[3])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
                
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
                .disabled(SelectedItem[1].isEmpty || SelectedItem[2].isEmpty)
                
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
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Заполните поля 'имя' и 'фамилия'" )
        }
        .alert("Ошибка", isPresented: $showAlertMaxChar) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ошибка сохранения! Проверьте количество символов!")
        }
        .frame(width: 550, height: 300)
        .padding(20)
    }
    private func saveData() {
        let dbManager = PostgreSQLManager()
        let tableName = MenuItem().table_names[section] ?? ""
        
        // Экранируем текстовые поля
        let safeFirstName = dbManager.escapeSQL(SelectedItem[1])
        let safeLastName = dbManager.escapeSQL(SelectedItem[2])
        let safePatronymic = dbManager.escapeSQL(SelectedItem[3])
        let safeId = dbManager.escapeSQL(SelectedItem[0])
        
        let cleanedFirstName = safeFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedLastName = safeLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedFirstName.isEmpty || cleanedLastName.isEmpty {
            showAlert = true
            return
        }
        
        var query = ""
        
        if !isEdited {
            query = "INSERT INTO \(tableName) (first_name, last_name, patronymic) VALUES ('\(cleanedFirstName)', '\(cleanedLastName)', '\(safePatronymic)')"
        } else {
            if SelectedItem == originalSelectedItem {
                dismiss()
                return
            }
            query = "UPDATE \(tableName) SET first_name='\(cleanedFirstName)', last_name='\(cleanedLastName)', patronymic='\(safePatronymic)' WHERE id=\(safeId)"
        }
        
        if dbManager.executeUpdate(query) {
            needsRefresh = true
            dismiss()
        } else {
            showAlertMaxChar = true
            print("Ошибка сохранения")
        }
    }
    private func resetToOriginal() {
        SelectedItem = originalSelectedItem
        dismiss()
    }
}

struct TeacherView_Previews: PreviewProvider {
    @State static private var needsRefresh = false
    @State static private var selectedItem = ["", "Имя", "Фамилия", "Отчество"]
    @State static private var isEdited = false
    
    static var previews: some View {
        TeacherView(
            section: 5,
            needsRefresh: $needsRefresh,
            SelectedItem: $selectedItem,
            isEdited: $isEdited
        )
    }
}
