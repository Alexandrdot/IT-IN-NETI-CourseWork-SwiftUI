import SwiftUI

extension View {
    func inputFieldStyle() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .padding(.vertical, 5)
            .padding(.trailing, 15)
    }
    func ExitButtonStyle() -> some View {
        self
            .clipShape(.circle)
            .buttonStyle(.glass)
            .contentShape(Rectangle())
            .frame(width: 50, height: 50)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 25)
    }
}

