#include "transactioncontroller.h"
#include <QJsonArray>
#include <QLocale>
#include <QDateTime>
#include <QDebug>

TransactionController::TransactionController(QObject *parent)
    : QObject(parent)
    , m_api(new ApiManager(this))
    , m_isLoading(false)
    , m_totalRevenue(0.0)
    , m_thisMonthRevenue(0.0)
    , m_totalTransactions(0)
    , m_currentStatus("all")
    , m_currentPage(1)
    , m_totalPages(1)
    , m_limit(20)
    , m_total(0)
{
    connect(m_api, &ApiManager::transactionsLoaded,
            this, &TransactionController::onTransactionsLoaded);
    connect(m_api, &ApiManager::transactionsLoadFailed,
            this, &TransactionController::onTransactionsLoadFailed);

    connect(m_api, &ApiManager::requestStarted,
            this, &TransactionController::onRequestStarted);
    connect(m_api, &ApiManager::requestFinished,
            this, &TransactionController::onRequestFinished);
}

TransactionController::~TransactionController()
{
}

void TransactionController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void TransactionController::setError(const QString &error)
{
    if (m_errorMessage != error) {
        m_errorMessage = error;
        emit errorMessageChanged();
    }
}

QString TransactionController::formatCurrency(double amount) const
{
    QLocale locale(QLocale::English, QLocale::UnitedStates);
    return locale.toCurrencyString(amount, "$");
}

QString TransactionController::formattedTotalRevenue() const
{
    return formatCurrency(m_totalRevenue);
}

QString TransactionController::formattedThisMonthRevenue() const
{
    return formatCurrency(m_thisMonthRevenue);
}

void TransactionController::loadTransactions()
{
    clearError();

    QString status = m_currentStatus == "all" ? "" : m_currentStatus;
    m_api->getTransactions(m_currentPage, m_limit, status, m_searchQuery);
}

void TransactionController::setStatusFilter(const QString &status)
{
    if (m_currentStatus != status) {
        m_currentStatus = status;
        m_currentPage = 1; // Reset to first page
        emit currentStatusChanged();
        emit currentPageChanged();
        loadTransactions();
    }
}

void TransactionController::setSearchQuery(const QString &query)
{
    if (m_searchQuery != query) {
        m_searchQuery = query;
        m_currentPage = 1; // Reset to first page
        emit searchQueryChanged();
        emit currentPageChanged();
        loadTransactions();
    }
}

void TransactionController::nextPage()
{
    if (m_currentPage < m_totalPages) {
        m_currentPage++;
        emit currentPageChanged();
        loadTransactions();
    }
}

void TransactionController::previousPage()
{
    if (m_currentPage > 1) {
        m_currentPage--;
        emit currentPageChanged();
        loadTransactions();
    }
}

void TransactionController::goToPage(int page)
{
    if (page >= 1 && page <= m_totalPages && page != m_currentPage) {
        m_currentPage = page;
        emit currentPageChanged();
        loadTransactions();
    }
}

void TransactionController::clearError()
{
    setError("");
}

void TransactionController::refresh()
{
    loadTransactions();
}

void TransactionController::onTransactionsLoaded(const QJsonObject &data)
{
    if (data.contains("summary")) {
        updateSummary(data["summary"].toObject());
    }

    if (data.contains("transactions")) {
        updateTransactionsList(data["transactions"].toArray());
    }

    if (data.contains("pagination")) {
        updatePagination(data["pagination"].toObject());
    }

    emit transactionsLoaded();
}

void TransactionController::onTransactionsLoadFailed(const QString &errorMessage)
{
    setError(errorMessage.isEmpty() ?
                 "Failed to load transactions. Please try again." :
                 errorMessage);
}

void TransactionController::onRequestStarted()
{
    setLoading(true);
}

void TransactionController::onRequestFinished()
{
    setLoading(false);
}

void TransactionController::updateSummary(const QJsonObject &summary)
{
    m_totalRevenue = summary["totalRevenue"].toDouble();
    m_thisMonthRevenue = summary["thisMonthRevenue"].toDouble();
    m_totalTransactions = summary["totalTransactions"].toInt();

    emit summaryChanged();
}

void TransactionController::updateTransactionsList(const QJsonArray &transactionsArray)
{
    m_transactions.clear();

    for (const QJsonValue &value : transactionsArray) {
        QJsonObject transaction = value.toObject();

        QVariantMap transactionMap;
        transactionMap["orderId"] = transaction["orderId"].toString();
        transactionMap["orderNumber"] = transaction["orderNumber"].toString();
        transactionMap["amount"] = transaction["amount"].toDouble();
        transactionMap["formattedAmount"] = formatCurrency(transaction["amount"].toDouble());
        transactionMap["status"] = transaction["status"].toString();
        transactionMap["paymentMethod"] = transaction["paymentMethod"].toString();
        transactionMap["createdAt"] = transaction["createdAt"].toString();

        // Format payment method display
        QString paymentMethod = transaction["paymentMethod"].toString();
        if (paymentMethod == "credit_card") {
            transactionMap["paymentMethodDisplay"] = "Credit Card";
        } else if (paymentMethod == "debit_card") {
            transactionMap["paymentMethodDisplay"] = "Debit Card";
        } else if (paymentMethod == "paypal") {
            transactionMap["paymentMethodDisplay"] = "PayPal";
        } else {
            transactionMap["paymentMethodDisplay"] = paymentMethod;
        }

        // Student info
        QJsonObject student = transaction["student"].toObject();
        transactionMap["studentName"] = student["name"].toString();
        transactionMap["studentEmail"] = student["email"].toString();
        transactionMap["studentImage"] = student["profileImage"].toString();

        // Courses info
        QJsonArray coursesArray = transaction["courses"].toArray();
        QVariantList coursesList;
        for (const QJsonValue &courseValue : coursesArray) {
            QJsonObject course = courseValue.toObject();
            QVariantMap courseMap;
            courseMap["courseId"] = course["courseId"].toString();
            courseMap["title"] = course["title"].toString();
            courseMap["price"] = course["price"].toDouble();
            courseMap["formattedPrice"] = formatCurrency(course["price"].toDouble());
            coursesList.append(courseMap);
        }
        transactionMap["courses"] = coursesList;

        // Format dates
        transactionMap["formattedDate"] = formatDateTime(transaction["createdAt"].toString());
        transactionMap["relativeTime"] = formatRelativeTime(transaction["createdAt"].toString());

        // Status display
        QString status = transaction["status"].toString();
        transactionMap["statusText"] = status.left(1).toUpper() + status.mid(1);

        m_transactions.append(transactionMap);
    }

    emit transactionsChanged();
}

void TransactionController::updatePagination(const QJsonObject &pagination)
{
    m_currentPage = pagination["page"].toInt();
    m_limit = pagination["limit"].toInt();
    m_total = pagination["total"].toInt();
    m_totalPages = pagination["pages"].toInt();

    emit currentPageChanged();
    emit paginationChanged();
    emit limitChanged();
}

QString TransactionController::formatDateTime(const QString &dateString) const
{
    if (dateString.isEmpty()) {
        return "Unknown";
    }

    QDateTime dateTime = QDateTime::fromString(dateString, Qt::ISODate);
    if (!dateTime.isValid()) {
        return "Unknown";
    }

    return dateTime.toString("MMM dd, yyyy hh:mm AP");
}

QString TransactionController::formatRelativeTime(const QString &dateString) const
{
    if (dateString.isEmpty()) {
        return "";
    }

    QDateTime dateTime = QDateTime::fromString(dateString, Qt::ISODate);
    if (!dateTime.isValid()) {
        return "";
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
    } else {
        return formatDateTime(dateString);
    }
}
