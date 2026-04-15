import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        HStack{
            Text("Оформление:")
                .font(.title2)
                .bold()
            Picker(selection: $isDarkMode, label: Text("")) {
                Text("Светлое").tag(false)
                Text("Тёмное").tag(true)
                    .foregroundStyle(.black)
            }
            .tint(isDarkMode ? .black : .white)
            .cornerRadius(10)
            .frame(width: 170, height: 70)
            .background(.black.opacity(0.15))
            .pickerStyle(SegmentedPickerStyle())
            .cornerRadius(30)
        }
        .frame(width: 400, height: 200)
        .glassEffect()
    }
}

struct SettingsView_Previews: PreviewProvider{
    static var previews: some View{
        SettingsView()
    }
}
