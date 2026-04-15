import SwiftUI

struct SetPasswordView: View {
    @Binding var user: User?
    
    @State private var oldpassword = ""
    @State private var newpassword = ""
    @State private var renewpassword = ""
    @State private var showAlert: Bool = false
    @State private var showAlert6: Bool = false
    @State private var showAlertComplete: Bool = false
    
    
    var body: some View {
        
        GeometryReader { _ in
            VStack{
                VStack{
                    HStack{
                        Image(systemName: "pencil.circle")
                            .padding(.leading, 5)
                        TextField("Введите старый пароль", text: $oldpassword)
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 10)
                    HStack{
                        Image(systemName: "eye.slash.fill")
                            
                        SecureField("Введите новый пароль", text: $newpassword)
                            .cornerRadius(20)
                        
                    }
                    .padding(.bottom, 10)
                    
                    HStack{
                        Image(systemName: "eye.slash.fill")
                        SecureField("Повторите новый пароль", text: $renewpassword)
                            .cornerRadius(20)
                    }
                }
                .padding(15)
                .frame(minWidth: 200, minHeight: 80)
                .background(.white.opacity(0.05))
                .cornerRadius(30)
                .padding(.top, 20)
                
                
                HStack{
                    Image(systemName: "stroke.line.diagonal.slash")
                        .foregroundStyle(.red)
                    Text("Пароли не совпадают")
                        .foregroundStyle(.red)
                        .italic()
                }
                .opacity(newpassword != renewpassword ? 1 : 0)
                
                Button(action:{
                    if newpassword.count < 6 {
                        showAlert6 = true
                        return
                    }
                    if authManager.hashPassword(oldpassword) != user!.password {
                        showAlert = true
                        return
                    }
                    showAlertComplete = authManager.SetPassword(login: user!.login, password: newpassword)
                    user?.password = authManager.hashPassword(newpassword)
                    oldpassword = ""
                    newpassword = ""
                    renewpassword = ""
                    
                }) {
                    Text("Сохранить")
                        .foregroundStyle(.green)
                }
                .clipShape(Capsule())
                .buttonStyle(PlainButtonStyle())
                .frame(width: 90, height: 30)
                .glassEffect()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.bottom, 20)
                .disabled(newpassword != renewpassword || newpassword == "")
            }
        }
        .padding(.horizontal, 20)
        .background(LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.1)]), startPoint: .bottomLeading, endPoint: .bottomTrailing).cornerRadius(20))
        .frame(minWidth: 400, minHeight: 200)
        .alert("Ошибка", isPresented: $showAlert){
            Button("OK", role: .cancel) {}
        } message: {
            Text("Неправильный пароль!")
        }
        .alert("Ошибка", isPresented: $showAlert6){
            Button("OK", role: .cancel) {}
        } message: {
            Text("В новом пароле должно быть не менее 6 символов!")
        }
        .alert("Уведомление", isPresented: $showAlertComplete){
            Button("OK", role: .cancel) {}
        } message: {
            Text("Успешная смена пароля!")
        }
    }
}
