import SwiftUI

struct AuthorizationView: View {
    
    @State var index = 0
    @State private var isAuthenticated = false
    @State private var user: User? = nil
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        if isAuthenticated && user != nil {
            MainWindowView(isAuthenticated: $isAuthenticated,user: $user)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        else{
            GeometryReader { _ in
                VStack {
                    
                    Spacer()
                    Image("logo")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(4)
                        .frame(width:170, height: 130)
                        .glassEffect()
                    
                    ZStack {
                        SingUp(user: $user, index: self.$index, isAuthenticated: $isAuthenticated)
                            .zIndex(Double(self.index))
                        Login(user: $user, index: self.$index, isAuthenticated: $isAuthenticated)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .frame(minWidth: 400, minHeight: 600)
            .background(LinearGradient(gradient: Gradient(colors: [.clear, .purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
            .preferredColorScheme(.dark)
        }
    }
}

struct CShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        return Path { path in
            path.move(to: CGPoint(x: rect.width, y: 100))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}

struct CShape1: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 100))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
}

struct Login : View {
    @State var email = ""
    @State var pass = ""
    @State var showForgotPassword = false
    
    @State var showAlertEmail: Bool = false
    @State var showAlertPassword: Bool = false
    @State var showAlertAll: Bool = false
    @State var showAuthError: Bool = false
    
    @Binding var user: User?
    @Binding var index : Int
    @Binding var isAuthenticated: Bool
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    VStack(spacing: 10) {
                        Text("Login")
                            .foregroundColor(self.index == 0 ? .white : .gray)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Capsule()
                            .fill(self.index == 0 ? Color.blue : Color.clear)
                            .frame(width: 100, height: 5)
                    }
                    
                    Spacer()
                    
                } .padding(.top, 30)
                
              VStack{
                    
                    HStack(spacing: 15){
                        
                        Image(systemName: "envelope.fill")
                        .foregroundColor(Color("Color1"))
                        .padding(8)
                        .glassEffect()
                        
                        TextField("Email Address", text: self.$email)
                            .focused($focusedField, equals: .email)
                    }
                    
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(Color("Color1"))
                            .padding(8)
                            .glassEffect()
                        SecureField("Password", text: self.$pass)
                            .focused($focusedField, equals: .password)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.5))
                } .padding(.horizontal)
                    .padding(.top, 30)
                
                HStack {
                    Spacer(minLength: 0)
                    Button(action: {
                        email=""
                        pass=""
                        self.showForgotPassword = true
                    }) {
                        Text("Forget Password?")
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .buttonStyle(.bordered)
                    .cornerRadius(30)
                }
                .padding(.horizontal)
                    .padding(.top, 30)
                
            }   .padding()
                .padding(.bottom, 65)
                .background(Color("Color2"))

            
                .clipShape(CShape())
                .contentShape(CShape())
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: -5)
                .onTapGesture {
                    self.index = 0
            }
            .cornerRadius(35)
            .padding(.horizontal, 20)
            
            
            Button(action: {
                if (self.email.isEmpty && self.pass.isEmpty) {
                    showAlertAll = true
                }
                else if (self.email.isEmpty || !email.contains("@")){
                    showAlertEmail = true
                }
                else if (self.pass.isEmpty || self.pass.count < 6 ){
                    showAlertPassword = true
                }
                else {
                    if let u = authManager.login(login: email.lowercased(), password: pass) {
                        user = u  // ← Сохраняем пользователя
                        email = ""
                        pass = ""
                        isAuthenticated = true
                    } else {
                        showAuthError = true
                    }
                }
            }) {
                Text("LOGIN")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding(.horizontal, 50)
                    .clipShape(Capsule())
                    .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
            }
            .buttonStyle(.glass)
            .cornerRadius(35)
            .offset(y: 30)
            .opacity(self.index == 0 ? 1 : 0)
            
            .alert("Ошибка данных", isPresented: $showAlertAll) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Заполните все поля")
            }
            
            .alert("Ошибка данных", isPresented: $showAlertEmail) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Заполните поле Email и убедитесь в наличии '@' ")
            }
            
            .alert("Ошибка данных", isPresented: $showAlertPassword) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Заполните поле Password и убедитесь в наличии не менее 6 символов ")
            }
            .alert("Ошибка", isPresented: $showAuthError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Неправильный логин или пароль")
            }
            
        }
        .onChange(of: index) { newIndex in
            if newIndex != 0 {
                focusedField = nil
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            // Сбрасываем фокус при появлении
            focusedField = nil
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

struct SingUp: View {
    @State var email = ""
    @State var pass = ""
    @State var Repass = ""
    
    @Binding var user: User?
    @State var showAlertEmail: Bool = false
    @State var showAlertPassword: Bool = false
    @State var showAlertAll: Bool = false
    @State var swowAlertRepass: Bool = false
    @State var showSignUpError: Bool = false
    
    @Binding var index : Int
    @Binding var isAuthenticated: Bool
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, repassword
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Spacer(minLength: 0)
                    
                    VStack(spacing: 10) {
                        Text("SignUp")
                            .foregroundColor(self.index == 1 ? .white : .gray)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Capsule()
                            .fill(self.index == 1 ? Color.blue : Color.clear)
                            .frame(width: 100, height: 5)
                    }
                }
                .padding(.top, 30)
                                
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "envelope.fill")
                        .foregroundColor(Color("Color1"))
                        .padding(8)
                        .glassEffect()
                        TextField("Email Address", text: self.$email)
                            .focused($focusedField, equals: .email)
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                
                VStack {
                    
                    HStack(spacing: 15) {
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(Color("Color1"))
                            .padding(8)
                            .glassEffect()
                        SecureField("Password", text: self.$pass)
                            .focused($focusedField, equals: .password)
                    }
                    Divider()
                        .background(Color.white.opacity(0.5))
                } .padding(.horizontal)
                    .padding(.top, 30)
                
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(Color("Color1"))
                            .padding(8)
                            .glassEffect()
                        SecureField("Password", text: self.$Repass)
                            .focused($focusedField, equals: .repassword)
                    }
                    Divider().background(Color.white.opacity(0.5))
                } .padding(.horizontal)
                    .padding(.top, 30)
                
            }
            .padding()
            .padding(.bottom, 65)
            .background(Color("Color2"))
            .clipShape(CShape1())
            .contentShape(CShape1())
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: -5)
            .onTapGesture {
                self.index = 1
            }
            .cornerRadius(35)
            .padding(.horizontal,20)
            
            Button(action: {
                
                if (self.email.isEmpty && self.pass.isEmpty && self.Repass.isEmpty) {
                    showAlertAll = true
                }
                else if (self.email.isEmpty || !email.contains("@")){
                    showAlertEmail = true
                }
                else if (self.pass.isEmpty || self.pass.count < 6){
                    showAlertPassword = true
                }
                else if (self.pass != self.Repass){
                    swowAlertRepass = true
                }
                else {
                    if let u = authManager.signUp(login: email.lowercased(), password: pass) {
                        user = u  // ← Сохраняем пользователя
                        email = ""
                        pass = ""
                        isAuthenticated = true
                    } else {
                        showSignUpError = true
                    }
                }
            }) {
                Text("SIGNUP")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding(.horizontal, 50)
                    .clipShape(Capsule())
                    .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: -5)
            }
            .buttonStyle(.glass)
            .cornerRadius(35)
            .offset(y: 28)
            .opacity(self.index == 1 ? 1 : 0)
            
            
            .alert("Ошибка данных", isPresented: $showAlertAll) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Заполните все поля")
            }
            
            .alert("Ошибка данных", isPresented: $showAlertEmail) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Заполните поле Email и убедитесь в наличии '@' ")
            }
            
            .alert("Ошибка данных", isPresented: $showAlertPassword) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Заполните поле Password и убедитесь в наличии не менее 6 символов ")
            }
            
            .alert("Ошибка данных", isPresented: $swowAlertRepass) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Пароли не совпадают! ")
            }
            .alert("Ошибка", isPresented: $showSignUpError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Пользователь с таким логином уже существует! ")
            }
            
        }
        .onChange(of: index) { newIndex in
            if newIndex != 1 {
                focusedField = nil
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            // Сбрасываем фокус при появлении только если это активная вкладка
            if index != 1 {
                focusedField = nil
            }
        }
    }
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView()
    }
}
