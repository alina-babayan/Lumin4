#ifndef DASHBOARDCONTROLLER_H
#define DASHBOARDCONTROLLER_H

#include <QObject>
#include <QJsonObject>
#include "apimanager.h"

class DashboardController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

    Q_PROPERTY(int totalInstructors READ totalInstructors NOTIFY statsChanged)
    Q_PROPERTY(int verifiedInstructors READ verifiedInstructors NOTIFY statsChanged)
    Q_PROPERTY(int pendingInstructors READ pendingInstructors NOTIFY statsChanged)

    Q_PROPERTY(int totalStudents READ totalStudents NOTIFY statsChanged)
    Q_PROPERTY(int activeStudents READ activeStudents NOTIFY statsChanged)

    Q_PROPERTY(int totalCourses READ totalCourses NOTIFY statsChanged)
    Q_PROPERTY(int activeCourses READ activeCourses NOTIFY statsChanged)
    Q_PROPERTY(int draftCourses READ draftCourses NOTIFY statsChanged)

    Q_PROPERTY(double totalRevenue READ totalRevenue NOTIFY statsChanged)
    Q_PROPERTY(double monthlyRevenue READ monthlyRevenue NOTIFY statsChanged)
    Q_PROPERTY(QString formattedTotalRevenue READ formattedTotalRevenue NOTIFY statsChanged)
    Q_PROPERTY(QString formattedMonthlyRevenue READ formattedMonthlyRevenue NOTIFY statsChanged)

public:
    explicit DashboardController(QObject *parent = nullptr);
    ~DashboardController();

    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }

    int totalInstructors() const { return m_totalInstructors; }
    int verifiedInstructors() const { return m_verifiedInstructors; }
    int pendingInstructors() const { return m_pendingInstructors; }

    int totalStudents() const { return m_totalStudents; }
    int activeStudents() const { return m_activeStudents; }

    int totalCourses() const { return m_totalCourses; }
    int activeCourses() const { return m_activeCourses; }
    int draftCourses() const { return m_draftCourses; }

    double totalRevenue() const { return m_totalRevenue; }
    double monthlyRevenue() const { return m_monthlyRevenue; }
    QString formattedTotalRevenue() const;
    QString formattedMonthlyRevenue() const;

    Q_INVOKABLE void loadStats();
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void reloadTokens();

signals:
    void isLoadingChanged();
    void errorMessageChanged();
    void statsChanged();

    void statsLoaded();

private slots:
    void onStatsLoaded(const QJsonObject &stats);
    void onStatsLoadFailed(const QString &errorMessage);
    void onRequestStarted();
    void onRequestFinished();

private:
    ApiManager *m_api;

    bool m_isLoading;
    QString m_errorMessage;

    int m_totalInstructors;
    int m_verifiedInstructors;
    int m_pendingInstructors;

    int m_totalStudents;
    int m_activeStudents;

    int m_totalCourses;
    int m_activeCourses;
    int m_draftCourses;

    double m_totalRevenue;
    double m_monthlyRevenue;

    void setLoading(bool loading);
    void setError(const QString &error);
    QString formatCurrency(double amount) const;
};

#endif // DASHBOARDCONTROLLER_H
