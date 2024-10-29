import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    let currency: Currency
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.category.rawValue)
                Text(expense.note)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(currency.symbol)\(expense.amount, specifier: "%.2f")")
        }
    }
}

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var expenseManager: ExpenseManager
    
    @State private var amount = ""
    @State private var category = Category.other
    @State private var note = ""
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text(expenseManager.selectedCurrency.symbol)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Picker("Category", selection: $category) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                
                TextField("Note", text: $note)
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if let amount = Double(amount) {
                        let expense = Expense(amount: amount,
                                           category: category,
                                           date: Date(),
                                           note: note)
                        expenseManager.addExpense(expense)
                        dismiss()
                    }
                }
            )
        }
    }
}

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var expenseManager: ExpenseManager
    
    @State private var amount = ""
    @State private var note = ""
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text(expenseManager.selectedCurrency.symbol)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                TextField("Note", text: $note)
            }
            .navigationTitle("Add Income")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if let amount = Double(amount) {
                        let income = Income(amount: amount,
                                         date: Date(),
                                         note: note)
                        expenseManager.addIncome(income)
                        dismiss()
                    }
                }
            )
        }
    }
}
