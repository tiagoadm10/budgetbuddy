import Foundation

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let userDefaultsKey = "registeredUsers"
    
    // Dictionary to store users with email as key
    private var users: [String: User] {
        get {
            if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
               let decoded = try? JSONDecoder().decode([String: User].self, from: data) {
                return decoded
            }
            return [:]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            }
        }
    }
    
    func signup(email: String, name: String, password: String) -> Bool {
        // Check if email already exists
        if users[email.lowercased()] != nil {
            return false
        }
        
        let newUser = User(
            id: UUID(),
            email: email.lowercased(),
            name: name,
            password: password // In a real app, you should hash this password
        )
        
        // Store the new user
        var updatedUsers = users
        updatedUsers[email.lowercased()] = newUser
        users = updatedUsers
        
        // Auto login after signup
        currentUser = newUser
        isAuthenticated = true
        
        return true
    }
    
    func login(email: String, password: String) -> Bool {
        if let user = users[email.lowercased()],
           user.password == password { // In a real app, verify against hashed password
            currentUser = user
            isAuthenticated = true
            return true
        }
        return false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}

class ExpenseManager: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet {
            saveExpenses()
        }
    }
    @Published var income: [Income] = [] {
        didSet {
            saveIncome()
        }
    }
    @Published var selectedCurrency: Currency = .usd {
        didSet {
            UserDefaults.standard.set(selectedCurrency.rawValue, forKey: "\(userEmail)_currency")
        }
    }
    
    private let userEmail: String
    
    init(userEmail: String) {
        self.userEmail = userEmail
        loadData()
    }
    
    private func loadData() {
        // Load expenses
        if let data = UserDefaults.standard.data(forKey: "\(userEmail)_expenses"),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
        
        // Load income
        if let data = UserDefaults.standard.data(forKey: "\(userEmail)_income"),
           let decoded = try? JSONDecoder().decode([Income].self, from: data) {
            income = decoded
        }
        
        // Load currency preference
        if let currencyString = UserDefaults.standard.string(forKey: "\(userEmail)_currency"),
           let currency = Currency(rawValue: currencyString) {
            selectedCurrency = currency
        }
    }
    
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "\(userEmail)_expenses")
        }
    }
    
    private func saveIncome() {
        if let encoded = try? JSONEncoder().encode(income) {
            UserDefaults.standard.set(encoded, forKey: "\(userEmail)_income")
        }
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalIncome: Double {
        income.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpenses
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }
    
    func addIncome(_ income: Income) {
        self.income.append(income)
    }
    
    func expensesByCategory(_ category: Category) -> Double {
        expenses.filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
}
