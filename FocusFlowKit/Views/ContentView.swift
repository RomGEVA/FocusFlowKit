//
//  ContentView.swift
//  FocusFlow
//
//

import SwiftUI



struct ContentView: View {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @StateObject private var viewModel = FocusFlowViewModel()
    
    var body: some View {
        if hasSeenOnboarding {
            TabView {
                TimerView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
