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
                Section {
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
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveExpense()
                }
            )
        }
    }
    
    private func saveExpense() {
        guard let amountDouble = Double(amount), !note.isEmpty else { return }
        
        expenseManager.addExpense(
            amount: amountDouble,
            category: category,
            note: note
        )
        
        dismiss()
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
                Section(header: Text("Income Details")) {
                    HStack {
                        Text(expenseManager.selectedCurrency.symbol)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    TextField("Note", text: $note)
                }
            }
            .navigationTitle("Add Income")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveIncome()
                }
            )
        }
    }
    
    private func saveIncome() {
        guard let amountDouble = Double(amount), !note.isEmpty else { return }
        
        expenseManager.addIncome(
            amount: amountDouble,
            note: note
        )
        
        dismiss()
    }
}

#if DEBUG
struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(expenseManager: ExpenseManager(userEmail: "test@test.com"))
    }
}

struct AddIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        AddIncomeView(expenseManager: ExpenseManager(userEmail: "test@test.com"))
    }
}
#endif
