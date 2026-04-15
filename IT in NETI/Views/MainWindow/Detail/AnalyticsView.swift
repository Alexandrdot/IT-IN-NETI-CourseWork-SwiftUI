import SwiftUI
import Charts

struct ChartData: Identifiable, Equatable {
    let table_name: String
    let count: Int
    var id: String { return table_name }
}

struct SetChartData: Identifiable {
    var date: String
    var type: String
    var color: String
    var count: Int
    var id = UUID()
}

struct AnalyticsView: View {
    let section: Int //номер меню
    
    @State var data: [[ChartData]] = [[], [], []]
    @State var setData: [SetChartData] = []
    
    @State private var startSelectedDate = Date()
    @State private var endSelectedDate = Date()

    var body: some View {
        VStack{
            if ([28, 30].contains(section)){
                VStack{
                    Chart {
                        ForEach(data[section-28]) { dataPoint in
                            BarMark(
                                x: .value("Количество", dataPoint.count),
                                y: .value("Таблица", dataPoint.table_name) // ← Названия по оси Y
                            )
                            .annotation(position: .trailing) {
                                Text("\(dataPoint.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(7)
                    .background(.black.opacity(0.1))
                    .cornerRadius(20)
                    .padding(10)
                }
                .onAppear{
                    data[section-28] = loadData()
                }
                .task(id: section) {
                    if data[section-28] == [] {
                        data[section-28] = loadData()
                    }
                }
            }
            else{
                VStack{
                    VStack{
                        Chart {
                            ForEach(setData) { item in
                                BarMark(
                                    x: .value("Item Type", item.date),
                                    y: .value("Total Count", item.count)
                                )
                                .foregroundStyle(by: .value("Item Color", item.type))
                                .annotation(position: .overlay) {
                                    if item.count > 0 {
                                       Text("\(item.count)")
                                           .font(.caption)
                                           .foregroundColor(.black)
                                           .opacity(0.8)
                                   }
                                }
                            }
                        }
                        .chartForegroundStyleScale([
                        "add": .green,
                        "delete": .red,
                        "set": .yellow
                        ])
                    }
                    .padding()
                    .onAppear{
                        setData = loadSetdata()
                    }
                    HStack{
                        DatePicker("Интервал: от", selection: $startSelectedDate, in: ...endSelectedDate, displayedComponents: .date)
                            .onChange(of: startSelectedDate) { _ in
                                setData = loadSetdata()
                            }
                            .datePickerStyle(.compact)
                            .padding()
                        DatePicker("до", selection: $endSelectedDate, in: startSelectedDate..., displayedComponents: .date)
                            .onChange(of: endSelectedDate) { _ in
                                setData = loadSetdata()
                            }
                            .datePickerStyle(.compact)
                            .padding()
                    }
                    .glassEffect()
                    .padding()
                }
            }
            
        }
        
    }
    func loadSetdata() -> [SetChartData]{
        // 1 зайти в таблицу логирование и по between собрать все действия
        // 2 разделить по датам
        // 3 в каждой дате посчитать сколько и какие действия
        // info = [date1: [add:10, set:5, del: 4], date2: [add:14, set:2, del: 7], ...]
        // построить диаграмму накопления разными цветами
        let dbManager = PostgreSQLManager()
        var tmp_setDate: [SetChartData] = []
            // Форматируем даты для SQL
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let startDateStr = formatter.string(from: startSelectedDate)
            let endDateStr = formatter.string(from: endSelectedDate)
            
            // Запрос для получения статистики по датам
            let query = """
            SELECT 
                event_date,
                event_type,
                COUNT(*) as count
            FROM logs
            WHERE event_date BETWEEN '\(startDateStr)' AND '\(endDateStr)'
            GROUP BY event_date, event_type
            ORDER BY event_date
            """
            
            guard let result = dbManager.executeTableQuery("", query) else {
                return []
            }
            // Собираем данные по датам
            var dateStats: [String: [String: Int]] = [:]
            
            for row in result {
                guard let date = row["column_0"] as? String,
                      let eventType = row["column_1"] as? String,
                      let countString = row["column_2"] as? String,
                      let count = Int(countString) else {
                    continue
                }
                if dateStats[date] == nil {
                    dateStats[date] = ["add": 0, "set": 0, "delete": 0]
                }
                dateStats[date]?[eventType] = count
            }
            print(dateStats)
            //["2025-12-07": ["delete": 2, "add": 6, "set": 6]]
            for (date, events) in dateStats {
                for (type, count) in events {
                    let chartItem = SetChartData(
                        date: date,
                        type: type,
                        color: getColorForEventType(type), // Функция для определения цвета
                        count: count
                    )
                    tmp_setDate.append(chartItem)
                }
            }

            tmp_setDate.sort {
                if $0.date == $1.date {
                    return $0.type < $1.type
                }
                return $0.date < $1.date
            }
            return tmp_setDate
    }
    
    func loadData() -> [ChartData] {
        let dbManager = PostgreSQLManager()
        let menuItem = MenuItem()
        var data: [ChartData] = []
        
        switch section {
            case 28:
                for (_, tableName) in menuItem.table_names {
                    let countQuery = "SELECT COUNT(*) FROM \(tableName)"
                    
                    if let result = dbManager.executeTableQuery("", countQuery),
                       let firstRow = result.first,
                       let countString = firstRow["column_0"] as? String,
                       let count = Int(countString) {
                        
                        data.append(ChartData(table_name: tableName, count: count))
                    }
                }
            case 30:
                let dbManager = PostgreSQLManager()
                // 1. Получаем все мастер-классы
                let masterClassesQuery = "SELECT id, title FROM master_classes"
                
                let masterClasses = dbManager.executeTableQuery("", masterClassesQuery) ?? []
                
                for mc in masterClasses {
                    guard let mcId = mc["column_0"] as? String,
                          let title = mc["column_1"] as? String else {
                        continue
                    }
                    
                    let participantsQuery = "SELECT COUNT(*) FROM participants_master_classes WHERE id_master_class = \(mcId)"
                    
                    var participantCount = 0
                    if let countResult = dbManager.executeTableQuery("", participantsQuery),
                       let firstRow = countResult.first,
                       let countString = firstRow["column_0"] as? String,
                       let count = Int(countString) {
                        participantCount = count
                    }
                    data.append(ChartData(
                        table_name: title,
                        count: participantCount
                    ))
                }
            
            default:
                fatalError("Unknown section")
        }
        
        return data.sorted { $0.count > $1.count }
    }
    func getColorForEventType(_ type: String) -> String {
        switch type {
        case "add":
            return "green"
        case "delete":
            return "red"
        case "set":
            return "yellow"
        default:
            return "gray"
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView(section: 29)
    }
}
