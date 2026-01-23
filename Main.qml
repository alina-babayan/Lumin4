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
        initialItem: authController.isLoggedIn ? dashboardComponent : loginComponent
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

    Component {
        id: dashboardComponent
        DashboardPage {
            onLogout: {
                stackView.clear()
                stackView.push(loginComponent)
            }
            onNavigateToInstructors: {
                // FIXED: Actually navigate to Instructors page
                stackView.push(instructorsComponent)
            }
        }
    }

    // NEW: Add Instructors component
    Component {
        id: instructorsComponent
        InstructorsPage {
            // Add back navigation if needed
            // onNavigateBack: stackView.pop()
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
