#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include <QObject>
#include <QJsonObject>
#include "apimanager.h"
#include <QString>
class AuthController : public QObject
{
    Q_OBJECT

    // Properties exposed to QML
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(QString maskedEmail READ maskedEmail NOTIFY maskedEmailChanged)
    Q_PROPERTY(QString userName READ userName NOTIFY userNameChanged)
    Q_PROPERTY(QString userEmail READ userEmail NOTIFY userEmailChanged)
    Q_PROPERTY(QString userImage READ userImage NOTIFY userImageChanged)
    Q_PROPERTY(QString userId READ userId NOTIFY userIdChanged)

public:
    explicit AuthController(QObject *parent = nullptr);
    ~AuthController();

    // Property getters
    bool isLoading() const { return m_isLoading; }
    bool isLoggedIn() const { return m_api->isLoggedIn(); }
    QString errorMessage() const { return m_errorMessage; }
    QString maskedEmail() const { return m_maskedEmail; }
    QString userName() const { return m_userName; }
    QString userEmail() const { return m_userEmail; }
    QString userImage() const { return m_userImage; }
    QString userId() const { return m_userId; }

    // Methods exposed to QML
    Q_INVOKABLE void login(const QString &email, const QString &password);
    Q_INVOKABLE void verifyOtp(const QString &code);
    Q_INVOKABLE void resendOtp();
    Q_INVOKABLE void registerUser(const QString &firstName, const QString &lastName,
                                  const QString &email, const QString &password);
    Q_INVOKABLE void forgotPassword(const QString &email);
    Q_INVOKABLE void resetPassword(const QString &token, const QString &newPassword);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void loadProfile();
    Q_INVOKABLE void changePassword(const QString &currentPassword, const QString &newPassword);

signals:
    // Property change signals
    void isLoadingChanged();
    void isLoggedInChanged();
    void errorMessageChanged();
    void maskedEmailChanged();
    void userNameChanged();
    void userEmailChanged();
    void userImageChanged();
    void userIdChanged();

    // Navigation signals (for QML to handle screen transitions)
    void loginSuccessful();          // Navigate to OTP screen
    void otpVerified();              // Navigate to dashboard
    void registrationSuccessful();   // Show success message
    void passwordResetSent();        // Show confirmation
    void passwordResetSuccessful();  // Navigate to login
    void passwordChanged();          // Show confirmation
    void loggedOut();                // Navigate to login

private slots:
    // Handle API responses
    void onLoginSuccess(const QString &sessionToken, const QString &maskedEmail);
    void onLoginFailed(const QString &errorCode, const QString &errorMessage);
    void onOtpVerifySuccess(const QString &accessToken, const QString &refreshToken, const QJsonObject &user);
    void onOtpVerifyFailed(const QString &errorCode, const QString &errorMessage);
    void onRegisterSuccess(const QString &userId, const QString &email);
    void onRegisterFailed(const QString &errorCode, const QString &errorMessage);
    void onForgotPasswordSuccess(const QString &message);
    void onForgotPasswordFailed(const QString &errorCode, const QString &errorMessage);
    void onResetPasswordSuccess();
    void onResetPasswordFailed(const QString &errorCode, const QString &errorMessage);
    void onProfileLoaded(const QJsonObject &user);
    void onProfileLoadFailed(const QString &errorMessage);
    void onPasswordChanged();
    void onPasswordChangeFailed(const QString &errorMessage);
    void onRequestStarted();
    void onRequestFinished();

private:
    ApiManager *m_api;

    // State
    bool m_isLoading;
    QString m_errorMessage;
    QString m_sessionToken;
    QString m_maskedEmail;

    // User info
    QString m_userName;
    QString m_userEmail;
    QString m_userImage;
    QString m_userId;

    // Cached credentials for resend
    QString m_lastEmail;
    QString m_lastPassword;

    // Helper methods
    void setLoading(bool loading);
    void setError(const QString &error);
    void setUserFromJson(const QJsonObject &user);
    QString formatError(const QString &code, const QString &message);
};

#endif // AUTHCONTROLLER_H
