import SwiftUI

struct HappyView: View {
    @State private var rotationAngle = 0.0
    @State var speed = 1.0
    @State var size = 50.0
    @State var epilepce: Bool = false
    @State private var animationTask: Task<Void, Never>?
    @State private var backgroundColor = Color.clear
    @State private var colorTask: Task<Void, Never>?
    
    let epilepticColors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan
    ]
    
    var body: some View {
        ZStack {
            // Фон который будет мигать
            backgroundColor
                .ignoresSafeArea()
            
            GeometryReader{ _ in
                ZStack{
                    VStack{
                        Image("happy")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.circle)
                            .frame(width:size*8, height:size*8)
                            .overlay( Circle().stroke(backgroundColor == .clear ? .black : epilepticColors.randomElement()!, lineWidth: 4))
                            .rotationEffect(Angle(degrees: rotationAngle))
                    }
                    .frame(width: 600, height: 600)
//                    .frame(maxWidth: 600, maxHeight: 600)
                    .padding(20)
                    VStack{
                        
                        Spacer()
                        Spacer()
                        HStack{
                            Text("Эпилепсии:")
                                .font(Font.title2.bold())
                                .opacity(1)
                                .foregroundStyle(backgroundColor == .clear ? .primary : backgroundColor)
                            Toggle(isOn: $epilepce) {}
                                .scaleEffect(1.2)
                                .padding(.horizontal, 10)
                                .toggleStyle(.switch)

                            
                        }
                        .frame(width: 200, height: 50)
                        .padding(.horizontal, 20)
                        .glassEffect()
                        
                        
                        HStack{
                            Text("Скорость: \(Int(speed))")
                                .font(Font.title2.bold())
                                .foregroundStyle(backgroundColor == .clear ? .primary : backgroundColor)
                            Slider(
                                value: $speed,
                                in: 1...100,
                                step: 1
                            )
                            .tint(backgroundColor)
                            .glassEffect()
                        }
                        .frame(width: 300, height: 50)
                        .padding(.horizontal, 20)
                        .glassEffect()
                        
                        .padding(.top, 10)
                        HStack{
                            Text("Размер: \(Int(size))")
                                .font(Font.title2.bold())
                                .foregroundStyle(backgroundColor == .clear ? .primary : backgroundColor)
                            Slider(
                                value: $size,
                                in: 1...100,
                                step: 1
                            )
                            .tint(backgroundColor)
                            
                            .glassEffect()
                        }
                        .frame(width: 400, height: 50)
                        .padding(.horizontal, 20)
                        .glassEffect()
                        .padding(.top, 10)
                    }
                }
            }
            .padding(20)
            .frame(minHeight: 650)
            .frame(maxWidth: 700, maxHeight: 700)
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            animationTask?.cancel()
            colorTask?.cancel()
        }
        .onChange(of: epilepce) { newValue in
            if newValue {
                startColorAnimation()
            } else {
                stopColorAnimation()
                backgroundColor = .clear
            }
        }
    }
    
    private func startAnimation() {
        animationTask = Task {
            while !Task.isCancelled {
                rotationAngle += (speed * 0.36)
                if rotationAngle >= 360 {
                    rotationAngle = 0
                }
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
        }
    }
    
    private func startColorAnimation() {
        colorTask = Task {
            while !Task.isCancelled && epilepce {
                backgroundColor = epilepticColors.randomElement() ?? .red
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
            }
        }
    }
    
    private func stopColorAnimation() {
        colorTask?.cancel()
        colorTask = nil
    }
}

struct HappyView_Previews: PreviewProvider {
    static var previews: some View {
        HappyView()
    }
}
