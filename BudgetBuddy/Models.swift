import Foundation

enum Currency: String, Codable, CaseIterable {
    case usd = "USD ($)"
    case eur = "EUR (€)"
    case gbp = "GBP (£)"
    case jpy = "JPY (¥)"
    case aud = "AUD (A$)"
    case cad = "CAD (C$)"
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .aud: return "A$"
        case .cad: return "C$"
        }
    }
}

struct User: Codable, Identifiable {
    var id: UUID
    var email: String
    var name: String
    var password: String
    
    init(id: UUID = UUID(), email: String, name: String, password: String) {
        self.id = id
        self.email = email
        self.name = name
        self.password = password
    }
}

struct Expense: Codable, Identifiable {
    var id: UUID // Change from let to var for Codable
    var amount: Double
    var category: Category
    var date: Date
    var note: String
    
    // Add initializer
    init(id: UUID = UUID(), amount: Double, category: Category, date: Date, note: String) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
    }
}

enum Category: String, Codable, CaseIterable {
    case housing = "Housing"
    case utilities = "Utilities"
    case food = "Food"
    case transportation = "Transportation"
    case healthcare = "Healthcare"
    case entertainment = "Entertainment"
    case other = "Other"
}

struct Income: Codable, Identifiable {
    var id: UUID // Change from let to var for Codable
    var amount: Double
    var date: Date
    var note: String
    
    // Add initializer
    init(id: UUID = UUID(), amount: Double, date: Date, note: String) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }
}
