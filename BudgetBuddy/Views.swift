import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserManager()
    
    var body: some View {
        Group {
            if let user = userManager.currentUser {
                ExpenseView(expenseManager: ExpenseManager(userEmail: user.email), userManager: userManager)
            } else {
                LoginView(userManager: userManager)
            }
        }
    }
}

struct ExpenseView: View {
    @ObservedObject var expenseManager: ExpenseManager // Change to @ObservedObject since it's passed in
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
                    }
                }
                
                // Expenses by Category
                Section(header: Text("Expenses by Category")) {
                    ForEach(Category.allCases, id: \.self) { category in
                        HStack {
                            Text(category.rawValue)
                            Spacer()
                            Text("\(expenseManager.selectedCurrency.symbol)\(expenseManager.expensesByCategory(category), specifier: "%.2f")")
                        }
                    }
                }
                
                // Recent Expenses
                Section(header: Text("Recent Expenses")) {
                    ForEach(expenseManager.expenses, id: \.id) { expense in
                        ExpenseRow(expense: expense, currency: expenseManager.selectedCurrency)
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
