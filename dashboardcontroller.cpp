#include "dashboardcontroller.h"
#include <QLocale>
#include <QDebug>

DashboardController::DashboardController(QObject *parent)
    : QObject(parent)
    , m_api(new ApiManager(this))
    , m_isLoading(false)
    , m_totalInstructors(0)
    , m_verifiedInstructors(0)
    , m_pendingInstructors(0)
    , m_totalStudents(0)
    , m_activeStudents(0)
    , m_totalCourses(0)
    , m_activeCourses(0)
    , m_draftCourses(0)
    , m_totalRevenue(0.0)
    , m_monthlyRevenue(0.0)
{
    // Connect API signals
    connect(m_api, &ApiManager::dashboardStatsLoaded,
            this, &DashboardController::onStatsLoaded);
    connect(m_api, &ApiManager::dashboardStatsLoadFailed,
            this, &DashboardController::onStatsLoadFailed);

    connect(m_api, &ApiManager::requestStarted,
            this, &DashboardController::onRequestStarted);
    connect(m_api, &ApiManager::requestFinished,
            this, &DashboardController::onRequestFinished);
}

DashboardController::~DashboardController()
{
}

// ==================== HELPER METHODS ====================

void DashboardController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void DashboardController::setError(const QString &error)
{
    if (m_errorMessage != error) {
        m_errorMessage = error;
        emit errorMessageChanged();
    }
}

QString DashboardController::formatCurrency(double amount) const
{
    QLocale locale(QLocale::English, QLocale::UnitedStates);
    return locale.toCurrencyString(amount, "$");
}

QString DashboardController::formattedTotalRevenue() const
{
    return formatCurrency(m_totalRevenue);
}

QString DashboardController::formattedMonthlyRevenue() const
{
    return formatCurrency(m_monthlyRevenue);
}

// ==================== PUBLIC METHODS ====================

void DashboardController::loadStats()
{
    clearError();
    m_api->getDashboardStats();
}

void DashboardController::clearError()
{
    setError("");
}

// ==================== PRIVATE SLOTS ====================

void DashboardController::onStatsLoaded(const QJsonObject &stats)
{
    // Parse instructors
    QJsonObject instructors = stats["instructors"].toObject();
    m_totalInstructors = instructors["total"].toInt();
    m_verifiedInstructors = instructors["verified"].toInt();
    m_pendingInstructors = instructors["pending"].toInt();

    // Parse students
    QJsonObject students = stats["students"].toObject();
    m_totalStudents = students["total"].toInt();
    m_activeStudents = students["active"].toInt();

    // Parse courses
    QJsonObject courses = stats["courses"].toObject();
    m_totalCourses = courses["total"].toInt();
    m_activeCourses = courses["active"].toInt();
    m_draftCourses = courses["draft"].toInt();

    // Parse revenue
    QJsonObject revenue = stats["revenue"].toObject();
    m_totalRevenue = revenue["total"].toDouble();
    m_monthlyRevenue = revenue["thisMonth"].toDouble();

    emit statsChanged();
    emit statsLoaded();
}

void DashboardController::onStatsLoadFailed(const QString &errorMessage)
{
    setError(errorMessage.isEmpty() ?
                 "Failed to load dashboard statistics. Please try again." :
                 errorMessage);
}

void DashboardController::onRequestStarted()
{
    setLoading(true);
}

void DashboardController::onRequestFinished()
{
    setLoading(false);
}
