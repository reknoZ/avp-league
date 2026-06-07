import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    @State private var scale: CGFloat = 0.08
    @State private var opacity: Double = 1

    private let logoWidth: CGFloat = 240
    private let avpYellow = Color(red: 1, green: 0.831, blue: 0)

    var body: some View {
        ZStack {
            avpYellow.ignoresSafeArea()

            VStack(spacing: 10) {
                Image("AVPLogo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.black)
                    .frame(width: logoWidth)

                Text("League")
                    .font(.system(size: 30, weight: .bold))
                    .tracking(6)
                    .foregroundStyle(.black)
            }
            .scaleEffect(scale)
        }
        .opacity(opacity)
        .onAppear(perform: runAnimation)
    }

    private func runAnimation() {
        withAnimation(.spring(response: 0.95, dampingFraction: 0.78, blendDuration: 0)) {
            scale = 1
        }

        Task {
            try? await Task.sleep(for: .seconds(1.55))
            withAnimation(.easeInOut(duration: 0.45)) {
                opacity = 0
            }
            try? await Task.sleep(for: .seconds(0.45))
            onFinish()
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
