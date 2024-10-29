import SwiftUI

struct LoginView: View {
    @ObservedObject var userManager: UserManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignup = false
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                }
                
                Button("Login") {
                    if userManager.login(email: email, password: password) {
                        // Successfully logged in
                    } else {
                        showingError = true
                    }
                }
                
                Button("Create Account") {
                    showingSignup = true
                }
            }
            .navigationTitle("Login")
            .alert("Invalid Credentials", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            }
            .sheet(isPresented: $showingSignup) {
                SignupView(userManager: userManager)
            }
        }
    }
}

struct SignupView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Name", text: $name)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Button("Create Account") {
                    if password == confirmPassword {
                        if userManager.signup(email: email, name: name, password: password) {
                            dismiss()
                        } else {
                            showingError = true
                        }
                    }
                }
                .disabled(password != confirmPassword || email.isEmpty || name.isEmpty || password.isEmpty)
            }
            .navigationTitle("Create Account")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .alert("Error Creating Account", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
