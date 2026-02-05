#include "notificationcontroller.h"
#include <QJsonArray>
#include <QDateTime>
#include <QDebug>

NotificationController::NotificationController(QObject *parent)
    : QObject(parent)
    , m_api(new ApiManager(this))
    , m_isLoading(false)
    , m_unreadCount(0)
    , m_currentFilter("all")
{
    connect(m_api, &ApiManager::notificationsLoaded,
            this, &NotificationController::onNotificationsLoaded);
    connect(m_api, &ApiManager::notificationsLoadFailed,
            this, &NotificationController::onNotificationsLoadFailed);

    connect(m_api, &ApiManager::notificationMarkedAsRead,
            this, &NotificationController::onNotificationMarkedAsRead);
    connect(m_api, &ApiManager::markAsReadFailed,
            this, &NotificationController::onMarkAsReadFailed);

    connect(m_api, &ApiManager::allMarkedAsRead,
            this, &NotificationController::onAllMarkedAsRead);
    connect(m_api, &ApiManager::markAllAsReadFailed,
            this, &NotificationController::onMarkAllAsReadFailed);

    connect(m_api, &ApiManager::requestStarted,
            this, &NotificationController::onRequestStarted);
    connect(m_api, &ApiManager::requestFinished,
            this, &NotificationController::onRequestFinished);
}

NotificationController::~NotificationController()
{
}

void NotificationController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void NotificationController::setError(const QString &error)
{
    if (m_errorMessage != error) {
        m_errorMessage = error;
        emit errorMessageChanged();
    }
}

void NotificationController::loadNotifications(int limit)
{
    clearError();

    QString status = m_currentFilter == "all" ? "" : m_currentFilter;
    m_api->getNotifications(limit, status);
}

void NotificationController::loadRecentNotifications()
{
    clearError();
    m_api->getRecentNotifications();
}

void NotificationController::setFilter(const QString &filter)
{
    if (m_currentFilter != filter) {
        m_currentFilter = filter;
        emit currentFilterChanged();
        loadNotifications();
    }
}

void NotificationController::markAsRead(const QString &notificationId)
{
    clearError();
    m_api->markNotificationAsRead(notificationId);
}

void NotificationController::markAllAsRead()
{
    clearError();
    m_api->markAllNotificationsAsRead();
}

void NotificationController::clearError()
{
    setError("");
}

void NotificationController::refresh()
{
    loadNotifications();
}

void NotificationController::onNotificationsLoaded(const QJsonObject &data)
{
    if (data.contains("unreadCount")) {
        int newUnreadCount = data["unreadCount"].toInt();
        if (m_unreadCount != newUnreadCount) {
            m_unreadCount = newUnreadCount;
            emit unreadCountChanged();
        }
    }

    if (data.contains("notifications")) {
        bool isRecent = data.contains("isRecent") && data["isRecent"].toBool();
        updateNotificationsList(data["notifications"].toArray(), isRecent);
    }

    emit notificationsLoaded();
}

void NotificationController::onNotificationsLoadFailed(const QString &errorMessage)
{
    setError(errorMessage.isEmpty() ?
                 "Failed to load notifications. Please try again." :
                 errorMessage);
}

void NotificationController::onNotificationMarkedAsRead(const QJsonObject &data)
{
    Q_UNUSED(data);

    // Decrement unread count
    if (m_unreadCount > 0) {
        m_unreadCount--;
        emit unreadCountChanged();
    }

    emit notificationMarkedAsRead();

    // Reload to update the list
    loadRecentNotifications();
}

void NotificationController::onMarkAsReadFailed(const QString &errorMessage)
{
    setError(errorMessage.isEmpty() ?
                 "Failed to mark notification as read." :
                 errorMessage);
}

void NotificationController::onAllMarkedAsRead(const QJsonObject &data)
{
    Q_UNUSED(data);

    m_unreadCount = 0;
    emit unreadCountChanged();
    emit allMarkedAsRead();

    // Reload to update the list
    loadRecentNotifications();
}

void NotificationController::onMarkAllAsReadFailed(const QString &errorMessage)
{
    setError(errorMessage.isEmpty() ?
                 "Failed to mark all notifications as read." :
                 errorMessage);
}

void NotificationController::onRequestStarted()
{
    setLoading(true);
}

void NotificationController::onRequestFinished()
{
    setLoading(false);
}

void NotificationController::updateNotificationsList(const QJsonArray &notificationsArray, bool isRecent)
{
    QVariantList *targetList = isRecent ? &m_recentNotifications : &m_notifications;
    targetList->clear();

    for (const QJsonValue &value : notificationsArray) {
        QJsonObject notification = value.toObject();

        QVariantMap notificationMap;
        notificationMap["id"] = notification["id"].toString();
        notificationMap["type"] = notification["type"].toString();
        notificationMap["title"] = notification["title"].toString();
        notificationMap["message"] = notification["message"].toString();
        notificationMap["isRead"] = notification["isRead"].toBool();
        notificationMap["actionUrl"] = notification["actionUrl"].toString();
        notificationMap["createdAt"] = notification["createdAt"].toString();

        // Format relative time
        notificationMap["relativeTime"] = formatRelativeTime(notification["createdAt"].toString());

        // Get icon based on type
        notificationMap["icon"] = getNotificationIcon(notification["type"].toString());

        targetList->append(notificationMap);
    }

    if (isRecent) {
        emit recentNotificationsChanged();
    } else {
        emit notificationsChanged();
    }
}

QString NotificationController::formatRelativeTime(const QString &dateString) const
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
        return QString("%1m ago").arg(minutes);
    } else if (seconds < 86400) {
        int hours = seconds / 3600;
        return QString("%1h ago").arg(hours);
    } else if (seconds < 604800) {
        int days = seconds / 86400;
        return QString("%1d ago").arg(days);
    } else if (seconds < 2592000) {
        int weeks = seconds / 604800;
        return QString("%1w ago").arg(weeks);
    } else {
        return dateTime.toString("MMM dd");
    }
}

QString NotificationController::getNotificationIcon(const QString &type) const
{
    // Return icon names based on notification type
    if (type == "course_submitted") {
        return "qrc:/icons/course.svg";
    } else if (type == "course_approved") {
        return "qrc:/icons/check-circle.svg";
    } else if (type == "course_rejected") {
        return "qrc:/icons/x-circle.svg";
    } else if (type == "instructor_request") {
        return "qrc:/icons/user.svg";
    } else if (type == "new_student") {
        return "qrc:/icons/user-plus.svg";
    } else if (type == "transaction") {
        return "qrc:/icons/dollar-sign.svg";
    } else {
        return "qrc:/icons/bell.svg";
    }
}
