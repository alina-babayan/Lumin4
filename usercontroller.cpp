#include "usercontroller.h"
#include <QJsonArray>
#include <QDateTime>
#include <QDebug>

UserController::UserController(QObject *parent)
    : QObject(parent)
    , m_api(new ApiManager(this))
    , m_isLoading(false)
    , m_totalStudents(0)
    , m_activeStudents(0)
    , m_inactiveStudents(0)
    , m_currentStatus("all")
{
    connect(m_api, &ApiManager::studentsLoaded,
            this, &UserController::onStudentsLoaded);
    connect(m_api, &ApiManager::studentsLoadFailed,
            this, &UserController::onStudentsLoadFailed);

    connect(m_api, &ApiManager::requestStarted,
            this, &UserController::onRequestStarted);
    connect(m_api, &ApiManager::requestFinished,
            this, &UserController::onRequestFinished);
}

UserController::~UserController()
{
}

void UserController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void UserController::setError(const QString &error)
{
    if (m_errorMessage != error) {
        m_errorMessage = error;
        emit errorMessageChanged();
    }
}

void UserController::loadStudents()
{
    clearError();

    QString isActiveParam;
    if (m_currentStatus == "active") {
        isActiveParam = "true";
    } else if (m_currentStatus == "inactive") {
        isActiveParam = "false";
    }

    m_api->getStudents(isActiveParam, m_searchQuery);
}

void UserController::setStatusFilter(const QString &status)
{
    if (m_currentStatus != status) {
        m_currentStatus = status;
        emit currentStatusChanged();
        loadStudents();
    }
}

void UserController::setSearchQuery(const QString &query)
{
    if (m_searchQuery != query) {
        m_searchQuery = query;
        emit searchQueryChanged();
        loadStudents();
    }
}

void UserController::clearError()
{
    setError("");
}

void UserController::refresh()
{
    loadStudents();
}

void UserController::onStudentsLoaded(const QJsonObject &data)
{
    if (data.contains("stats")) {
        updateStats(data["stats"].toObject());
    }

    if (data.contains("students")) {
        updateStudentsList(data["students"].toArray());
    }

    emit studentsLoaded();
}

void UserController::onStudentsLoadFailed(const QString &errorMessage)
{
    setError(errorMessage.isEmpty() ?
                 "Failed to load students. Please try again." :
                 errorMessage);
}

void UserController::onRequestStarted()
{
    setLoading(true);
}

void UserController::onRequestFinished()
{
    setLoading(false);
}

void UserController::updateStats(const QJsonObject &stats)
{
    m_totalStudents = stats["total"].toInt();
    m_activeStudents = stats["active"].toInt();
    m_inactiveStudents = stats["inactive"].toInt();

    emit statsChanged();
}

void UserController::updateStudentsList(const QJsonArray &studentsArray)
{
    m_students.clear();

    for (const QJsonValue &value : studentsArray) {
        QJsonObject student = value.toObject();

        QVariantMap studentMap;
        studentMap["id"] = student["id"].toString();
        studentMap["firstName"] = student["firstName"].toString();
        studentMap["lastName"] = student["lastName"].toString();
        studentMap["email"] = student["email"].toString();
        studentMap["profileImage"] = student["profileImage"].toString();
        studentMap["isActive"] = student["isActive"].toBool();
        studentMap["createdAt"] = student["createdAt"].toString();

        // Format full name
        QString fullName = student["firstName"].toString() + " " +
                           student["lastName"].toString();
        studentMap["fullName"] = fullName;

        // Format relative date
        QString relativeDate = formatRelativeDate(student["createdAt"].toString());
        studentMap["relativeDate"] = relativeDate;

        // Status display
        studentMap["statusText"] = student["isActive"].toBool() ? "Active" : "Inactive";

        m_students.append(studentMap);
    }

    emit studentsChanged();
}

QString UserController::formatRelativeDate(const QString &dateString) const
{
    if (dateString.isEmpty()) {
        return "Unknown";
    }

    QDateTime dateTime = QDateTime::fromString(dateString, Qt::ISODate);
    if (!dateTime.isValid()) {
        return "Unknown";
    }

    QDateTime now = QDateTime::currentDateTime();
    qint64 seconds = dateTime.secsTo(now);

    if (seconds < 60) {
        return "Just now";
    } else if (seconds < 3600) {
        int minutes = seconds / 60;
        return QString("%1 minute%2 ago").arg(minutes).arg(minutes > 1 ? "s" : "");
    } else if (seconds < 86400) {
        int hours = seconds / 3600;
        return QString("%1 hour%2 ago").arg(hours).arg(hours > 1 ? "s" : "");
    } else if (seconds < 604800) {
        int days = seconds / 86400;
        return QString("%1 day%2 ago").arg(days).arg(days > 1 ? "s" : "");
    } else if (seconds < 2592000) {
        int weeks = seconds / 604800;
        return QString("%1 week%2 ago").arg(weeks).arg(weeks > 1 ? "s" : "");
    } else if (seconds < 31536000) {
        int months = seconds / 2592000;
        return QString("%1 month%2 ago").arg(months).arg(months > 1 ? "s" : "");
    } else {
        int years = seconds / 31536000;
        return QString("%1 year%2 ago").arg(years).arg(years > 1 ? "s" : "");
    }
}
