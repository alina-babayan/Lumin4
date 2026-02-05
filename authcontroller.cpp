#include "authcontroller.h"
#include <QDebug>

AuthController::AuthController(QObject *parent)
    : QObject(parent)
    , m_api(new ApiManager(this))
    , m_isLoading(false)
{

    connect(m_api, &ApiManager::loginSuccess,
            this, &AuthController::onLoginSuccess);
    connect(m_api, &ApiManager::loginFailed,
            this, &AuthController::onLoginFailed);

    connect(m_api, &ApiManager::otpVerifySuccess, this, &AuthController::onOtpVerifySuccess);
    connect(m_api, &ApiManager::otpVerifyFailed, this, &AuthController::onOtpVerifyFailed);

    connect(m_api, &ApiManager::registerSuccess, this, &AuthController::onRegisterSuccess);
    connect(m_api, &ApiManager::registerFailed, this, &AuthController::onRegisterFailed);

    connect(m_api,
            &ApiManager::forgotPasswordSuccess,
            this,
            &AuthController::onForgotPasswordSuccess);
    connect(m_api, &ApiManager::forgotPasswordFailed, this, &AuthController::onForgotPasswordFailed);

    connect(m_api, &ApiManager::resetPasswordSuccess, this, &AuthController::onResetPasswordSuccess);
    connect(m_api, &ApiManager::resetPasswordFailed, this, &AuthController::onResetPasswordFailed);


    connect(m_api, &ApiManager::profileLoaded,
            this, &AuthController::onProfileLoaded);
    connect(m_api, &ApiManager::profileLoadFailed,
            this, &AuthController::onProfileLoadFailed);

    connect(m_api, &ApiManager::passwordChanged, this, &AuthController::onPasswordChanged);
    connect(m_api, &ApiManager::passwordChangeFailed, this, &AuthController::onPasswordChangeFailed);


    connect(m_api, &ApiManager::requestStarted,
            this, &AuthController::onRequestStarted);
    connect(m_api, &ApiManager::requestFinished,
            this, &AuthController::onRequestFinished);

    if (m_api->isLoggedIn()) {
        loadProfile();
    }
}


AuthController::~AuthController()
{
}


void AuthController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void AuthController::setError(const QString &error)
{
    if (m_errorMessage != error) {
        m_errorMessage = error;
        emit errorMessageChanged();
    }
}

void AuthController::setUserFromJson(const QJsonObject &user)
{
    QString firstName = user["firstName"].toString();
    QString lastName = user["lastName"].toString();
    QString fullName = firstName;
    if (!lastName.isEmpty()) {
        fullName += " " + lastName;
    }

    if (m_userName != fullName) {
        m_userName = fullName;
        emit userNameChanged();
    }

    QString email = user["email"].toString();
    if (m_userEmail != email) {
        m_userEmail = email;
        emit userEmailChanged();
    }

    QString image = user["image"].toString();
    if (m_userImage != image) {
        m_userImage = image;
        emit userImageChanged();
    }

    QString id = user["id"].toString();
    if (m_userId != id) {
        m_userId = id;
        emit userIdChanged();
    }
}


void AuthController::login(const QString &email, const QString &password)
{
    clearError();

    if (email.trimmed().isEmpty()) {
        setError("Please enter your email address.");
        return;
    }

    if (password.isEmpty()) {
        setError("Please enter your password.");
        return;
    }

    m_lastEmail = email.trimmed();
    m_lastPassword = password;

    qDebug() << "AuthController::login - Starting login for:" << m_lastEmail;
    m_api->login(m_lastEmail, password);
}

void AuthController::verifyOtp(const QString &code)
{
    clearError();

    qDebug() << "AuthController::verifyOtp - Code length:" << code.length();
    qDebug() << "AuthController::verifyOtp - Session token empty?" << m_sessionToken.isEmpty();
    qDebug() << "AuthController::verifyOtp - Session token (first 20 chars):"
             << m_sessionToken.left(20);

    if (code.length() != 6) {
        setError("Please enter the complete 6-digit code.");
        return;
    }

    if (m_sessionToken.isEmpty()) {
        setError("Session expired. Please login again.");
        qDebug() << "AuthController::verifyOtp - ERROR: Session token is empty!";
        emit loggedOut();
        return;
    }

    qDebug() << "AuthController::verifyOtp - Calling API verifyOtp";
    m_api->verifyOtp(m_sessionToken, code);
}

void AuthController::resendOtp()
{
    clearError();

    qDebug() << "AuthController::resendOtp - Last email:" << m_lastEmail;
    qDebug() << "AuthController::resendOtp - Last password empty?" << m_lastPassword.isEmpty();

    if (m_lastEmail.isEmpty() || m_lastPassword.isEmpty()) {
        setError("Session expired. Please login again.");
        emit loggedOut();
        return;
    }

    qDebug() << "AuthController::resendOtp - Calling login again";
    m_api->login(m_lastEmail, m_lastPassword);
}

void AuthController::registerUser(const QString &firstName, const QString &lastName,
                                  const QString &email, const QString &password)
{
    clearError();

    if (firstName.trimmed().length() < 2) {
        setError("First name must be at least 2 characters.");
        return;
    }

    if (lastName.trimmed().length() < 2) {
        setError("Last name must be at least 2 characters.");
        return;
    }

    if (!email.contains("@") || !email.contains(".")) {
        setError("Please enter a valid email address.");
        return;
    }

    if (password.length() < 8) {
        setError("Password must be at least 8 characters.");
        return;
    }

    m_api->registerUser(firstName.trimmed(), lastName.trimmed(), email.trimmed(), password);
}

void AuthController::forgotPassword(const QString &email)
{
    clearError();

    if (email.trimmed().isEmpty() || !email.contains("@")) {
        setError("Please enter a valid email address.");
        return;
    }

    m_api->forgotPassword(email.trimmed());
}

void AuthController::resetPassword(const QString &token, const QString &newPassword)
{
    clearError();

    if (token.isEmpty()) {
        setError("Invalid reset link. Please request a new one.");
        return;
    }

    if (newPassword.length() < 8) {
        setError("Password must be at least 8 characters.");
        return;
    }

    m_api->resetPassword(token, newPassword);
}

void AuthController::logout()
{
    m_api->clearTokens();

    m_sessionToken.clear();
    m_maskedEmail.clear();
    m_lastEmail.clear();
    m_lastPassword.clear();

    m_userName.clear();
    m_userEmail.clear();
    m_userImage.clear();
    m_userId.clear();

    emit userNameChanged();
    emit userEmailChanged();
    emit userImageChanged();
    emit userIdChanged();
    emit isLoggedInChanged();
    emit loggedOut();
}

void AuthController::clearError()
{
    setError("");
}

void AuthController::loadProfile()
{
    m_api->getProfile();
}

void AuthController::changePassword(const QString &currentPassword, const QString &newPassword)
{
    clearError();

    if (currentPassword.isEmpty()) {
        setError("Please enter your current password.");
        return;
    }

    if (newPassword.length() < 8) {
        setError("New password must be at least 8 characters.");
        return;
    }

    if (currentPassword == newPassword) {
        setError("New password must be different from current password.");
        return;
    }

    m_api->changePassword(currentPassword, newPassword);
}


void AuthController::onLoginSuccess(const QString &sessionToken, const QString &maskedEmail)
{
    qDebug() << "AuthController::onLoginSuccess - Session token received (length):" << sessionToken.length();
    qDebug() << "AuthController::onLoginSuccess - Session token (first 50 chars):" << sessionToken.left(50);
    qDebug() << "AuthController::onLoginSuccess - Masked email:" << maskedEmail;

    // CRITICAL: Store the session token
    m_sessionToken = sessionToken;

    if (m_maskedEmail != maskedEmail) {
        m_maskedEmail = maskedEmail;
        emit maskedEmailChanged();
    }

    qDebug() << "AuthController::onLoginSuccess - m_sessionToken stored (first 50 chars):" << m_sessionToken.left(50);
    qDebug() << "AuthController::onLoginSuccess - Emitting loginSuccessful signal";

    emit loginSuccessful();
}

void AuthController::onLoginFailed(const QString &errorCode, const QString &errorMessage)
{
    qDebug() << "AuthController::onLoginFailed - Code:" << errorCode << "Message:" << errorMessage;
    setError(formatError(errorCode, errorMessage));
}

void AuthController::onOtpVerifySuccess(const QString &accessToken, const QString &refreshToken,
                                        const QJsonObject &user)
{
    Q_UNUSED(accessToken)
    Q_UNUSED(refreshToken)

    qDebug() << "AuthController::onOtpVerifySuccess - Verification successful";

    // Clear sensitive data
    m_lastPassword.clear();
    m_sessionToken.clear();

    setUserFromJson(user);

    emit isLoggedInChanged();
    emit otpVerified();
}

void AuthController::onOtpVerifyFailed(const QString &errorCode, const QString &errorMessage)
{
    qDebug() << "AuthController::onOtpVerifyFailed - Code:" << errorCode << "Message:" << errorMessage;
    setError(formatError(errorCode, errorMessage));
}

void AuthController::onRegisterSuccess(const QString &userId, const QString &email)
{
    Q_UNUSED(userId)
    Q_UNUSED(email)

    emit registrationSuccessful();
}

void AuthController::onRegisterFailed(const QString &errorCode, const QString &errorMessage)
{
    setError(formatError(errorCode, errorMessage));
}

void AuthController::onForgotPasswordSuccess(const QString &message)
{
    Q_UNUSED(message)
    emit passwordResetSent();
}

void AuthController::onForgotPasswordFailed(const QString &errorCode, const QString &errorMessage)
{
    setError(formatError(errorCode, errorMessage));
}

void AuthController::onResetPasswordSuccess()
{
    emit passwordResetSuccessful();
}

void AuthController::onResetPasswordFailed(const QString &errorCode, const QString &errorMessage)
{
    setError(formatError(errorCode, errorMessage));
}

void AuthController::onProfileLoaded(const QJsonObject &user)
{
    setUserFromJson(user);
}

void AuthController::onProfileLoadFailed(const QString &errorMessage)
{
    qDebug() << "Failed to load profile:" << errorMessage;
}

void AuthController::onPasswordChanged()
{
    emit passwordChanged();
}

void AuthController::onPasswordChangeFailed(const QString &errorMessage)
{
    setError(errorMessage);
}

void AuthController::onRequestStarted()
{
    setLoading(true);
}

void AuthController::onRequestFinished()
{
    setLoading(false);
}

QString AuthController::formatError(const QString &code, const QString &message)
{
    static const QMap<QString, QString> errorMessages = {
                                                         {"INVALID_CREDENTIALS", "Invalid email or password. Please try again."},
                                                         {"INVALID_OTP", "Invalid verification code. Please check and try again."},
                                                         {"OTP_EXPIRED", "Verification code has expired. Please request a new one."},
                                                         {"OTP_MAX_ATTEMPTS", "Too many failed attempts. Please request a new code."},
                                                         {"ACCOUNT_SUSPENDED", "Your account has been suspended. Please contact support."},
                                                         {"ACCOUNT_PENDING", "Your account is pending approval. Please wait for admin activation."},
                                                         {"ACCOUNT_INACTIVE", "Your account is inactive. Please contact support."},
                                                         {"EMAIL_EXISTS", "This email is already registered. Try logging in instead."},
                                                         {"USER_NOT_FOUND", "No account found with this email address."},
                                                         {"EMAIL_NOT_FOUND", "No account found with this email address."},
                                                         {"INVALID_TOKEN", "Invalid or expired token. Please try again."},
                                                         {"INVALID_PASSWORD", "Current password is incorrect."},
                                                         {"WEAK_PASSWORD", "Password is too weak. Use at least 8 characters with letters and numbers."},
                                                         {"RATE_LIMITED", "Too many requests. Please wait a moment and try again."},
                                                         {"NETWORK_ERROR", "Unable to connect. Please check your internet connection."},
                                                         {"SERVER_ERROR", "Server error. Please try again later."},
                                                         };

    if (errorMessages.contains(code)) {
        return errorMessages[code];
    }

    if (!message.isEmpty()) {
        return message;
    }

    return "An unexpected error occurred. Please try again.";
}
