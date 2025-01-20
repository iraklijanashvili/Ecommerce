import Foundation

struct NotImplementedError: Error {
    let message: String
    
    init(_ message: String = "This feature is not implemented yet") {
        self.message = message
    }
} 
