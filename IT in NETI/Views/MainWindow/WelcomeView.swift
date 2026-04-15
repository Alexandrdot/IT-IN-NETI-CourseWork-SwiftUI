import SwiftUI

struct WelcomeView: View{
    var body: some View {
        HStack{
            Image(systemName: "arrowshape.left")
                .resizable()
                .frame(width: 30, height: 30)
                .symbolEffect(.breathe)
            Text("Выберите раздел")
                .foregroundColor(.secondary)
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(width: 250, height: 50)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.3)]), startPoint: .bottomTrailing, endPoint: .bottomLeading))
                .cornerRadius(20)
        }
        
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
