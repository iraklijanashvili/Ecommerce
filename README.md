# GemStore - iOS E-commerce Application


## 📱 Overview

GemStore is a modern iOS e-commerce application built with a hybrid approach using both SwiftUI and UIKit. The app provides a seamless shopping experience with features like product discovery, detailed product views, shopping cart management, and secure authentication.

## ✨ Key Features

- 🏠 **Home Feed**: Curated product listings with category filtering
- 🔍 **Product Discovery**: Advanced search and filtering capabilities
- 🛍️ **Product Details**: Comprehensive product information and image galleries
- 🛒 **Shopping Cart**: Real-time cart management with price calculations
- 👤 **User Authentication**: Secure sign-up and login functionality
- 📦 **Order Management**: Track and manage customer orders
- 🔄 **Seamless Integration**: Hybrid architecture combining SwiftUI and UIKit

## 🏗️ Architecture

The application follows the MVVM (Model-View-ViewModel) architecture pattern and is organized into the following main components:

```
GemStore/
├── App/
├── Features/
│   ├── Home/
│   ├── Auth/
│   ├── ProductDetails/
│   ├── Orders/
│   ├── Discover/
│   └── Collection/
└── Core/
    ├── Services/
    └── Repositories/
```

## 🛠️ Technical Stack

- **Minimum iOS Version**: iOS 15.0+
- **Architecture Pattern**: MVVM
- **UI Frameworks**: 
  - SwiftUI for modern interfaces
  - UIKit for complex interactions
- **Data Persistence**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Dependency Management**: Swift Package Manager
- **Async Operations**: Swift async/await


### Prerequisites

- Xcode 14.0+
- iOS 15.0+
- Swift 5.5+

### Installation

1. Clone the repository
```bash
git clone https://github.com/iraklijanashvili/Ecommerce.git
```

2. Navigate to the project directory
```bash
cd Ecommerce

```

3. Install dependencies (if using CocoaPods)
```bash
pod install
```

4. Open Ecommerce.xcodeproj in Xcode

5. Configure Firebase:
   - Add your `GoogleService-Info.plist`
   - Update Firebase configuration

6. Build and run the project

## 🔐 Configuration

To run this project, you'll need to set up the following:

1. Firebase Configuration
2. API Keys
3. Environment Variables


## 👥 Author

- Irakli Janashvili


