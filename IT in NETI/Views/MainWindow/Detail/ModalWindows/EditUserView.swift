import SwiftUI

struct EditUserView: View {

    var list_roles: [[String]] //инфа для выбора
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var needsRefresh: Bool// ← для обновления данных в DetailView
    @Binding var SelectedItem: [String] // <- либо там ничего нет либо там есть данные для изменения
    @Binding var user: User?
    
    @State private var originalSelectedItem: [String] = ["", "", ""]
    @State var showUserAlert = false
    
    // id       login          id_ role
    //  0         1               2
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    SelectedItem = originalSelectedItem
                    dismiss()
                }) {
                    Image(systemName: "multiply")
                        .foregroundStyle(.red)
                        .frame(width: 45, height: 45)
                        .cornerRadius(30)
                        .background(.black.opacity(0.02))
                }
                .clipShape(.circle)
                .buttonStyle(.glass)
                .contentShape(Rectangle())
                .frame(width: 50, height: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 25)
                
                Text("Редактирование пользователя")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(height: 60)
                    .frame(minWidth: 400)
                    .glassEffect()
                    .padding(.trailing, 30)
            }
            .padding(.top, 30)
            ScrollView {
                
                HStack{
                    Image(systemName: "info.bubble.fill")
                    Text("Пользователь: \(SelectedItem[1])")
                }
                .inputFieldStyle()
                
                HStack{
                    Image(systemName: "square.and.pencil")
                    Picker(selection: $SelectedItem[2]) {
                        ForEach(list_roles, id: \.self) { item in
                            Text("\(item[1])").tag(item[0])
                        }
                    } label: {
                        Text("Роль")
                    }
                }
                .inputFieldStyle()
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
                    if SelectedItem[1] == user!.login {
                        showUserAlert = true
                    }
                    else{
                        saveData()
                    }
                    
                    print(SelectedItem)
                    print(originalSelectedItem)
                }) {
                    HStack{
                        Image(systemName: "square.and.arrow.down")
                        Text("Сохранить")
                            .font(.title3)
                    }
                    .foregroundStyle(.green)
                }
                .disabled(SelectedItem[2] == originalSelectedItem[2])
                .buttonStyle(.glass)
            }
            
        }
        .onAppear {
            originalSelectedItem = SelectedItem
        }
        .alert("Внимание! 🚨", isPresented: $showUserAlert) {
            Button("Изменить", role: .destructive) {
                saveData()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы меняете роль текущего пользователя. \n Подумайте несколько раз!")
        }
        
        .frame(width: 550, height: 400)
        .padding(20)
    }
    
    private func saveData() {

        let  query = "UPDATE users SET id_role='\(SelectedItem[2])' WHERE id=\(originalSelectedItem[0])"
        
        if PostgreSQLManager().executeUpdate(query) {
            user!.id_role = Int(SelectedItem[2])!
           needsRefresh = true
           dismiss()
        } else {
           print("Ошибка сохранения")
        }
   }
}
