import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 1400
    height: 800
    minimumWidth: 1200
    minimumHeight: 700
    title: "Lumin"

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: loginPageComponent

        Component.onCompleted: {
            if (authController && authController.isLoggedIn) {
                stack.replace(dashboardPageComponent)
            }
        }
    }

    Component {
        id: loginPageComponent
        LoginPage {
            onNavigateToOtp: stack.push(otpPageComponent)
            onNavigateToForgotPassword: stack.push(forgotPasswordPageComponent)
            onNavigateToRegister: stack.push(registerPageComponent)
        }
    }

    Component {
        id: otpPageComponent
        OtpPage {
            onNavigateBack: stack.pop()
        }
    }

    Component {
        id: forgotPasswordPageComponent
        ForgotPasswordPage {
            onNavigateBack: stack.pop()
        }
    }

    Component {
        id: registerPageComponent
        RegisterPage {
            onNavigateBack: stack.pop()
        }
    }

    Component {
        id: dashboardPageComponent
        DashboardPage {}
    }

    SuccessDialog {
        id: successDialog
        onAccepted: {
            authController.clearError()
            stack.pop()
        }
    }

    Connections {
        target: authController

        function onLoginSuccessful() {
            stack.push(otpPageComponent)
        }

        function onOtpVerified() {
            stack.replace(dashboardPageComponent)
        }

        function onRegistrationSuccessful() {
            successDialog.open()
        }

        function onLoggedOut() {
            stack.replace(loginPageComponent)
        }
    }
}
