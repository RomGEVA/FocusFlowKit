import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var page = 0
    
    var body: some View {
        TabView(selection: $page) {
            OnboardingPage(
                title: "Welcome to FocusFlow",
                subtitle: "Pomodoro timer for deep work and mindful breaks.",
                image: "timer.circle.fill",
                gradient: Gradient(colors: [.mint, .green])
            )
            .tag(0)
            
            OnboardingPage(
                title: "Phases",
                subtitle: "Work, Short Break, Long Break — all automatic.",
                image: "circle.grid.3x3.fill",
                gradient: Gradient(colors: [.blue, .indigo])
            )
            .tag(1)
            
            OnboardingPage(
                title: "Customize & Track",
                subtitle: "Set durations, track stats, and stay focused.",
                image: "slider.horizontal.3",
                gradient: Gradient(colors: [.purple, .pink])
            )
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if page < 2 {
                        Button("Next") {
                            withAnimation { page += 1 }
                        }
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                        .padding(.bottom, 40)
                    } else {
                        Button("Start") {
                            hasSeenOnboarding = true
                        }
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                        .padding(.bottom, 40)
                    }
                    Spacer()
                }
            }
        )
        .animation(.easeInOut, value: page)
    }
}

struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let image: String
    let gradient: Gradient
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 180, height: 180)
                    .shadow(radius: 12)
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
            }
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
} 