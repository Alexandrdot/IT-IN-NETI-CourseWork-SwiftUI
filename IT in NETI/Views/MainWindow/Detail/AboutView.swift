import SwiftUI

struct AboutView: View{
    var body: some View{

        VStack{
            VStack(spacing: 20){
                Image(systemName: "swift").symbolEffect(.scale.up.byLayer, options: .nonRepeating)
                    .font(.system(size: 45))
                    .frame(width: 100, height: 100)
                    .background(.blue)
                    .cornerRadius(50)
                    .padding(.top, 20)
                Text("Приложение разработанно в 2025 году на SwiftUI")
                    .padding(20)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Название приложения: IT in NETI \nВерсия: 1.0.0\nПлатформа: MacOs")
                    .font(.title3)
                    .frame(width: 300, height: 100, alignment: .center)
                    .background(.black.opacity(0.25))
                    .cornerRadius(30)
                Spacer()
                
                HStack{
                    Image(systemName: "apple.logo")
                    Text("Design by AlexandrDot")
                        
                }
                .padding(.bottom, 15)
            }
        }
    }
}


struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
