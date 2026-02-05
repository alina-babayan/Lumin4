#ifndef COURSECONTROLLER_H
#define COURSECONTROLLER_H

#include <QObject>
#include <QJsonObject>
#include "apimanager.h"

class CourseController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(int totalCourses READ totalCourses NOTIFY statsChanged)
    Q_PROPERTY(int draftCourses READ draftCourses NOTIFY statsChanged)
    Q_PROPERTY(int pendingReviewCourses READ pendingReviewCourses NOTIFY statsChanged)
    Q_PROPERTY(int publishedCourses READ publishedCourses NOTIFY statsChanged)
    Q_PROPERTY(int rejectedCourses READ rejectedCourses NOTIFY statsChanged)

public:
    explicit CourseController(QObject *parent = nullptr);
    ~CourseController();

    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }
    int totalCourses() const { return m_totalCourses; }
    int draftCourses() const { return m_draftCourses; }
    int pendingReviewCourses() const { return m_pendingReviewCourses; }
    int publishedCourses() const { return m_publishedCourses; }
    int rejectedCourses() const { return m_rejectedCourses; }

    Q_INVOKABLE void loadStats();
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void refresh();

signals:
    void isLoadingChanged();
    void errorMessageChanged();
    void statsChanged();
    void statsLoaded();

private slots:
    void onCourseStatsLoaded(const QJsonObject &data);
    void onCourseStatsLoadFailed(const QString &errorMessage);
    void onRequestStarted();
    void onRequestFinished();

private:
    ApiManager *m_api;

    bool m_isLoading;
    QString m_errorMessage;
    int m_totalCourses;
    int m_draftCourses;
    int m_pendingReviewCourses;
    int m_publishedCourses;
    int m_rejectedCourses;

    void setLoading(bool loading);
    void setError(const QString &error);
    void updateStats(const QJsonObject &stats);
};

#endif // COURSECONTROLLER_H
