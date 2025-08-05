import SwiftUI
import SafariServices
import StoreKit

struct SettingsView: View {
    @AppStorage("workDuration") private var workDuration = 25
    @AppStorage("shortBreakDuration") private var shortBreakDuration = 5
    @AppStorage("longBreakDuration") private var longBreakDuration = 15
    @AppStorage("pomodorosUntilLongBreak") private var pomodorosUntilLongBreak = 4
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Timer Settings") {
                    SettingCard(
                        title: "Work Duration",
                        icon: "timer",
                        color: .mint
                    ) {
                        Stepper("\(workDuration) minutes", value: $workDuration, in: 1...60)
                    }
                    
                    SettingCard(
                        title: "Short Break",
                        icon: "cup.and.saucer",
                        color: .blue
                    ) {
                        Stepper("\(shortBreakDuration) minutes", value: $shortBreakDuration, in: 1...30)
                    }
                    
                    SettingCard(
                        title: "Long Break",
                        icon: "bed.double",
                        color: .purple
                    ) {
                        Stepper("\(longBreakDuration) minutes", value: $longBreakDuration, in: 1...60)
                    }
                    
                    SettingCard(
                        title: "Pomodoros until Long Break",
                        icon: "number",
                        color: .orange
                    ) {
                        Stepper("\(pomodorosUntilLongBreak)", value: $pomodorosUntilLongBreak, in: 2...8)
                    }
                }
                
                Section("App") {
                    Button(action: {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                            Text("Rate App")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    SettingCard(
                        title: "Privacy Policy",
                        icon: "lock.shield",
                        color: .gray
                    ) {
                        Button("View Privacy Policy") {
                            showPrivacyPolicy = true
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPrivacyPolicy) {
                SafariView(url: URL(string: "https://example.com/privacy")!)
            }
        }
    }
}

struct SettingCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                content
            }
        }
        .padding(.vertical, 8)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
} 