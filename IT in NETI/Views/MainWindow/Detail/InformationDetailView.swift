import SwiftUI

struct InformationDetailView: View{
    let section: Int
    let messages = Messages().messages_about
    var menu = MenuItem()

    var body: some View {
        GeometryReader { geometry in
            HStack{
                VStack(spacing: 30) {
                    Text("Руководство к использованию: \(menu.navi[section])")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("\(messages[section])")
                        .font(.body)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.controlBackgroundColor))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                }
                .padding(.vertical, 40)
                .padding(.leading, 20)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.1)]), startPoint: .bottomLeading, endPoint: .bottomTrailing).cornerRadius(20))
//        .ignoresSafeArea(edges: .horizontal)
        
    }
}

struct InformationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        InformationDetailView(section: 1)
    }
}
