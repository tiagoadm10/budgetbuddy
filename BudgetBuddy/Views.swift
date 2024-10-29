import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserManager()
    
    var body: some View {
        Group {
            if let user = userManager.currentUser {
                MainTabView(expenseManager: ExpenseManager(userEmail: user.email), userManager: userManager)
            } else {
                LoginView(userManager: userManager)
            }
        }
    }
}

// New MainTabView to handle navigation
struct MainTabView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @ObservedObject var userManager: UserManager
    
    var body: some View {
        TabView {
            ExpenseView(expenseManager: expenseManager, userManager: userManager)
                .tabItem {
                    Label("Overview", systemImage: "chart.pie")
                }
            
            ExpenseSummaryView(expenseManager: expenseManager)
                .tabItem {
                    Label("Summary", systemImage: "list.bullet.clipboard")
                }
        }
    }
}

struct ExpenseView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @ObservedObject var userManager: UserManager
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            List {
                // Summary Section
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Total Income")
                        Spacer()
                        Text("\(expenseManager.selectedCurrency.symbol)\(expenseManager.totalIncome, specifier: "%.2f")")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Total Expenses")
                        Spacer()
                        Text("\(expenseManager.selectedCurrency.symbol)\(expenseManager.totalExpenses, specifier: "%.2f")")
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Balance")
                        Spacer()
                        Text("\(expenseManager.selectedCurrency.symbol)\(expenseManager.balance, specifier: "%.2f")")
                            .foregroundColor(expenseManager.balance >= 0 ? .green : .red)
                            .bold()
                    }
                }
                
                // Recent Expenses
                Section(header: Text("Recent Expenses")) {
                    ForEach(expenseManager.expenses.prefix(5), id: \.id) { expense in
                        ExpenseRow(expense: expense, currency: expenseManager.selectedCurrency)
                    }
                    
                    if expenseManager.expenses.count > 5 {
                        NavigationLink("See All Expenses", destination: AllExpensesView(expenseManager: expenseManager))
                    }
                }
            }
            .navigationTitle("Expense Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Expense") {
                            showingAddExpense = true
                        }
                        Button("Add Income") {
                            showingAddIncome = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(expenseManager: expenseManager)
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView(expenseManager: expenseManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(expenseManager: expenseManager, userManager: userManager)
        }
    }
}

// New view for showing all expenses
struct AllExpensesView: View {
    @ObservedObject var expenseManager: ExpenseManager
    
    var body: some View {
        List {
            ForEach(expenseManager.expenses) { expense in
                ExpenseRow(expense: expense, currency: expenseManager.selectedCurrency)
            }
        }
        .navigationTitle("All Expenses")
    }
}

struct ExpenseSummaryView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @State private var selectedInterval: TimeInterval = .daily
    @State private var selectedDate = Date()
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    
    enum TimeInterval {
        case daily
        case weekly
        case monthly
        case custom
    }
    
    var expenses: [Expense] {
        switch selectedInterval {
        case .daily:
            return expenseManager.getDailyExpenses(for: selectedDate)
        case .weekly:
            return expenseManager.getWeeklyExpenses(for: selectedDate)
        case .monthly:
            return expenseManager.getMonthlyExpenses(for: selectedDate)
        case .custom:
            return expenseManager.getExpensesForPeriod(start: customStartDate, end: customEndDate)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Time Period")) {
                    Picker("Interval", selection: $selectedInterval) {
                        Text("Daily").tag(TimeInterval.daily)
                        Text("Weekly").tag(TimeInterval.weekly)
                        Text("Monthly").tag(TimeInterval.monthly)
                        Text("Custom").tag(TimeInterval.custom)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selectedInterval != .custom {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                    } else {
                        DatePicker("Start Date", selection: $customStartDate, displayedComponents: [.date])
                        DatePicker("End Date", selection: $customEndDate, displayedComponents: [.date])
                    }
                }
                
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Total Expenses")
                        Spacer()
                        Text("\(expenseManager.selectedCurrency.symbol)\(expenseManager.getTotalExpenses(for: expenses), specifier: "%.2f")")
                            .bold()
                    }
                }
                
                Section(header: Text("By Category")) {
                    ForEach(Category.allCases, id: \.self) { category in
                        let amount = expenseManager.getExpensesByCategory(for: expenses)[category] ?? 0
                        if amount > 0 {
                            HStack {
                                Text(category.rawValue)
                                Spacer()
                                Text("\(expenseManager.selectedCurrency.symbol)\(amount, specifier: "%.2f")")
                            }
                        }
                    }
                }
                
                Section(header: Text("Expenses")) {
                    ForEach(expenses) { expense in
                        ExpenseRow(expense: expense, currency: expenseManager.selectedCurrency)
                    }
                }
            }
            .navigationTitle("Expense Summary")
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
