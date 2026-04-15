import SwiftUI

struct MasterClassView: View {
    var section: Int
    var menu = MenuItem().section
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var needsRefresh: Bool// ← для обновления данных в DetailView
    @Binding var SelectedItem: [String] // <- либо там ничего нет либо там есть данные для изменения
    @Binding var isEdited: Bool // изменение или добавление
   
    @State private var originalSelectedItem: [String] = []
    @State private var capacity: Double = 1
    @State private var showAlertMaxPart: Bool = false
    @State private var showAlertField: Bool = false
    @State private var showAlertUnique: Bool = false
    @State var showAlertMaxChar: Bool = false
    @State private var now_count_part: Int = 0
    
    var body: some View {
        VStack {
            BaseView(title: "\(isEdited ? "Редактирование" : "Добавление"): \(menu[section])", dismiss: dismiss,  onCancel: isEdited ? {
                resetToOriginal()
            } : nil)
            ScrollView {
                VStack(spacing: 20){
                    HStack{
                        Image(systemName: "square.and.pencil")
                        TextField("Введите название", text: $SelectedItem[1])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack{
                        Image(systemName: "square.and.pencil")
                        TextField("Введите целевую аудиторию", text: $SelectedItem[2])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack{
                        Image(systemName: "square.and.pencil")
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextEditor(text: $SelectedItem[3])
                            .frame(height: 70) // ← высота поля
                            .padding(8)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
                    }
                    HStack{
                        Image(systemName: "square.and.pencil")
                        Text("Вместимость (человек): \(Int(capacity))")
                        Slider(
                            value: $capacity, ///!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            in: 1...100,
                            step: 1
                        )
                        .tint(capacity > 90 ? .red : (capacity > 70 ? .orange : .blue))
                        .onAppear {
                            capacity = Double(SelectedItem[4]) ?? 1
                        }
                        .onChange(of: capacity) { newValue in
                            SelectedItem[4] = String(Int(newValue))
                        }
                        .glassEffect()
                        
                    }
                    HStack{
                        Image(systemName: "square.and.pencil")
                        TextField("Введите аудиторию проведения", text: $SelectedItem[5])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack{
                        Image(systemName: "square.and.pencil")
                        TextField("Введите онлайн ссылку", text: $SelectedItem[6])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()

            }
            .onAppear {
                if isEdited {
                    originalSelectedItem = SelectedItem
                }
                else{
                    SelectedItem[4] = "1"
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .frame(width: 500, height: 200)
            .background(.black.opacity(0.1))
            .cornerRadius(20)
            .padding()
            
            VStack{
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
                .disabled(SelectedItem[1].isEmpty || SelectedItem[2].isEmpty || SelectedItem[5].isEmpty)
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
            Text("Запись с таким названием уже существует")
        }
        .alert("Ошибка", isPresented: $showAlertMaxPart) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Максимальное количество участников не может быть меньше \(now_count_part)")
        }
        .alert("Ошибка", isPresented: $showAlertMaxChar) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ошибка сохранения! Проверьте количество символов!")
        }
        
        .frame(width: 550, height: 350)
        .padding(20)
    }
    private func saveData() {
        let dbManager = PostgreSQLManager()
        let tableName = MenuItem().table_names[section] ?? ""
        
        // Экранируем текстовые поля
        let safeTitle = dbManager.escapeSQL(SelectedItem[1])
        let safeTargetAudience = dbManager.escapeSQL(SelectedItem[2])
        let safeDescription = dbManager.escapeSQL(SelectedItem[3])
        let safeAudience = dbManager.escapeSQL(SelectedItem[5])
        let safeOnlineLink = dbManager.escapeSQL(SelectedItem[6])
        let safeId = dbManager.escapeSQL(SelectedItem[0])
        
        let cleanedTitle = safeTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAudience = safeAudience.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedTargetAudience = safeTargetAudience.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedTitle.isEmpty || cleanedAudience.isEmpty || cleanedTargetAudience.isEmpty {
            showAlertField = true
            return
        }
        
        if !isEdited || (isEdited && SelectedItem[1] != originalSelectedItem[1]) {
            let items = dbManager.executeTableQuery(tableName, "SELECT * FROM \(tableName) WHERE title='\(cleanedTitle)'") ?? []
            if !items.isEmpty {
                showAlertUnique = true
                return
            }
        }
        // Проверка максимального количества участников
        if isEdited && Int(SelectedItem[4])! < Int(originalSelectedItem[4])! {
            let items = dbManager.executeTableQuery("", "SELECT * FROM participants_master_classes WHERE id_master_class=\(safeId)") ?? []
            if items.count > Int(SelectedItem[4])! {
                now_count_part = items.count
                showAlertMaxPart = true
                return
            }
        }
        
        var query = ""
        
        if !isEdited {
            query = "INSERT INTO \(tableName) (title, target_audience, audience, description, max_participants, online_link) VALUES ('\(cleanedTitle)', '\(cleanedTargetAudience)', '\(cleanedAudience)', '\(safeDescription)', '\(Int(SelectedItem[4])!)', '\(safeOnlineLink)')"
        } else {
            if SelectedItem == originalSelectedItem {
                dismiss()
                return
            }
            query = "UPDATE \(tableName) SET title='\(cleanedTitle)', target_audience='\(cleanedTargetAudience)', audience='\(cleanedAudience)', description='\(safeDescription)', max_participants='\(Int(SelectedItem[4])!)', online_link='\(safeOnlineLink)' WHERE id=\(safeId)"
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
