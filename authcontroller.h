#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include <QJsonObject>
#include <QObject>
#include <QString>
#include "apimanager.h"

class AuthController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(QString maskedEmail READ maskedEmail NOTIFY maskedEmailChanged)
    Q_PROPERTY(QString userName READ userName NOTIFY userNameChanged)
    Q_PROPERTY(QString userEmail READ userEmail NOTIFY userEmailChanged)
    Q_PROPERTY(QString userImage READ userImage NOTIFY userImageChanged)
    Q_PROPERTY(QString userId READ userId NOTIFY userIdChanged)
    Q_PROPERTY(QString accessToken READ accessToken NOTIFY accessTokenChanged)  // ← new

public:
    explicit AuthController(QObject *parent = nullptr);
    ~AuthController();

    bool isLoading() const { return m_isLoading; }
    bool isLoggedIn() const { return m_api->isLoggedIn(); }
    QString errorMessage() const { return m_errorMessage; }
    QString maskedEmail() const { return m_maskedEmail; }
    QString userName() const { return m_userName; }
    QString userEmail() const { return m_userEmail; }
    QString userImage() const { return m_userImage; }
    QString userId() const { return m_userId; }
    QString accessToken() const { return m_api->accessToken(); }  // ← new

    Q_INVOKABLE void login(const QString &email, const QString &password);
    Q_INVOKABLE void verifyOtp(const QString &code);
    Q_INVOKABLE void resendOtp();
    Q_INVOKABLE void registerUser(const QString &firstName,
                                  const QString &lastName,
                                  const QString &email,
                                  const QString &password);
    Q_INVOKABLE void forgotPassword(const QString &email);
    Q_INVOKABLE void resetPassword(const QString &token, const QString &newPassword);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void loadProfile();
    Q_INVOKABLE void changePassword(const QString &currentPassword, const QString &newPassword);
    Q_INVOKABLE void updateProfile(const QString &firstName, const QString &lastName);  // ← new

signals:
    void isLoadingChanged();
    void isLoggedInChanged();
    void errorMessageChanged();
    void maskedEmailChanged();
    void userNameChanged();
    void userEmailChanged();
    void userImageChanged();
    void userIdChanged();
    void accessTokenChanged();   // ← new: emitted after OTP success so all controllers reload tokens

    void loginSuccessful();
    void otpVerified();
    void registrationSuccessful();
    void passwordResetSent();
    void passwordResetSuccessful();
    void passwordChanged();
    void profileUpdated();       // ← new
    void loggedOut();

private slots:
    void onLoginSuccess(const QString &sessionToken, const QString &maskedEmail);
    void onLoginFailed(const QString &errorCode, const QString &errorMessage);
    void onOtpVerifySuccess(const QString &accessToken,
                            const QString &refreshToken,
                            const QJsonObject &user);
    void onOtpVerifyFailed(const QString &errorCode, const QString &errorMessage);
    void onRegisterSuccess(const QString &userId, const QString &email);
    void onRegisterFailed(const QString &errorCode, const QString &errorMessage);
    void onForgotPasswordSuccess(const QString &message);
    void onForgotPasswordFailed(const QString &errorCode, const QString &errorMessage);
    void onResetPasswordSuccess();
    void onResetPasswordFailed(const QString &errorCode, const QString &errorMessage);
    void onProfileLoaded(const QJsonObject &user);
    void onProfileLoadFailed(const QString &errorMessage);
    void onProfileUpdated(const QJsonObject &user);     // ← new
    void onProfileUpdateFailed(const QString &errorMessage); // ← new
    void onPasswordChanged();
    void onPasswordChangeFailed(const QString &errorMessage);
    void onRequestStarted();
    void onRequestFinished();

private:
    ApiManager *m_api;

    bool m_isLoading;
    QString m_errorMessage;
    QString m_sessionToken;
    QString m_maskedEmail;

    QString m_userName;
    QString m_userEmail;
    QString m_userImage;
    QString m_userId;

    QString m_lastEmail;
    QString m_lastPassword;

    void setLoading(bool loading);
    void setError(const QString &error);
    void setUserFromJson(const QJsonObject &user);
    QString formatError(const QString &code, const QString &message);
};

#endif // AUTHCONTROLLER_H
