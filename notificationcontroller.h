#ifndef NOTIFICATIONCONTROLLER_H
#define NOTIFICATIONCONTROLLER_H

#include <QObject>
#include <QVariantList>
#include "apimanager.h"

class NotificationController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(int unreadCount READ unreadCount NOTIFY unreadCountChanged)
    Q_PROPERTY(QVariantList notifications READ notifications NOTIFY notificationsChanged)
    Q_PROPERTY(QVariantList recentNotifications READ recentNotifications NOTIFY recentNotificationsChanged)
    Q_PROPERTY(QString currentFilter READ currentFilter NOTIFY currentFilterChanged)

public:
    explicit NotificationController(QObject *parent = nullptr);
    ~NotificationController();

    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }
    int unreadCount() const { return m_unreadCount; }
    QVariantList notifications() const { return m_notifications; }
    QVariantList recentNotifications() const { return m_recentNotifications; }
    QString currentFilter() const { return m_currentFilter; }

    Q_INVOKABLE void loadNotifications(int limit = 50);
    Q_INVOKABLE void loadRecentNotifications();
    Q_INVOKABLE void setFilter(const QString &filter);
    Q_INVOKABLE void markAsRead(const QString &notificationId);
    Q_INVOKABLE void markAllAsRead();
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void refresh();

signals:
    void isLoadingChanged();
    void errorMessageChanged();
    void unreadCountChanged();
    void notificationsChanged();
    void recentNotificationsChanged();
    void currentFilterChanged();
    void notificationsLoaded();
    void notificationMarkedAsRead();
    void allMarkedAsRead();

private slots:
    void onNotificationsLoaded(const QJsonObject &data);
    void onNotificationsLoadFailed(const QString &errorMessage);
    void onNotificationMarkedAsRead(const QJsonObject &data);
    void onMarkAsReadFailed(const QString &errorMessage);
    void onAllMarkedAsRead(const QJsonObject &data);
    void onMarkAllAsReadFailed(const QString &errorMessage);
    void onRequestStarted();
    void onRequestFinished();

private:
    void setLoading(bool loading);
    void setError(const QString &error);
    void updateNotificationsList(const QJsonArray &notificationsArray, bool isRecent = false);
    QString formatRelativeTime(const QString &dateString) const;
    QString getNotificationIcon(const QString &type) const;

    ApiManager *m_api;
    bool m_isLoading;
    QString m_errorMessage;
    int m_unreadCount;
    QVariantList m_notifications;
    QVariantList m_recentNotifications;
    QString m_currentFilter;
};

#endif // NOTIFICATIONCONTROLLER_H
