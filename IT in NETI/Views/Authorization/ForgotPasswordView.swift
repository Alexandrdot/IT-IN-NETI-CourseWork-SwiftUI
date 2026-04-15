import SwiftUI

struct ForgotPasswordView: View {
    
    @State var email: String = ""
    @State private var showAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    let massage: String = "Инструкции для восстановления пароля высланы на почту!"
    var body: some View {
        
        VStack(spacing: 20) {
            VStack{
                Button(action: {
                        dismiss()
                    }) {
                    Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .padding(10)
                    }
                    .cornerRadius(50)
                    .frame(width: 10)
                    .padding(.leading, -200)
   
                Image("logo")
                    .resizable()
                    .frame(width: 80, height: 80, alignment: .center)
                    .cornerRadius(4)
            }
            .padding(20)
                
            VStack{
                Text("Восстановление пароля")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                HStack(spacing: 15){
                    
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color("Color1"))
                    
                    TextField("Email Address", text: self.$email)
                }
                .padding()
                Button(action: {
                    showAlert = true;
                }) {
                    Text("Восстановить пароль")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(Color("Color1"))
                        .clipShape(Capsule())
                        .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
                }
                .alert("Восстановление пароля", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {  dismiss() }
                } message: {
                    Text(massage)
                }
                .offset(y: 25)
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 65)
            }
            .padding()
            .padding(.bottom, 65)
            .background(Color("Color2"))
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: -5)
            .cornerRadius(35)
            .padding(.horizontal,20)
        }
        .frame(height:600)
        .background(LinearGradient(gradient: Gradient(colors: [.clear, .purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
    }
}

struct ForfotPassword_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
