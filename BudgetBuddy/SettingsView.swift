import SwiftUI

struct SettingsView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    if let user = userManager.currentUser {
                        Text("Name: \(user.name)")
                        Text("Email: \(user.email)")
                    }
                    
                    Button("Logout") {
                        userManager.logout()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Currency")) {
                    Picker("Currency", selection: $expenseManager.selectedCurrency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}
