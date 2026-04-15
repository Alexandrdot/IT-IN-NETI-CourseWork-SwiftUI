import SwiftUI

struct BaseView: View {
    let title: String
    let dismiss: DismissAction
    let onCancel: (() -> Void)?
    
    var body: some View {
        HStack {
            Button(action: {
                if let onCancel = onCancel {
                   onCancel()
                }
                else {
                   dismiss()
                }
            }) {
                Image(systemName: "multiply")
                    .foregroundStyle(.red)
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
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .frame(height: 60)
                .frame(minWidth: 400)
                .glassEffect()
                .padding(.trailing, 30)
        }
        .padding(.top, 30)
    }
}
