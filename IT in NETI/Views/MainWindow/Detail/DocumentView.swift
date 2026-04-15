import SwiftUI
import CodableCSV
import UniformTypeIdentifiers

struct DocumentView: View {
    
    var user: User
    
    
    @State private var showExporter = false
    
    
    @State var ban_table_names: [String] = []
    @State var white_list_table_names: [String] = []
    let ban_words = [
        "insert", "update", "delete", "drop", "alter", "create",
        "truncate", "replace", "exec", "execute", "xp_", "sp_",
        "shutdown", "kill", "--", "/*", "*/", ";" ]
    
    let should_words = ["select", "from"]
    
    @State private var sqlquery: String = ""
    @State private var isMyQUERY: Bool = true
    @State var columnNames: [String] = []
    @State var textError: String = ""
    @State private var errorTimer: Timer?
    var listik: [Double] = [1, 2.5, 4]
    @State private var  result_query: [[Any]] = [] //список результатов
    var queries: [String] = ["select * from participants", "select * from master_classes", "select * from teachers", "select * from groups"]
    
    var body: some View {
        VStack{
            // Подпись, поле ввода и кнопка
            VStack{
                HStack{
                    Image(systemName: "externaldrive.badge.person.crop")
                        .font(.system(size: 35))
                        .frame(width: 60, height: 60)
                        .cornerRadius(50)
                    Text("SQL-запросы")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                HStack{
                    if (isMyQUERY){
                        Text("Запрос:")
                        TextField("Введите запрос", text: self.$sqlquery)
                            .cornerRadius(20)
                    }
                    else{
                        Text("Выберите запрос:")
                        Picker(selection: $sqlquery, label: Text("")) {
                            ForEach(queries, id: \.self) { item in
                                Text("\(item)").tag(item)
                            }
                        }
                        .cornerRadius(20)
                        .glassEffect()
                    }
                }
                .font(.title3)
                .frame(minWidth: 300)
                .frame(height: 40)
                .padding(10)
                .glassEffect()
                .padding(20)
                HStack{
                    HStack{
                        Image(systemName: "stroke.line.diagonal.slash")
                            .foregroundStyle(.red)
                        Text("\(textError)")
                            .foregroundStyle(.red)
                            .italic()
                            
                    }
                    .frame(width: 220, height: 40)
                    .glassEffect()
                    .padding(.leading, 20)
                    .opacity(textError == "" ? 0 : 1)
                    HStack{
                        Text("Ввести самому:")
                            .font(.title3)
                        Toggle(isOn:$isMyQUERY){}
                            .toggleStyle(.switch)
                    }
                    .frame(width: 200, height: 40)
                    .glassEffect()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 20)
                }
                Button(action:{
                    executeQuery()
                }) {
                    Text("Выполнить")
                        .font(.title3)
                        .padding(11)
                    
                }
                .clipShape(Capsule())
                .buttonStyle(.glass)
                .contentShape(Rectangle())
                .frame(width: 125, height: 50)
                .glassEffect()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            }
            //результат в виде list
            VStack{
                List(result_query as? [[String]] ?? [], id: \.self) { row in
                    HStack{
                        Image(systemName: "list.bullet")
                        // Объединяем "столбец: значение" для всех полей в одну строку
                        Text(
                            zip(row, columnNames)
                                .map { "\($1): \($0)" }
                                .joined(separator: ", ")
                        )
                        Spacer()
                    }
                }
                .mask(
                    RoundedRectangle(cornerRadius: 55)
                )
                .glassEffect()
            }
            .padding(20)
            .frame(height: 150)
            
            //кнопка экспорта
            VStack{
                Button(action:{
                    exportToCSV()
                }) {
                    Text("Экспорт данных")
                        .font(.title3)
                        .padding(2)
                }
                .clipShape(Capsule())
                .buttonStyle(.glass)
                .frame(width: 140, height: 30)
                .glassEffect()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .disabled(columnNames == [])
            }
            .padding(.bottom, 20)
        }
        // Добавь модификатор к VStack:
        
        .onAppear{
            (white_list_table_names, ban_table_names) = GetBanTableNames()
        }
        
    }
    
    private func executeQuery()->Void{
        columnNames = []
        result_query = []
        sqlquery = sqlquery.lowercased()
        //запретные слова
        if (ban_words.contains(where: { sqlquery.lowercased().contains($0) })){
            textError = "Запретные слова в запросе"
            startErrorTimer()
            return
        }
        //запретные таблицы
        if (ban_table_names.contains(where: { sqlquery.lowercased().contains($0) })){
            textError = "Нет доступа к таблицам"
            startErrorTimer()
            return
        }
        // нет селекта и фрома
        if !should_words.allSatisfy({ sqlquery.lowercased().contains($0) }) {
            textError = "Запрос должен содержать SELECT и FROM"
            startErrorTimer()
            return
        }
        if !white_list_table_names.contains(where: { sqlquery.lowercased().contains($0) }) {
            textError = "Запрос должен содержать доступную таблицу"
            startErrorTimer()
            return
        }
        

        result_query = loadData()
        //получили список значений без столбцов
        
        let words_after = GetWordsAfter()
        
        if words_after[0] == "*"{
            columnNames = PostgreSQLManager().getTableColumnNames("\(words_after[1])")
        }
        if columnNames == []{
            let columnCount = result_query.first?.count ?? 0
                columnNames = (0..<columnCount).map { "col_\($0)" }
        }
        //теперь имеем подписи для каждого столбца
        
        
    }
    func loadData() -> [[Any]]{
        guard let one_data_dict = PostgreSQLManager().executeTableQuery("", sqlquery) else {
                textError = "Ошибка выполнения запроса"
                startErrorTimer()
                return []
            }
        
        
        let one_data = one_data_dict.map { dict in
            Array(dict.sorted {
                // Извлекаем числа из "column_1", "column_2" и сравниваем как Int
                let num1 = Int($0.key.replacingOccurrences(of: "column_", with: "")) ?? 0
                let num2 = Int($1.key.replacingOccurrences(of: "column_", with: "")) ?? 0
                return num1 < num2
            }.map { $0.value })
        }
        return one_data
    }
    
    func GetBanTableNames()->([String], [String]) {
        // all
        let dbManager = PostgreSQLManager()
        let allTablesQuery = "SELECT table_name FROM menu WHERE table_name IS NOT NULL"
        let allTables = dbManager.executeTableQuery("menu", allTablesQuery) ?? []
        //print(allTables)
        
        //access
        let accessibleTablesQuery = "SELECT m.table_name FROM menu m JOIN accesses a ON a.id_menu = m.id WHERE m.table_name IS NOT NULL AND a.id_role = \(user.id_role) AND a.r = 't'"
        let accessibleTables = dbManager.executeTableQuery("accesses", accessibleTablesQuery) ?? []
        let accessibleTableNames1 = accessibleTables.compactMap { $0["column_0"] as? String }
        
        //ban
        let allTableNames = allTables.compactMap { $0["column_0"] as? String }
        let accessibleTableNames = accessibleTables.compactMap { $0["column_0"] as? String }
        let forbiddenTableNames = Array(Set(allTableNames).subtracting(Set(accessibleTableNames)))
        
        print(forbiddenTableNames)
        return (accessibleTableNames1, forbiddenTableNames)
    }
    
    func GetWordsAfter()->[String]{
        let words = sqlquery.split(separator: " ").map(String.init)

        var selectWord: String = ""
        var fromWord: String = ""

        for i in 0..<words.count-1 {
            if words[i].lowercased() == "select" && i+1 < words.count {
                selectWord = words[i+1]
            }
            if words[i].lowercased() == "from" && i+1 < words.count {
                fromWord = words[i+1]
            }
        }
        return [selectWord, fromWord]
    }
    private func startErrorTimer() {
        errorTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            textError = ""
        }
    }
    func exportToCSV() {
        guard !result_query.isEmpty else {
            textError = "Нет данных для экспорта"
            startErrorTimer()
            return
        }
        
        do {
            let encoder = CSVEncoder {
                $0.headers = columnNames
                $0.delimiters.row = "\n"
                $0.delimiters.field = ";"
            }
            
            let stringData = result_query.map { row in
                row.map { "\($0)" }
            }
            
            let csvData = try encoder.encode(stringData)
            
            // Сохраняем во временный файл
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("export_\(Date().timeIntervalSince1970).csv")
            
            try csvData.write(to: tempURL)
            
            // Показываем панель шаринга
            let sharingService = NSSharingServicePicker(items: [tempURL])
            sharingService.show(relativeTo: .zero, of: NSApp.keyWindow!.contentView!, preferredEdge: .minY)
            
            textError = "Файл готов для экспорта"
            startErrorTimer()
            
        } catch {
            textError = "Ошибка: \(error.localizedDescription)"
            startErrorTimer()
        }
    }
   
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(user: User(login: "test", password: "test", id_role: 1))
    }
}
