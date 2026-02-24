#include "coursecontroller.h"
#include <QDebug>

CourseController::CourseController(QObject *parent)
    : QObject(parent)
    , m_api(new ApiManager(this))
    , m_isLoading(false)
    , m_totalCourses(0)
    , m_draftCourses(0)
    , m_pendingReviewCourses(0)
    , m_publishedCourses(0)
    , m_rejectedCourses(0)
{
    connect(m_api, &ApiManager::courseStatsLoaded,
            this, &CourseController::onCourseStatsLoaded);
    connect(m_api, &ApiManager::courseStatsLoadFailed,
            this, &CourseController::onCourseStatsLoadFailed);

    connect(m_api, &ApiManager::requestStarted,
            this, &CourseController::onRequestStarted);
    connect(m_api, &ApiManager::requestFinished,
            this, &CourseController::onRequestFinished);
}

CourseController::~CourseController()
{
}

void CourseController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void CourseController::setError(const QString &error)
{
    if (m_errorMessage != error) {
        m_errorMessage = error;
        emit errorMessageChanged();
    }
}

void CourseController::reloadTokens()
{
    // Re-read the access token from QSettings so this controller's
    // ApiManager picks up the token saved by AuthController after login.
    m_api->loadTokens();
    qDebug() << "CourseController: tokens reloaded, logged in:"
             << m_api->isLoggedIn();
}

void CourseController::loadStats()
{
    clearError();
    m_api->getCourseStats();
}

void CourseController::clearError()
{
    setError("");
}

void CourseController::refresh()
{
    loadStats();
}

void CourseController::onCourseStatsLoaded(const QJsonObject &data)
{
    qDebug() << "Course stats response:" << data;

    if (data.contains("stats")) {
        updateStats(data["stats"].toObject());
    } else {
        updateStats(data);
    }

    emit statsLoaded();
}

void CourseController::onCourseStatsLoadFailed(const QString &errorMessage)
{
    setError(errorMessage.isEmpty() ?
                 "Failed to load course statistics. Please try again." :
                 errorMessage);
}

void CourseController::onRequestStarted()
{
    setLoading(true);
}

void CourseController::onRequestFinished()
{
    setLoading(false);
}

void CourseController::updateStats(const QJsonObject &stats)
{
    qDebug() << "Updating stats with:" << stats;

    m_totalCourses = stats.contains("total") ? stats["total"].toInt() : 0;
    m_draftCourses = stats.contains("draft") ? stats["draft"].toInt() : 0;

    if (stats.contains("pending_review")) {
        m_pendingReviewCourses = stats["pending_review"].toInt();
    } else if (stats.contains("pendingReview")) {
        m_pendingReviewCourses = stats["pendingReview"].toInt();
    } else {
        m_pendingReviewCourses = 0;
    }

    m_publishedCourses = stats.contains("published") ? stats["published"].toInt() : 0;
    m_rejectedCourses  = stats.contains("rejected")  ? stats["rejected"].toInt()  : 0;

    qDebug() << "Stats updated - Total:" << m_totalCourses
             << "Draft:" << m_draftCourses
             << "Pending:" << m_pendingReviewCourses
             << "Published:" << m_publishedCourses
             << "Rejected:" << m_rejectedCourses;

    emit statsChanged();
}
