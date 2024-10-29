import SwiftUI

struct LoginView: View {
    @StateObject var userManager = UserManager() // Change to StateObject
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
            } message: {
                Text("Please check your email and password and try again.")
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
    @State private var errorMessage = ""
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !name.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        email.contains("@")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Section {
                    Button("Create Account") {
                        if password == confirmPassword {
                            if userManager.signup(email: email, name: name, password: password) {
                                dismiss()
                            } else {
                                errorMessage = "An account with this email already exists."
                                showingError = true
                            }
                        } else {
                            errorMessage = "Passwords don't match."
                            showingError = true
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .alert("Error Creating Account", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(userManager: UserManager())
    }
}
#endif
