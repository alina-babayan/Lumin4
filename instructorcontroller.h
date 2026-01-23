#ifndef INSTRUCTORCONTROLLER_H
#define INSTRUCTORCONTROLLER_H

#include <QJsonArray>
#include <QJsonObject>
#include <QObject>
#include <QString>
#include "apimanager.h"

class InstructorController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(int totalInstructors READ totalInstructors NOTIFY statsChanged)
    Q_PROPERTY(int pendingInstructors READ pendingInstructors NOTIFY statsChanged)
    Q_PROPERTY(int verifiedInstructors READ verifiedInstructors NOTIFY statsChanged)
    Q_PROPERTY(int rejectedInstructors READ rejectedInstructors NOTIFY statsChanged)
    Q_PROPERTY(QVariantList instructors READ instructors NOTIFY instructorsChanged)
    Q_PROPERTY(QString currentStatus READ currentStatus NOTIFY currentStatusChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery NOTIFY searchQueryChanged)

public:
    explicit InstructorController(QObject *parent = nullptr);
    ~InstructorController();

    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }
    int totalInstructors() const { return m_totalInstructors; }
    int pendingInstructors() const { return m_pendingInstructors; }
    int verifiedInstructors() const { return m_verifiedInstructors; }
    int rejectedInstructors() const { return m_rejectedInstructors; }
    QVariantList instructors() const { return m_instructors; }
    QString currentStatus() const { return m_currentStatus; }
    QString searchQuery() const { return m_searchQuery; }

    Q_INVOKABLE void loadInstructors();
    Q_INVOKABLE void setStatusFilter(const QString &status);
    Q_INVOKABLE void setSearchQuery(const QString &query);
    Q_INVOKABLE void approveInstructor(const QString &instructorId);
    Q_INVOKABLE void rejectInstructor(const QString &instructorId);
    Q_INVOKABLE void revokeInstructor(const QString &instructorId);
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void refresh();

signals:
    void isLoadingChanged();
    void errorMessageChanged();
    void statsChanged();
    void instructorsChanged();
    void currentStatusChanged();
    void searchQueryChanged();
    void instructorUpdated(const QString &message);
    void actionFailed(const QString &error);

private slots:
    void onInstructorsLoaded(const QJsonObject &data);
    void onInstructorsLoadFailed(const QString &errorMessage);
    void onInstructorStatusUpdated(const QJsonObject &data);
    void onInstructorStatusUpdateFailed(const QString &errorMessage);
    void onRequestStarted();
    void onRequestFinished();

private:
    ApiManager *m_api;

    bool m_isLoading;
    QString m_errorMessage;
    int m_totalInstructors;
    int m_pendingInstructors;
    int m_verifiedInstructors;
    int m_rejectedInstructors;
    QVariantList m_instructors;
    QString m_currentStatus;
    QString m_searchQuery;

    void setLoading(bool loading);
    void setError(const QString &error);
    void updateStats(const QJsonObject &stats);
    void updateInstructorsList(const QJsonArray &instructorsArray);
    QString formatRelativeDate(const QString &dateString) const;
};

#endif // INSTRUCTORCONTROLLER_H
