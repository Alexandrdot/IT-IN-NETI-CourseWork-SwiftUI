import SwiftUI

struct InformationView: View {
    @State private var selectedItem: Int? = nil
    var menu = MenuItem()
    
    var body: some View{
        GeometryReader{ _ in
            
            
            HStack(spacing: 0){
                //Spacer()
                //NavigationSplitView{
                List(selection: $selectedItem) {
                    
                    NavigationLink(value: 0) {
                        Image(systemName: "info.circle")
                        Text("\(menu.navi[0])")
                    }
                    NavigationLink(value: 1) {
                        Image(systemName: "document.on.document")
                        Text("\(menu.navi[1])")
                    }
                    NavigationLink(value: 2) {
                        Image(systemName: "person.2")
                        Text("\(menu.navi[2])")
                    }
                    NavigationLink(value: 3) {
                        Image(systemName: "icloud")
                        Text("\(menu.navi[3])")
                    }
                    NavigationLink(value: 4) {
                        Image(systemName: "square.and.arrow.up.on.square")
                        Text("\(menu.navi[4])")
                    }
                    NavigationLink(value: 5) {
                        Image(systemName: "bookmark.circle")
                        Text("\(menu.navi[5])")
                    }
                }
                .listStyle(.sidebar)
                .background(Color(.controlBackgroundColor))
                .scrollContentBackground(.hidden)
                .frame(width: 150)
                //Divider()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1) // ← тень
                
                
                if let selectedItem = selectedItem{
                    InformationDetailView(section: selectedItem)
                }
                else {
                    WelcomeView()
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor)) // ←
        
    }
}


struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
