import SwiftUI

struct SimpleView: View {
    var section: Int
    var menu = MenuItem().section
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var needsRefresh: Bool// ← для обновления данных в DetailView
    @Binding var SelectedItem: [String] // <- либо там ничего нет либо там есть данные для изменения [id title]
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
                HStack{
                    Image(systemName: "square.and.pencil")
                    TextField("Введите название", text: $SelectedItem[1])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                .disabled(SelectedItem[1].isEmpty)
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
            Text("Запись с таким названием уже существует")
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
        
        let safeTitle = dbManager.escapeSQL(SelectedItem[1])
        let safeId = dbManager.escapeSQL(SelectedItem[0])
        
        let cleanedTitle = safeTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if SelectedItem[1].isEmpty || cleanedTitle.isEmpty {
            return
        }
        
        if !isEdited || (isEdited && SelectedItem[1] != originalSelectedItem[1]) {
            let items = dbManager.executeTableQuery(tableName, "SELECT * FROM \(tableName) WHERE title='\(cleanedTitle)'") ?? []
            if !items.isEmpty {
                showAlert = true
                return
            }
        }
        
        var query = ""
        
        if !isEdited {
            query = "INSERT INTO \(tableName) (title) VALUES ('\(cleanedTitle)')"
        } else {
            if SelectedItem == originalSelectedItem {
                dismiss()
                return
            }
            query = "UPDATE \(tableName) SET title='\(cleanedTitle)' WHERE id=\(safeId)"
        }
        
        if dbManager.executeUpdate(query) {
            SelectedItem[1] = cleanedTitle
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

struct SimpleView_Previews: PreviewProvider {
    @State static private var needsRefresh = false
    @State static private var selectedItem = ["", "Название"]
    @State static private var isEdited = false
    
    static var previews: some View {
        SimpleView(
            section: 5,
            needsRefresh: $needsRefresh,
            SelectedItem: $selectedItem,
            isEdited: $isEdited
        )
    }
}
