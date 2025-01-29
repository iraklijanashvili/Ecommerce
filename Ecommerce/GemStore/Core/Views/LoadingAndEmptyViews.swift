import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading...")
                .foregroundColor(.gray)
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    init(
        title: String = "No Items Found",
        message: String = "There are no items to display at this time.",
        systemImage: String = "doc.text.magnifyingglass"
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 100)
    }
}

struct RetryView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error Occurred")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
} 