import SwiftUI


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
                            .onChange(of: amount) { oldValue, newValue in
                                validateAmount(newValue)
                            }
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    DatePicker("Date of Expense",
                               selection: $expenseManager.selectedDate,
                               displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .padding()
                    
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
    
    private func validateAmount(_ newValue: String) {
        let filtered = newValue.filter { "0123456789.,".contains($0) }
        let decimalPoints = filtered.filter { $0 == "." || $0 == "," }.count
        
        if decimalPoints <= 1 {
            let parts = filtered.split { $0 == "." || $0 == "," }
            if parts.count > 1 {
                // Limit to 2 decimal places
                let wholePart = parts[0]
                let decimalPart = String(parts[1].prefix(2))
                amount = "\(wholePart),\(decimalPart)"
            } else {
                amount = filtered
            }
        }
    }
    
    private func saveExpense() {
        guard let amountDouble = Double(amount.replacingOccurrences(of: ",", with: ".")),
              amountDouble > 0 else { return }
        
        // Round to 2 decimal places
        let roundedAmount = (amountDouble * 100).rounded() / 100
        
        expenseManager.addExpense(
            amount: roundedAmount,
            category: category,
            note: note.isEmpty ? "-" : note
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
