import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    width: 1400
    height: 900
    visible: true
    title: "Picsart Academy - Lumin"

    StackView {
        id: stackView
        anchors.fill: parent
        // ALWAYS start with login page
        initialItem: loginComponent
    }

    Component {
        id: loginComponent
        LoginPage {
            onNavigateToOtp: stackView.push(otpComponent)
            onNavigateToForgotPassword: stackView.push(forgotPasswordComponent)
            onNavigateToRegister: stackView.push(registerComponent)
        }
    }

    Component {
        id: otpComponent
        OtpPage {
            onNavigateBack: stackView.pop()
        }
    }

    Component {
        id: registerComponent
        RegisterPage {
            onNavigateBack: stackView.pop()
            onShowSuccessDialog: successDialog.open()
        }
    }

    Component {
        id: forgotPasswordComponent
        ForgotPasswordPage {
            onNavigateBack: stackView.pop()
        }
    }

    // DashboardPage owns the sidebar + internal StackLayout.
    // All admin pages (Instructors, Courses, Users, Transactions, Notifications)
    // live inside DashboardPage — Main does NOT push them separately.
    Component {
        id: dashboardComponent
        DashboardPage {
            onLogout: {
                authController.logout()
                stackView.clear()
                stackView.push(loginComponent)
            }
        }
    }

    RegistrationSuccessDialog {
        id: successDialog
        onAccepted: {
            stackView.clear()
            stackView.push(loginComponent)
        }
    }

    Connections {
        target: authController

        function onLoginSuccessful() {
            stackView.push(otpComponent)
        }

        function onOtpVerified() {
            stackView.clear()
            stackView.push(dashboardComponent)
        }

        function onRegistrationSuccessful() {
            successDialog.open()
        }

        function onLoggedOut() {
            stackView.clear()
            stackView.push(loginComponent)
        }
    }
}


