#ifndef APIMANAGER_H
#define APIMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSettings>
#include <QUrl>
#include <QUrlQuery>

class ApiManager : public QObject
{
    Q_OBJECT

public:
    explicit ApiManager(QObject *parent = nullptr);
    ~ApiManager();

    void login(const QString &email, const QString &password);
    void verifyOtp(const QString &sessionToken, const QString &code);
    void registerUser(const QString &firstName, const QString &lastName,
                      const QString &email, const QString &password);
    void forgotPassword(const QString &email);
    void resetPassword(const QString &token, const QString &newPassword);
    void refreshAccessToken();

    void getProfile();
    void updateProfile(const QJsonObject &data);
    void changePassword(const QString &currentPassword, const QString &newPassword);
    void uploadProfileImage(const QString &filePath);
    void removeProfileImage();

    void getDashboardStats();

    void setAccessToken(const QString &token);
    void setRefreshToken(const QString &token);
    QString accessToken() const;
    QString refreshToken() const;
    bool isLoggedIn() const;
    void saveTokens();
    void loadTokens();
    void clearTokens();

    void setBaseUrl(const QString &url);
    QString baseUrl() const;
    void getInstructors(const QString &status = "");

signals:
    void loginSuccess(const QString &sessionToken, const QString &maskedEmail);
    void loginFailed(const QString &errorCode, const QString &errorMessage);

    void otpVerifySuccess(const QString &accessToken, const QString &refreshToken, const QJsonObject &user);
    void otpVerifyFailed(const QString &errorCode, const QString &errorMessage);

    void registerSuccess(const QString &userId, const QString &email);
    void registerFailed(const QString &errorCode, const QString &errorMessage);

    void forgotPasswordSuccess(const QString &message);
    void forgotPasswordFailed(const QString &errorCode, const QString &errorMessage);

    void resetPasswordSuccess();
    void resetPasswordFailed(const QString &errorCode, const QString &errorMessage);

    void tokenRefreshed(const QString &newAccessToken);
    void tokenRefreshFailed();

    void profileLoaded(const QJsonObject &user);
    void profileLoadFailed(const QString &errorMessage);

    void profileUpdated(const QJsonObject &user);
    void profileUpdateFailed(const QString &errorMessage);

    void passwordChanged();
    void passwordChangeFailed(const QString &errorMessage);

    void profileImageUploaded(const QString &imageUrl);
    void profileImageUploadFailed(const QString &errorMessage);

    void profileImageRemoved();
    void profileImageRemoveFailed(const QString &errorMessage);

    void dashboardStatsLoaded(const QJsonObject &stats);
    void dashboardStatsLoadFailed(const QString &errorMessage);

    void requestStarted();
    void requestFinished();
    void networkError(const QString &errorMessage);

    void instructorsLoaded(const QJsonObject &data);
    void instructorsLoadFailed(const QString &errorMessage);

private:
    QNetworkAccessManager *m_networkManager;
    QString m_baseUrl;
    QString m_accessToken;
    QString m_refreshToken;

    QNetworkRequest createRequest(const QString &endpoint, bool withAuth = false);
    void handleNetworkError(QNetworkReply *reply);
    QJsonObject parseResponse(QNetworkReply *reply);

private slots:
    void onSslErrors(QNetworkReply *reply, const QList<QSslError> &errors);
};

#endif // APIMANAGER_H
