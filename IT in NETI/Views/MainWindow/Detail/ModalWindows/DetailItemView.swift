import SwiftUI

struct DetailItemView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var item: [String]
    var section: Int
    
    let messages: [Int: [String] ] = Messages().messages
    
    var body: some View {
        VStack {
            HStack{
                Button(action:{
                    dismiss()
                }) {
                    Image(systemName: "arrowshape.turn.up.backward")
                        .foregroundStyle(.yellow)
                        .frame(width: 45, height: 45)
                        .cornerRadius(30)
                        .background(.black.opacity(0.02))
                }
                .clipShape(.circle)
                .buttonStyle(.glass)
                .contentShape(Rectangle())
                .frame(width: 50, height: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 25)
                
                
                Text("Подробная информация")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: 300, height: 60)
                    .glassEffect()
                    .padding(.trailing, 30)
                    
            }
            .padding(.top, 30)
            
            ScrollView {
                ForEach(0..<item.count, id: \.self) { i in
                    Text("\(messages[section]![i])\(item[i])")
                        .font(.title3)
                        .padding(.vertical, 1)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            .frame(width: 500, height: 350)
            .background(.black.opacity(0.1))
            .cornerRadius(20)
            .padding()
        }
        
        .frame(width: 550, height: 450)
        .padding(20)
    }
    
}

struct DetailItemView_Previews: PreviewProvider {
    static var previews: some View {
        DetailItemView(
            item: .constant(["Иван Иванов", "25 лет", "Студент"]),
            section: 15
        )
    }
}
