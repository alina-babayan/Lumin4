#include "apimanager.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QHttpMultiPart>
#include <QMimeDatabase>

ApiManager::ApiManager(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_baseUrl("https://learning-dashboard-rouge.vercel.app")
{
    loadTokens();

    connect(m_networkManager, &QNetworkAccessManager::sslErrors, this, &ApiManager::onSslErrors);
}

ApiManager::~ApiManager() {}


QNetworkRequest ApiManager::createRequest(const QString &endpoint, bool withAuth)
{
    QUrl url(m_baseUrl + endpoint);
    QNetworkRequest request(url);

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Accept", "application/json");

    if (withAuth && !m_accessToken.isEmpty()) {
        request.setRawHeader("Authorization", ("Bearer " + m_accessToken).toUtf8());
    }

    return request;
}

void ApiManager::handleNetworkError(QNetworkReply *reply)
{
    QString errorMsg = reply->errorString();
    qDebug() << "Network error:" << errorMsg;
    emit networkError(errorMsg);
}

QJsonObject ApiManager::parseResponse(QNetworkReply *reply)
{
    QByteArray data = reply->readAll();
    qDebug() << "Raw response data:" << data;
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (doc.isNull()) {
        qDebug() << "Failed to parse JSON:" << data;
        return QJsonObject();
    }

    QJsonObject obj = doc.object();
    qDebug() << "Parsed JSON object keys:" << obj.keys();
    return obj;
}

void ApiManager::onSslErrors(QNetworkReply *reply, const QList<QSslError> &errors)
{
    for (const QSslError &error : errors) {
        qDebug() << "SSL Error:" << error.errorString();
    }

}


void ApiManager::setBaseUrl(const QString &url)
{
    m_baseUrl = url;
}

QString ApiManager::baseUrl() const
{
    return m_baseUrl;
}


void ApiManager::setAccessToken(const QString &token)
{
    m_accessToken = token;
}

void ApiManager::setRefreshToken(const QString &token)
{
    m_refreshToken = token;
}

QString ApiManager::accessToken() const
{
    return m_accessToken;
}

QString ApiManager::refreshToken() const
{
    return m_refreshToken;
}

bool ApiManager::isLoggedIn() const
{
    return !m_accessToken.isEmpty();
}

void ApiManager::saveTokens()
{
    QSettings settings;
    settings.beginGroup("auth");
    settings.setValue("accessToken", m_accessToken);
    settings.setValue("refreshToken", m_refreshToken);
    settings.endGroup();
    settings.sync();
}

void ApiManager::loadTokens()
{
    QSettings settings;
    settings.beginGroup("auth");
    m_accessToken = settings.value("accessToken").toString();
    m_refreshToken = settings.value("refreshToken").toString();
    settings.endGroup();
}

void ApiManager::clearTokens()
{
    m_accessToken.clear();
    m_refreshToken.clear();

    QSettings settings;
    settings.beginGroup("auth");
    settings.remove("accessToken");
    settings.remove("refreshToken");
    settings.endGroup();
    settings.sync();
}


void ApiManager::login(const QString &email, const QString &password)
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/auth/login");

    QJsonObject json;
    json["email"] = email;
    json["password"] = password;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            QJsonObject response = parseResponse(reply);
            if (!response.isEmpty()) {
                emit loginFailed(response["code"].toString(), response["message"].toString());
            } else {
                emit loginFailed("NETWORK_ERROR", reply->errorString());
            }
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            QJsonObject data = response["data"].toObject();
            QString sessionToken = data["sessionToken"].toString();
            QString maskedEmail = data["maskedEmail"].toString();
            emit loginSuccess(sessionToken, maskedEmail);
        } else {
            emit loginFailed(response["code"].toString(), response["message"].toString());
        }
    });
}


void ApiManager::verifyOtp(const QString &sessionToken, const QString &code)
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/auth/verify-login");

    QJsonObject json;
    json["sessionToken"] = sessionToken;
    json["code"] = code;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            QJsonObject response = parseResponse(reply);
            if (!response.isEmpty()) {
                emit otpVerifyFailed(response["code"].toString(), response["message"].toString());
            } else {
                emit otpVerifyFailed("NETWORK_ERROR", reply->errorString());
            }
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            QJsonObject data = response["data"].toObject();

            m_accessToken = data["accessToken"].toString();
            m_refreshToken = data["refreshToken"].toString();
            saveTokens();

            QJsonObject user = data["user"].toObject();
            emit otpVerifySuccess(m_accessToken, m_refreshToken, user);
        } else {
            emit otpVerifyFailed(response["code"].toString(), response["message"].toString());
        }
    });
}


void ApiManager::registerUser(const QString &firstName,
                              const QString &lastName,
                              const QString &email,
                              const QString &password)
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/auth/register");

    QJsonObject json;
    json["firstName"] = firstName;
    json["lastName"] = lastName;
    json["email"] = email;
    json["password"] = password;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            QJsonObject response = parseResponse(reply);
            if (!response.isEmpty()) {
                emit registerFailed(response["code"].toString(), response["message"].toString());
            } else {
                emit registerFailed("NETWORK_ERROR", reply->errorString());
            }
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            QJsonObject data = response["data"].toObject();
            emit registerSuccess(data["userId"].toString(), data["email"].toString());
        } else {
            emit registerFailed(response["code"].toString(), response["message"].toString());
        }
    });
}

void ApiManager::forgotPassword(const QString &email)
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/auth/forgot-password");

    QJsonObject json;
    json["email"] = email;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "Forgot Password HTTP status:" << statusCode;

        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "Network error in forgotPassword:" << reply->errorString();
            QJsonObject response = parseResponse(reply);
            if (!response.isEmpty() && response.contains("error")) {
                qDebug() << "Emitting failed with code:" << response["error"].toString();
                emit forgotPasswordFailed(response["error"].toString(), response["message"].toString());
            } else {
                handleNetworkError(reply);
            }
            return;
        }

        QJsonObject response = parseResponse(reply);
        qDebug() << "Parsed response object:" << response;

        if (!response.isEmpty() && response.contains("success") && response["success"].toBool()) {
            qDebug() << "Success response detected";
            emit forgotPasswordSuccess(response["message"].toString());
        } else if (!response.isEmpty() && response.contains("error")) {
            qDebug() << "Error response detected";
            emit forgotPasswordFailed(response["error"].toString(), response["message"].toString());
        } else {
            qDebug() << "Unknown response format";
            emit forgotPasswordFailed("UNKNOWN_ERROR", "Unexpected response from server");
        }
    });
}

void ApiManager::resetPassword(const QString &token, const QString &newPassword)
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/auth/reset-password");

    QJsonObject json;
    json["token"] = token;
    json["newPassword"] = newPassword;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            QJsonObject response = parseResponse(reply);
            if (!response.isEmpty()) {
                emit resetPasswordFailed(response["code"].toString(),
                                         response["message"].toString());
            } else {
                emit resetPasswordFailed("NETWORK_ERROR", reply->errorString());
            }
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            emit resetPasswordSuccess();
        } else {
            emit resetPasswordFailed(response["code"].toString(), response["message"].toString());
        }
    });
}


void ApiManager::refreshAccessToken()
{
    if (m_refreshToken.isEmpty()) {
        emit tokenRefreshFailed();
        return;
    }

    QNetworkRequest request = createRequest("/api/auth/refresh");

    QJsonObject json;
    json["refreshToken"] = m_refreshToken;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            emit tokenRefreshFailed();
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            QJsonObject data = response["data"].toObject();
            m_accessToken = data["accessToken"].toString();
            saveTokens();
            emit tokenRefreshed(m_accessToken);
        } else {
            emit tokenRefreshFailed();
        }
    });
}


void ApiManager::getProfile()
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/user/profile", true);

    QNetworkReply *reply = m_networkManager->get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            if (reply->error() == QNetworkReply::AuthenticationRequiredError) {
                refreshAccessToken();
            }
            emit profileLoadFailed(reply->errorString());
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            emit profileLoaded(response["data"].toObject());
        } else {
            emit profileLoadFailed(response["message"].toString());
        }
    });
}


void ApiManager::updateProfile(const QJsonObject &data)
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/user/profile", true);

    QNetworkReply *reply = m_networkManager->put(request, QJsonDocument(data).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            emit profileUpdateFailed(reply->errorString());
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            emit profileUpdated(response["data"].toObject());
        } else {
            emit profileUpdateFailed(response["message"].toString());
        }
    });
}


void ApiManager::changePassword(const QString &currentPassword, const QString &newPassword)
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/user/change-password", true);

    QJsonObject json;
    json["currentPassword"] = currentPassword;
    json["newPassword"] = newPassword;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            QJsonObject response = parseResponse(reply);
            if (!response.isEmpty()) {
                emit passwordChangeFailed(response["message"].toString());
            } else {
                emit passwordChangeFailed(reply->errorString());
            }
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            emit passwordChanged();
        } else {
            emit passwordChangeFailed(response["message"].toString());
        }
    });
}


void ApiManager::uploadProfileImage(const QString &filePath)
{
    emit requestStarted();

    QFile *file = new QFile(filePath);
    if (!file->open(QIODevice::ReadOnly)) {
        emit profileImageUploadFailed("Failed to open file");
        delete file;
        emit requestFinished();
        return;
    }

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    QMimeDatabase mimeDb;
    QString mimeType = mimeDb.mimeTypeForFile(filePath).name();

    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, mimeType);
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                        QString("form-data; name=\"image\"; filename=\"%1\"")
                            .arg(QFileInfo(filePath).fileName()));
    imagePart.setBodyDevice(file);
    file->setParent(multiPart);

    multiPart->append(imagePart);

    QUrl url(m_baseUrl + "/api/user/upload-image");
    QNetworkRequest request(url);
    request.setRawHeader("Authorization", ("Bearer " + m_accessToken).toUtf8());

    QNetworkReply *reply = m_networkManager->post(request, multiPart);
    multiPart->setParent(reply);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            emit profileImageUploadFailed(reply->errorString());
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            QString imageUrl = response["data"].toObject()["imageUrl"].toString();
            emit profileImageUploaded(imageUrl);
        } else {
            emit profileImageUploadFailed(response["message"].toString());
        }
    });
}

void ApiManager::removeProfileImage()
{
    emit requestStarted();

    QNetworkRequest request = createRequest("/api/user/remove-image", true);

    QNetworkReply *reply = m_networkManager->deleteResource(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        emit requestFinished();

        if (reply->error() != QNetworkReply::NoError) {
            emit profileImageRemoveFailed(reply->errorString());
            return;
        }

        QJsonObject response = parseResponse(reply);

        if (response["success"].toBool()) {
            emit profileImageRemoved();
        } else {
            emit profileImageRemoveFailed(response["message"].toString());
        }
    });
}
