#ifndef USERCONTROLLER_H
#define USERCONTROLLER_H

#include <QObject>
#include <QVariantList>
#include "apimanager.h"

class UserController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(int totalStudents READ totalStudents NOTIFY statsChanged)
    Q_PROPERTY(int activeStudents READ activeStudents NOTIFY statsChanged)
    Q_PROPERTY(int inactiveStudents READ inactiveStudents NOTIFY statsChanged)
    Q_PROPERTY(QVariantList students READ students NOTIFY studentsChanged)
    Q_PROPERTY(QString currentStatus READ currentStatus NOTIFY currentStatusChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery NOTIFY searchQueryChanged)

public:
    explicit UserController(QObject *parent = nullptr);
    ~UserController();

    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }
    int totalStudents() const { return m_totalStudents; }
    int activeStudents() const { return m_activeStudents; }
    int inactiveStudents() const { return m_inactiveStudents; }
    QVariantList students() const { return m_students; }
    QString currentStatus() const { return m_currentStatus; }
    QString searchQuery() const { return m_searchQuery; }

    Q_INVOKABLE void loadStudents();
    Q_INVOKABLE void setStatusFilter(const QString &status);
    Q_INVOKABLE void setSearchQuery(const QString &query);
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void refresh();

signals:
    void isLoadingChanged();
    void errorMessageChanged();
    void statsChanged();
    void studentsChanged();
    void currentStatusChanged();
    void searchQueryChanged();
    void studentsLoaded();

private slots:
    void onStudentsLoaded(const QJsonObject &data);
    void onStudentsLoadFailed(const QString &errorMessage);
    void onRequestStarted();
    void onRequestFinished();

private:
    void setLoading(bool loading);
    void setError(const QString &error);
    void updateStats(const QJsonObject &stats);
    void updateStudentsList(const QJsonArray &studentsArray);
    QString formatRelativeDate(const QString &dateString) const;

    ApiManager *m_api;
    bool m_isLoading;
    QString m_errorMessage;
    int m_totalStudents;
    int m_activeStudents;
    int m_inactiveStudents;
    QVariantList m_students;
    QString m_currentStatus;
    QString m_searchQuery;
};

#endif // USERCONTROLLER_H
