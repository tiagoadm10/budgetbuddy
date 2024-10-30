import Foundation

// MARK: - DateIntervalType Enum
enum DateIntervalType: Hashable {
    case daily
    case weekly
    case monthly
    case custom(start: Date, end: Date)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .daily: hasher.combine(0)
        case .weekly: hasher.combine(1)
        case .monthly: hasher.combine(2)
        case .custom(let start, let end):
            hasher.combine(3)
            hasher.combine(start)
            hasher.combine(end)
        }
    }
    
    static func == (lhs: DateIntervalType, rhs: DateIntervalType) -> Bool {
        switch (lhs, rhs) {
        case (.daily, .daily): return true
        case (.weekly, .weekly): return true
        case (.monthly, .monthly): return true
        case (.custom(let lStart, let lEnd), .custom(let rStart, let rEnd)):
            return lStart == rStart && lEnd == rEnd
        default: return false
        }
    }
}

// MARK: - ExpenseManager
class ExpenseManager: ObservableObject {
    @Published private(set) var expenses: [Expense] = []
    @Published private(set) var income: [Income] = []
    @Published var selectedCurrency: Currency = .usd
    @Published var selectedDate = Date()
    
    private let userEmail: String
    
    init(userEmail: String) {
        self.userEmail = userEmail
        loadData()
    }
    
    // MARK: - Expense Management
    func addExpense(amount: Double, category: Category, note: String) {
            let expense = Expense(
                amount: amount,
                category: category,
                note: note,
                date: selectedDate, // This ensures we use the date selected in the DatePicker
                currency: selectedCurrency
            )
            expenses.append(expense)
            saveExpenses()
        }
    
    
    // MARK: - Income Management
    func addIncome(amount: Double, note: String) {
        let income = Income(
            amount: amount,
            date: Date(),
            note: note
        )
        self.income.append(income)
        saveIncome()
    }
    
    // MARK: - Summary Methods
    func getDailyExpenses(for date: Date = Date()) -> [Expense] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        return expenses.filter { expense in
            (startOfDay...endOfDay).contains(expense.date)
        }
    }
    
    func getWeeklyExpenses(for date: Date = Date()) -> [Expense] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }
        return getExpensesForPeriod(start: weekInterval.start, end: weekInterval.end)
    }
    
    func getMonthlyExpenses(for date: Date = Date()) -> [Expense] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }
        return getExpensesForPeriod(start: monthInterval.start, end: monthInterval.end)
    }
    
    func getExpensesForPeriod(start: Date, end: Date) -> [Expense] {
        expenses.filter { expense in
            (start...end).contains(expense.date)
        }
    }
    
    // MARK: - Calculations
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalIncome: Double {
        income.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpenses
    }
    
    func getTotalExpenses(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func getExpensesByCategory(for expenses: [Expense]) -> [Category: Double] {
        var categoryTotals: [Category: Double] = [:]
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }
        return categoryTotals
    }
    
    func expensesByCategory(_ category: Category) -> Double {
        expenses.filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Helper Methods
    func createDateInterval(for type: DateIntervalType, baseDate: Date = Date()) -> DateInterval {
        let calendar = Calendar.current
        
        switch type {
        case .daily:
            let startOfDay = calendar.startOfDay(for: baseDate)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                return DateInterval(start: baseDate, duration: 86400)
            }
            return DateInterval(start: startOfDay, end: endOfDay)
            
        case .weekly:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: baseDate) else {
                return DateInterval(start: baseDate, duration: 604800)
            }
            return weekInterval
            
        case .monthly:
            guard let monthInterval = calendar.dateInterval(of: .month, for: baseDate) else {
                return DateInterval(start: baseDate, duration: 2592000)
            }
            return monthInterval
            
        case .custom(let start, let end):
            return DateInterval(start: start, end: end)
        }
    }
    
    // MARK: - Data Persistence
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "\(userEmail)_expenses"),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: "\(userEmail)_income"),
           let decoded = try? JSONDecoder().decode([Income].self, from: data) {
            income = decoded
        }
        
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
}

// MARK: - UserManager
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published private var users: [User] = []
    
    init() {
        loadUsers()
    }
    
    // MARK: - Authentication Methods
    func login(email: String, password: String) -> Bool {
        if let user = users.first(where: { $0.email == email && $0.password == password }) {
            currentUser = user
            return true
        }
        return false
    }
    
    func signup(email: String, name: String, password: String) -> Bool {
        if users.contains(where: { $0.email == email }) {
            return false
        }
        
        let newUser = User(email: email, name: name, password: password)
        users.append(newUser)
        saveUsers()
        currentUser = newUser
        return true
    }
    
    func logout() {
        currentUser = nil
    }
    
    // MARK: - Data Persistence
    private func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: "users"),
           let decoded = try? JSONDecoder().decode([User].self, from: data) {
            users = decoded
        }
    }
    
    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: "users")
        }
    }
}
