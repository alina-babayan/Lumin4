#include "instructorcontroller.h"
#include <QDateTime>
#include <QDebug>

InstructorController::InstructorController(QObject *parent)
    : QObject(parent)
    , m_api(new ApiManager(this))
    , m_isLoading(false)
    , m_totalInstructors(0)
    , m_pendingInstructors(0)
    , m_verifiedInstructors(0)
    , m_rejectedInstructors(0)
    , m_currentStatus("all")
{
    connect(m_api, &ApiManager::instructorsLoaded,
            this, &InstructorController::onInstructorsLoaded);
    connect(m_api, &ApiManager::instructorsLoadFailed,
            this, &InstructorController::onInstructorsLoadFailed);

    connect(m_api, &ApiManager::instructorStatusUpdated,
            this, &InstructorController::onInstructorStatusUpdated);
    connect(m_api, &ApiManager::instructorStatusUpdateFailed,
            this, &InstructorController::onInstructorStatusUpdateFailed);

    connect(m_api, &ApiManager::requestStarted,
            this, &InstructorController::onRequestStarted);
    connect(m_api, &ApiManager::requestFinished,
            this, &InstructorController::onRequestFinished);
}

InstructorController::~InstructorController()
{
}

void InstructorController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void InstructorController::setError(const QString &error)
{
    if (m_errorMessage != error) {
        m_errorMessage = error;
        emit errorMessageChanged();
    }
}

void InstructorController::loadInstructors()
{
    clearError();

    QString status = m_currentStatus == "all" ? "" : m_currentStatus;
    m_api->getInstructors(status);
}

void InstructorController::setStatusFilter(const QString &status)
{
    if (m_currentStatus != status) {
        m_currentStatus = status;
        emit currentStatusChanged();
        loadInstructors();
    }
}

void InstructorController::setSearchQuery(const QString &query)
{
    if (m_searchQuery != query) {
        m_searchQuery = query;
        emit searchQueryChanged();
        loadInstructors();
    }
}

void InstructorController::approveInstructor(const QString &instructorId)
{
    clearError();
    m_api->updateInstructorStatus(instructorId, "verified");
}

void InstructorController::rejectInstructor(const QString &instructorId)
{
    clearError();
    m_api->updateInstructorStatus(instructorId, "rejected");
}

void InstructorController::revokeInstructor(const QString &instructorId)
{
    clearError();
    m_api->updateInstructorStatus(instructorId, "pending");
}

void InstructorController::clearError()
{
    setError("");
}

void InstructorController::refresh()
{
    loadInstructors();
}

void InstructorController::onInstructorsLoaded(const QJsonObject &data)
{
    if (data.contains("stats")) {
        updateStats(data["stats"].toObject());
    }

    if (data.contains("instructors")) {
        updateInstructorsList(data["instructors"].toArray());
    }
}

void InstructorController::onInstructorsLoadFailed(const QString &errorMessage)
{
    setError(errorMessage.isEmpty() ?
                 "Failed to load instructors. Please try again." :
                 errorMessage);
}

void InstructorController::onInstructorStatusUpdated(const QJsonObject &data)
{
    QString message = data["message"].toString();
    if (message.isEmpty()) {
        message = "Instructor status updated successfully";
    }

    emit instructorUpdated(message);
    loadInstructors(); // Refresh the list
}

void InstructorController::onInstructorStatusUpdateFailed(const QString &errorMessage)
{
    emit actionFailed(errorMessage.isEmpty() ?
                          "Failed to update instructor status" :
                          errorMessage);
}

void InstructorController::onRequestStarted()
{
    setLoading(true);
}

void InstructorController::onRequestFinished()
{
    setLoading(false);
}

void InstructorController::updateStats(const QJsonObject &stats)
{
    m_totalInstructors = stats["total"].toInt();
    m_pendingInstructors = stats["pending"].toInt();
    m_verifiedInstructors = stats["verified"].toInt();
    m_rejectedInstructors = stats["rejected"].toInt();

    emit statsChanged();
}

void InstructorController::updateInstructorsList(const QJsonArray &instructorsArray)
{
    m_instructors.clear();

    for (const QJsonValue &value : instructorsArray) {
        QJsonObject instructor = value.toObject();

        QVariantMap instructorMap;
        instructorMap["id"] = instructor["id"].toString();
        instructorMap["firstName"] = instructor["firstName"].toString();
        instructorMap["lastName"] = instructor["lastName"].toString();
        instructorMap["email"] = instructor["email"].toString();
        instructorMap["image"] = instructor["image"].toString();
        instructorMap["instructorStatus"] = instructor["instructorStatus"].toString();
        instructorMap["createdAt"] = instructor["createdAt"].toString();

        // Format full name
        QString fullName = instructor["firstName"].toString() + " " +
                           instructor["lastName"].toString();
        instructorMap["fullName"] = fullName;

        // Format relative date
        QString relativeDate = formatRelativeDate(instructor["createdAt"].toString());
        instructorMap["relativeDate"] = relativeDate;

        m_instructors.append(instructorMap);
    }

    emit instructorsChanged();
}

QString InstructorController::formatRelativeDate(const QString &dateString) const
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
