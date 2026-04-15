class User{
    var login: String
    var password: String //зашифрованный
    var id_role: Int
    init(login: String, password: String, id_role: Int){
        self.login = login
        self.password = password
        self.id_role = id_role
    }
}
